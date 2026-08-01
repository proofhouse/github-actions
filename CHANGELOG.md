# Changelog

## Unreleased ([e95a868..b407ccb](https://github.com/proofhouse/github-actions/compare/e95a868..b407ccb))

### Continuous Integration

- (**renovate**) check that preset references resolve (#39) - ([ef3ecc2](https://github.com/proofhouse/github-actions/commit/ef3ecc265ff637d2df3968a200e578070e06617c)) - [@tbhb](https://github.com/tbhb)
- (**renovate**) add a shared Go preset and gate it in CI (#35) - ([34ef434](https://github.com/proofhouse/github-actions/commit/34ef434049062eb766b4f1b9d41ad9a76c3415f2)) - [@tbhb](https://github.com/tbhb)
- (**tombi**) add the org config lint and format gate (#38) - ([b407ccb](https://github.com/proofhouse/github-actions/commit/b407ccbc2e1bec21bf9d9c03149f88e9f60d9c12)) - [@tbhb](https://github.com/tbhb)

- - -

## [v0.3.0](https://github.com/proofhouse/github-actions/compare/v0.2.2..v0.3.0) - 2026-08-01

### Continuous Integration

- (**brew**) update Homebrew before installing dependencies (#33) - ([39f507a](https://github.com/proofhouse/github-actions/commit/39f507a587ad2d8cfafd03a307437dc0bffa2833)) - [@tbhb](https://github.com/tbhb)
- (**vale**) pin the vale binary through a setup-vale composite (#36) - ([60ea3c5](https://github.com/proofhouse/github-actions/commit/60ea3c57e2e2b8ad8f185d5ae792c0da5caf0de7)) - [@tbhb](https://github.com/tbhb)
- (**vale**) follow the vale CLI repo move to vale-cli/vale (#27) - ([c132edd](https://github.com/proofhouse/github-actions/commit/c132edd4becaa7553e0cfe8e0f0cbdcc60b5fa56)) - [@tbhb](https://github.com/tbhb)

- - -

## [v0.2.2](https://github.com/proofhouse/github-actions/compare/v0.2.1..v0.2.2) - 2026-07-09

### Continuous Integration

- (**renovate**) inline global options to drop the anonymous preset fetch (#24) - ([9475ff5](https://github.com/proofhouse/github-actions/commit/9475ff5f832e9d9de656e5dce0eb42e6094a2311)) - [@tbhb](https://github.com/tbhb), [@tbhb](https://github.com/tbhb)
- advance the setup-just pins to v0.2.1 (#21) - ([b791f01](https://github.com/proofhouse/github-actions/commit/b791f01710e652029365fa5c8ac3dacb518b3ca7)) - [@tbhb](https://github.com/tbhb)

- - -

## [v0.2.1](https://github.com/proofhouse/github-actions/compare/v0.2.0..v0.2.1) - 2026-06-13

### Bug Fixes

- (**renovate**) authenticate github.com reads with GITHUB_COM_TOKEN (#15) - ([8c8ec32](https://github.com/proofhouse/github-actions/commit/8c8ec325dad4f79a737038d2444a44f3bf437bf6)) - [@tbhb](https://github.com/tbhb)

#### Continuous Integration

- (**renovate**) group the engine and validator image pins - ([329a249](https://github.com/proofhouse/github-actions/commit/329a249c01ca3f5137313d2e6e5fc011df8f41da)) - [@tbhb](https://github.com/tbhb)
- (**renovate**) use shared presets in this repo config (#11) - ([8a32909](https://github.com/proofhouse/github-actions/commit/8a32909e7636e1c174103ad79f9611474862840d)) - [@tbhb](https://github.com/tbhb)
- (**renovate**) add shared org config presets (#10) - ([c1e4c2b](https://github.com/proofhouse/github-actions/commit/c1e4c2b984241aa955b38c8c6a3822bafc3412df)) - [@tbhb](https://github.com/tbhb)
- (**renovate**) track Vale style packages in .vale.ini (#9) - ([78fc620](https://github.com/proofhouse/github-actions/commit/78fc62067ec402e78ac956db8731f9e2d339398d)) - [@tbhb](https://github.com/tbhb)
- default vale output to the agent template - ([c6f6070](https://github.com/proofhouse/github-actions/commit/c6f60702dcf4a6593c8420a6c05f5b569ad24adf)) - [@tbhb](https://github.com/tbhb)
- adopt the shared proofhouse vale package - ([780e0ec](https://github.com/proofhouse/github-actions/commit/780e0ec65796ef62b8137554298f1e093d59a883)) - [@tbhb](https://github.com/tbhb)
- put Homebrew on the runner PATH before brew bundle - ([0a45ec7](https://github.com/proofhouse/github-actions/commit/0a45ec70ae82ac42f907174f49d8e768677135b8)) - [@tbhb](https://github.com/tbhb)
- run the local lint gates in a ci workflow - ([c6f5aeb](https://github.com/proofhouse/github-actions/commit/c6f5aebef0b7aca4666fedbaf5ec26bc19740e37)) - [@tbhb](https://github.com/tbhb)
- add a gitleaks security workflow - ([45eca71](https://github.com/proofhouse/github-actions/commit/45eca711767063fabe169e590c75d670bffff2ce)) - [@tbhb](https://github.com/tbhb)
- remove unused setup-toolchain action (#5) - ([ae47537](https://github.com/proofhouse/github-actions/commit/ae475373d18cbec1f07f62ad1f34d7a9b0902fde)) - [@tbhb](https://github.com/tbhb)

#### Style

- rephrase the figurative verb in the worktree rules - ([45b0f8d](https://github.com/proofhouse/github-actions/commit/45b0f8de011f5d99161f0e890dceea07d746c2a0)) - [@tbhb](https://github.com/tbhb)

- - -

## [v0.2.0](https://github.com/proofhouse/github-actions/compare/v0.1.0..v0.2.0) - 2026-05-31

### Features

- (**workflows**) make CODEOWNERS and Renovate workflows reusable - ([8dcb940](https://github.com/proofhouse/github-actions/commit/8dcb940147ca7c7cbd842e5c0f766a206e9f732f)) - [@tbhb](https://github.com/tbhb)

#### Continuous Integration

- bump rumdl-pre-commit to v0.2.4 - ([f2dac68](https://github.com/proofhouse/github-actions/commit/f2dac68aa60dff300454682deca8f49a684099e8)) - [@tbhb](https://github.com/tbhb)
- scope Changelog rule exclusions to rumdl per-path config - ([5052217](https://github.com/proofhouse/github-actions/commit/5052217031d0a933d0ed241ca0300bfef63b5780)) - [@tbhb](https://github.com/tbhb)

- - -

## [v0.1.0](https://github.com/proofhouse/github-actions/compare/273a1797d570ae62b39a8af3c0b7fa005087649a..v0.1.0) - 2026-05-31

### Features

- (**hooks**) adopt shared commit-msg gates - ([66f096e](https://github.com/proofhouse/github-actions/commit/66f096ef0e8cb3415f3761b757ab1929b37119d0)) - [@tbhb](https://github.com/tbhb)
- (**workflows**) expose lint-workflows as a reusable workflow - ([0de69c2](https://github.com/proofhouse/github-actions/commit/0de69c235933c499a04ad1503f83c16ec8f7ea02)) - [@tbhb](https://github.com/tbhb)

#### Documentation

- add Apache-2.0 license - ([273a179](https://github.com/proofhouse/github-actions/commit/273a1797d570ae62b39a8af3c0b7fa005087649a)) - [@tbhb](https://github.com/tbhb)
