# Agent instructions

Guidance for AI coding agents working in this repository. Read it alongside the per-tool documentation and any memory files the harness loads.

## Commit messages

Write [Conventional Commits](https://www.conventionalcommits.org/) (`type(scope): subject`) with a DCO `Signed-off-by` trailer, and keep the subject under 80 characters.

This repository doesn't yet run commit-message linting (vale prose checks, cspell, the Conventional Commits shape, and trailer order). That tooling comes from the shared `pre-commit-hooks` repository. Until it lands, follow the Conventional Commits shape and add the sign-off.
