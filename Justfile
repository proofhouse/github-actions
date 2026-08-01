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

# Shared docker-run prefix. DOCKER_CONFIG points at a fresh empty dir so
# docker skips the osxkeychain helper; PATH prepends the runtime's dir
# for shells where docker isn't already on PATH.

docker_run := 'DOCKER_CONFIG="$(mktemp -d)" PATH="$(dirname ' + container_runtime + '):$PATH" ' + container_runtime + ' run --rm'

# The version CI pins through the setup-vale composite. Vale is
# brew-installed locally, so this is what `check-vale-version` compares
# against: a mismatch means local prose findings may not match the gate.

# renovate: datasource=github-releases depName=vale-cli/vale

vale_version := "3.17.0"

# The tombi release this repo's config and committed formatting are
# verified against. tombi is brew-installed, so `check-tombi-version`
# compares the local binary with it: a mismatch means local formatting
# may differ from what the gate expects.

# renovate: datasource=github-releases depName=tombi-toml/tombi

tombi_version := "1.2.5"

# renovate: datasource=docker depName=rhysd/actionlint

actionlint_version := "1.7.12"
actionlint_image := "docker.io/rhysd/actionlint:1.7.12@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667"

# actionlint via its SHA-pinned Docker image (bundles shellcheck), tree mounted read-only.

actionlint := docker_run + ' -v "$(pwd):/repo:ro" -w /repo ' + actionlint_image

# renovate: datasource=docker depName=ghcr.io/gitleaks/gitleaks

gitleaks_version := "v8.28.0"
gitleaks_image := "ghcr.io/gitleaks/gitleaks:v8.28.0@sha256:cdbb7c955abce02001a9f6c9f602fb195b7fadc1e812065883f695d1eeaba854"
gitleaks_scan := docker_run + ' -v "$(pwd):/repo" -w /repo ' + gitleaks_image

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

# Warn when the locally installed vale differs from the version CI pins.
# Advisory rather than fatal: local vale comes from Homebrew and drifts
# ahead on its own schedule, and that is fine so long as it stays
# visible. CI is the authority, so a mismatch means local findings may
# not match the gate.
[script]
check-vale-version:
    local=$(vale --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ "${local}" != "{{ vale_version }}" ]]; then
        echo "warning: local vale ${local} != CI-pinned {{ vale_version }}" >&2
        echo "         run 'brew upgrade vale' or expect findings to differ" >&2
    else
        echo "vale ${local} matches the CI pin"
    fi

# --- Format ---

# Format Markdown in place (whitespace, list markers, code fences).
format-markdown *args:
    rumdl fmt {{ if args == "" { "." } else { args } }}

# Format JSON / JS / TS in place via biome.
format-config *args:
    biome format --write {{ if args == "" { "." } else { args } }}

# In-place TOML formatter (tombi 1.2.0) — the fixer paired with `lint-toml`'s --check
# gate. Rewrites whitespace/style only; key and array order are preserved (schema-driven
# reordering is disabled in tombi.toml). Excludes and lockfile skips come from tombi.toml.
format-toml:
    tombi format

# --- Fix ---

# Apply rumdl's auto-fixable Markdown rules.
fix-markdown *args:
    rumdl check --fix {{ if args == "" { "." } else { args } }}

# --- Lint ---

# Run every linter over the source tree.
lint: lint-workflows lint-prose lint-spelling lint-markdown lint-config lint-yaml lint-toml

# Lint GitHub Actions workflows via actionlint (SHA-pinned Docker image).
lint-workflows:
    {{ actionlint }}

# Lint prose in Markdown via vale. The .claude/rules and .claude/skills
# entries plus apm_modules cover content that `apm install` deploys from
# proofhouse/agent-tools; that prose is upstream and pinned by the
# apm.lock.yaml hashes, so this repo never edits it to satisfy vale.
lint-prose *args:
    vale --output=proofhouse-agent.tmpl --glob='!{LICENSE,CHANGELOG.md,.vale/*,tmp/*,.claude/worktrees/*,COMMIT_AGENTMSG,apm_modules/*,.claude/rules/worktree-wip.md,.claude/skills/*}' {{ if args == "" { "." } else { args } }}

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

# tombi is the org TOML gate (tombi 1.2.0): it lint-checks every tracked *.toml.
# Cargo.toml/pyproject.toml validate offline against embedded SchemaStore schemas;
# cog.toml, .rumdl.toml, REUSE.toml, deny.toml et al. get syntax + style checks. We run
# the format gate in --check --diff mode here as well, so an unformatted TOML file fails
# `just lint` without being rewritten (`just format-toml` is the in-place fixer).
# --offline keeps CI hermetic against SchemaStore; --error-on-warnings promotes warnings
# to hard failures (matching the org -D-warnings / --max-warnings=0 posture). Scope
# (include/exclude, lockfile skips, schema.strict=false) lives in tombi.toml, so this
# recipe passes NO path args — tombi walks the tree per that config. This deliberately
# departs from the sibling `*args`-default-`.` idiom because tombi centralizes scoping in
# tombi.toml rather than on the CLI, keeping excludes in one place.
lint-toml:
    tombi format --check --diff
    tombi lint --offline --error-on-warnings

# Warn when the locally installed tombi differs from the verified
# release. Advisory rather than fatal: tombi comes from Homebrew and
# moves on its own schedule, and that is fine so long as it stays
# visible rather than silently reformatting a file the gate then
# rejects.
[script]
check-tombi-version:
    local=$(tombi --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    if [[ "${local}" != "{{ tombi_version }}" ]]; then
        echo "warning: local tombi ${local} != verified {{ tombi_version }}" >&2
        echo "         formatting may differ from what the gate expects" >&2
    else
        echo "tombi ${local} matches the verified release"
    fi

# Preview the four commit-msg gates against the COMMIT_AGENTMSG draft.
# prek needs .pre-commit-config.yaml staged to run.
lint-commit-msg:
    prek run --stage commit-msg --commit-msg-filename COMMIT_AGENTMSG

# --- Security ---

# Scan the working tree and full history for secrets via the pinned gitleaks image.
gitleaks:
    {{ gitleaks_scan }} git --verbose .

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

# Install the project's git hooks (commit-msg, pre-commit, pre-push).
prek-install:
    prek install -t commit-msg -t pre-commit -t pre-push

# Generate CHANGELOG.md from Conventional Commit history. Lint the file
# in place so the CHANGELOG.md per-file-ignores in .rumdl.toml apply
# (rumdl matches those globs against on-disk paths, not stdin).
generate-changelog:
    cog changelog | { echo "# Changelog"; cat; } > CHANGELOG.md
    rumdl check --fix CHANGELOG.md

# Preview changelog entries since the last tagged release.
preview-changelog:
    cog changelog --at $(git describe --tags)..HEAD -t full_hash | rumdl check -d MD041 --fix --stdin

# Generate release notes for a version (or HEAD if none given). MD041 is
# disabled for the heading-less fragment; without --isolated, MD013 stays
# off via .rumdl.toml so the full commit hashes are never wrapped.
[script]
generate-release-notes version="":
    v=$([[ -n "{{ version }}" ]] && echo "v{{ version }}" || echo "..$(git rev-parse HEAD)")
    cog changelog --at $v -t full_hash | rumdl check -d MD041 --fix --stdin
