set unstable := true
set positional-arguments := true

# Run [script] recipes under bash; dash lacks [[ ]], <<<, and pipefail.

set script-interpreter := ['bash', '-eu']

# Locate a Docker-compatible runtime; override with CONTAINER_RUNTIME.

container_runtime := env("CONTAINER_RUNTIME", `bash -c '
    docker_path=$(command -v docker 2>/dev/null || true)
    podman_path=$(command -v podman 2>/dev/null || true)
    for p in "$docker_path" \
             /usr/local/bin/docker \
             /opt/homebrew/bin/docker \
             /Applications/Docker.app/Contents/Resources/bin/docker \
             "$HOME/.docker/bin/docker" \
             "$HOME/.orbstack/bin/docker" \
             "$HOME/.rd/bin/docker" \
             "$podman_path" \
             /opt/podman/bin/podman; do
        if [ -n "$p" ] && [ -x "$p" ]; then echo "$p"; exit 0; fi
    done
    echo docker
'`)

# renovate: datasource=docker depName=rhysd/actionlint

actionlint_version := "1.7.12"
actionlint_image := "docker.io/rhysd/actionlint:1.7.12@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667"

# actionlint via its SHA-pinned Docker image (bundles shellcheck), tree mounted read-only.

actionlint := 'DOCKER_CONFIG="$(mktemp -d)" PATH="$(dirname ' + container_runtime + '):$PATH" ' + container_runtime + ' run --rm -v "$(pwd):/repo:ro" -w /repo ' + actionlint_image

# Default recipe.
default: lint

# --- Setup ---

# Set up the dev environment, refresh Vale styles, and install git hooks.
setup: install-brew install-tools prek-install

# Install Homebrew dependencies from Brewfile.
install-brew:
    brew bundle check || brew bundle install

# Refresh non-brew tooling (today: Vale's synced style packages).
install-tools:
    vale sync

# --- Format ---

# Format Markdown in place (whitespace, list markers, code fences).
format-markdown *args:
    rumdl fmt {{ if args == "" { "." } else { args } }}

# Format JSON / JS / TS in place via biome.
format-config *args:
    biome format --write {{ if args == "" { "." } else { args } }}

# --- Fix ---

# Apply rumdl's auto-fixable Markdown rules.
fix-markdown *args:
    rumdl check --fix {{ if args == "" { "." } else { args } }}

# --- Lint ---

# Run every linter over the source tree.
lint: lint-workflows lint-prose lint-spelling lint-markdown lint-config lint-yaml

# Lint GitHub Actions workflows via actionlint (SHA-pinned Docker image).
lint-workflows:
    {{ actionlint }}

# Lint prose in Markdown via vale.
lint-prose *args:
    vale --glob='!{LICENSE,CHANGELOG.md,.vale/*,tmp/*,.claude/worktrees/*,COMMIT_AGENTMSG}' {{ if args == "" { "." } else { args } }}

# Check spelling against the project dictionary (.cspell-words.txt).
lint-spelling *args:
    cspell --config .cspell.jsonc --no-summary --no-progress --no-must-find-files --exclude COMMIT_AGENTMSG {{ if args == "" { "." } else { args } }}

# Lint Markdown structure against .rumdl.toml.
lint-markdown *args:
    rumdl check {{ if args == "" { "." } else { args } }}

# Lint JSON / JS / TS via biome.
lint-config *args:
    biome check --files-ignore-unknown=true {{ if args == "" { "." } else { args } }}

# Lint YAML via yamllint (--strict; config in .yamllint.yaml).
lint-yaml *args:
    yamllint --strict {{ if args == "" { "." } else { args } }}

# --- Security ---

# Scan the working tree and git history for committed secrets via gitleaks.
gitleaks:
    gitleaks git --verbose .

# --- Aggregators ---

# Fast quality bar: the full lint set.
check: lint

# Comprehensive bar: lint plus the full-history gitleaks scan.
check-all: check gitleaks

# --- Utilities ---

# Sync Vale styles and dictionaries.
vale-sync:
    vale sync

# Run pre-commit hooks on changed files.
prek:
    prek

# Run pre-commit hooks on every file in the tree.
prek-all:
    prek run --all-files

# Install the project's pre-commit hooks (pre-commit, pre-push).
prek-install:
    prek install -t pre-commit -t pre-push

# Generate CHANGELOG.md from Conventional Commit history.
generate-changelog:
    cog changelog | { echo "# Changelog"; cat; } | rumdl check -d MD024 --fix --stdin > CHANGELOG.md

# Preview changelog entries since the last tagged release.
preview-changelog:
    cog changelog --at $(git describe --tags)..HEAD -t full_hash | rumdl check -d MD041 --fix --stdin

# Generate release notes for a version (or HEAD if none given).
[script]
generate-release-notes version="":
    v=$([[ -n "{{ version }}" ]] && echo "v{{ version }}" || echo "..$(git rev-parse HEAD)")
    cog changelog --at $v -t full_hash | rumdl check -d MD024,MD041 --isolated --fix --stdin
