# Agent instructions

Guidance for AI coding agents working in this repository. Read it alongside the per-tool documentation and any memory files the harness loads.

## Prose linting

`just lint-prose` and the vale pre-commit hook already emit the agent output template, which `just vale-sync` pulls in with the rest of the [`proofhouse`](https://github.com/proofhouse/vale-proofhouse) package. It prints one self-contained line per finding (location, severity, rule, the exact matched text, and the replacement when the rule carries one) plus a totals line, so you can fix every finding without follow-up searching. Pass `--output=proofhouse-agent.tmpl` yourself only when you invoke vale directly.

## Commit messages

Write [Conventional Commits](https://www.conventionalcommits.org/) (`type(scope): subject`) with a DCO `Signed-off-by` trailer, and keep the subject under 80 characters.

The `commit-msg` stage runs four hooks from the shared [`pre-commit-hooks`](https://github.com/proofhouse/pre-commit-hooks) repository: `commitlint` (the Conventional Commits shape and length bounds), `commit-trailers` (the AI-assistant trailer rules), `vale-commit-msg` (prose), and `cspell-commit-msg` (spelling). Run `just prek-install` once so the hooks fire on every commit.
