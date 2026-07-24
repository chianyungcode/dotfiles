# Chezmoi Scripts Refactor Design

## Summary

Refactor `chezmoi/.chezmoiscripts` from 21 independently orchestrated scripts
into eight phase-oriented entrypoints. Keep Bash and Chezmoi as the only
orchestration mechanisms, preserve platform-specific behavior, and make
fail-fast execution, dependency ordering, and testing explicit.

The refactor separates three responsibilities:

1. `.chezmoidata` declares what should be installed.
2. `.chezmoitemplates` defines how each platform performs the work.
3. `.chezmoiscripts` defines when each phase runs.

The result should reduce the number of executable entrypoints without replacing
the current scripts with a single opaque installer framework.

## Current State

The current script layer contains:

- 21 script templates.
- 1,276 lines across the script templates.
- A 452-line `shared_script_utils.bash` included in every script.
- Approximately 6,300 rendered lines for the current macOS profile.
- Approximately 7,100 to 7,400 rendered lines for representative Linux
  profiles.

The common utility template includes logging, traps, temporary-directory
handling, array matching, dependency installation, and `uv` discovery. Most
scripts use only logging plus one specialized helper. Because the complete
utility is rendered into every script, changing it changes the rendered
contents of all `run_once` and `run_onchange` consumers.

The audit also found concrete reliability issues:

- `run_onchange_before-10-paru-packages.sh.tmpl` does not use Chezmoi's
  `before_` attribute because its separator is a hyphen instead of an
  underscore.
- `run_after_30-instal-atuin.sh.tmpl` contains a filename typo.
- `run_after_30-install-non-pkg-manager-binaries.sh.tmpl` invokes
  `~/bin/install-binary.py`, but that file is not present in the source tree.
- The APT branch in `run_onchange_after_10-remove-packages.sh.tmpl` contains a
  malformed removal command.
- On a fresh Arch installation, Cargo and npm package phases can run before
  `mise` installs Rust and Node.
- Paru bootstrap is nested under the "missing prerequisite" condition, so Paru
  is not installed when the prerequisite commands exist but Paru itself does
  not.
- Several scripts query release APIs or perform update checks on every
  `chezmoi apply`.
- The existing render-config test currently fails because a secretless test
  configuration unexpectedly enables Age encryption. This is a pre-existing
  baseline failure and must be fixed or isolated before refactor verification.

## Goals

- Reduce `.chezmoiscripts` from 21 entrypoints to eight.
- Make ordering and dependencies visible in phase names.
- Retain Bash and native Chezmoi script semantics.
- Stop on the first installation or verification failure.
- Make a partially completed phase safe to retry.
- Avoid network and release-version checks during an unchanged regular apply.
- Keep platform-specific implementation code independently readable.
- Prevent changes to specialized helpers from changing unrelated script hashes.
- Render and statically validate representative macOS, Ubuntu, and Arch
  profiles.
- Test fail-fast behavior without installing real packages.

## Non-Goals

- Reworking the package list beyond changes required by the refactor.
- Introducing `mise tasks`, Make, Task, or another orchestration layer.
- Adding a new package manager.
- Changing the secret provider or remote-server data format.
- Defining new automatic upgrade policies for Homebrew, APT, npm, or Cargo.
- Refactoring unrelated shell configuration.
- Executing real installers during automated tests.

## Architecture

### Data: What to Install

Split the current 769-line `packages.toml` along execution boundaries:

```text
.chezmoidata/
├── packages-system.toml
├── packages-language.toml
└── binaries.toml
```

Ownership is exclusive:

- `packages-system.toml` owns `packages.homebrew`, `packages.mas`,
  `packages.apt`, and `packages.pacman`.
- `packages-language.toml` owns `packages.python`, `packages.node`, and
  `packages.cargo`, plus the runtime versions consumed by `mise`. Preserve the
  current `latest` selections as explicit data during migration.
- `binaries.toml` continues to own standalone GitHub-release binaries.

Chezmoi merges dictionaries from multiple `.chezmoidata` files but replaces
lists when the same key appears later. Exclusive key ownership prevents
order-dependent list replacement.

### Template Fragments: How to Install

Organize reusable implementation fragments under `.chezmoitemplates/scripts`:

```text
.chezmoitemplates/scripts/
├── core.bash
├── system/
│   ├── homebrew.bash
│   ├── apt.bash
│   └── paru.bash
├── language/
│   ├── runtimes.bash
│   └── packages.bash
└── standalone/
    └── github-release.bash
```

The tree defines the required logical boundaries. A listed fragment may be
split further only when it would otherwise exceed 200 lines; fragments from
different boundaries must not be combined:

- Core shell behavior is universal and minimal.
- Package-manager adapters own manager-specific queries and commands.
- Language helpers own runtime and language-package operations.
- GitHub-release logic is included only by the standalone-tool phase.

Only the fragment for the active OS is rendered into a system-package script.
For example, changing Homebrew implementation or macOS package data must not
change the rendered Ubuntu script.

### Entrypoints: When to Install

Create these eight entrypoints:

<!-- markdownlint-disable MD013 -->

| Phase | Entrypoint | Responsibility |
| --- | --- | --- |
| 00 | `run_before_00-bootstrap.sh.tmpl` | Ensure minimum commands and package managers exist |
| 10 | `run_onchange_before_10-system-packages.sh.tmpl` | Enforce OS package-manager state when configuration changes |
| 20 | `run_onchange_after_20-language-runtimes.sh.tmpl` | Install `uv`, `mise`, and declared runtimes |
| 30 | `run_onchange_after_30-language-packages.sh.tmpl` | Reconcile uv, npm, and Cargo packages |
| 40 | `run_onchange_after_40-standalone-tools.sh.tmpl` | Install tools outside system package managers |
| 50 | `run_after_50-post-install.sh.tmpl` | Repair cheap, idempotent user-level setup |
| 60 | `run_onchange_after_60-security-material.sh.tmpl` | Create SSH material from the configured secret provider |
| 90 | `run_once_after_90-monthly-maintenance.sh.tmpl` | Run explicitly approved monthly upgrades |

<!-- markdownlint-enable MD013 -->

## Phase Design

### Phase 00: Bootstrap

Run before target-state changes on every apply. Checks must be local and cheap;
network access occurs only when a required bootstrap component is missing.

Responsibilities:

- Ensure minimum commands such as `curl`, `wget`, and `unzip`.
- Install Homebrew on macOS when absent.
- Install the prerequisites for Paru on Arch.
- Install Paru whenever it is missing, independently of whether other
  prerequisites were missing.

This phase does not install user applications or language runtimes.

### Phase 10: System Packages

Render exactly one platform implementation:

- macOS: Homebrew formulae, Homebrew casks, and MAS applications.
- Ubuntu: APT packages and required repositories, including Eza setup.
- Arch: Pacman/Paru packages.

System-package removals belong to the matching manager adapter. Configured
packages are required; an unavailable or failed package stops the phase.

The current Homebrew, APT, Paru, MAS, Eza, and system-removal scripts are
replaced by this phase.

### Phase 20: Language Runtimes

Install runtime managers and runtime executables before language packages:

1. Install or verify `uv`.
2. Install or verify `mise` on every profile with declared mise-managed
   runtimes.
3. Install the declared Node, Go, Rust, Bun, Deno, and Taplo versions.
4. Verify required commands such as `uv`, `npm`, and `cargo` for the active
   package lists.

The version declaration must be rendered into this script so changing a
declared runtime version changes the `run_onchange` content.

### Phase 30: Language Packages

Reconcile language-level packages in this fixed order:

1. uv tools.
2. npm global packages.
3. Cargo crates.

The phase replaces the current Python, Node, and Cargo package scripts.
Language-package removals are handled by their owning manager rather than by a
cross-manager removal script.

### Phase 40: Standalone Tools

Install software that is not managed by the active system package manager:

- Atuin on Linux profiles that need a standalone installation.
- Git Credential Manager only on Ubuntu or Debian `amd64` systems where `dpkg`
  is available.
- Entries from `binaries.toml`, currently including `bottom`, `doggo`,
  `delta`, `lazygit`, `rip`, and `zoxide`.

Replace the missing Python installer with a Bash GitHub-release helper. The
helper must:

- Select an asset by OS, architecture, and configured pattern.
- Download into a private temporary directory.
- Fail on HTTP and extraction errors.
- Verify a checksum when the upstream release publishes one.
- Install atomically where practical.
- Verify the expected executable after installation.

The data format may gain explicit asset and checksum patterns, but must not
embed manager-specific execution logic.

### Phase 50: Post-Install

Run after every apply, using local postcondition checks to make the common path
cheap.

Responsibilities:

- Install Antidote only when its target directory is absent.
- Install nanorc only when its expected files are absent.
- Create `batcat` to `bat` and `fdfind` to `fd` symlinks when needed.

This phase is intentionally `run_after` rather than `run_onchange` so deleted
symlinks or directories are repaired on the next apply. It must not access the
network when all postconditions already hold.

### Phase 60: Security Material

Keep SSH key creation separate because it accesses the secret provider and
writes private material.

Requirements:

- Render an empty script when no secret provider is configured.
- Use `umask 077` for private material.
- Use `printf`, not `echo`, for key content.
- Set private keys to mode `0600` and public keys to mode `0644`.
- Never log key content.
- Leave existing keys unchanged unless the declared behavior explicitly
  requires replacement.

Migrating dynamic SSH keys to ordinary Chezmoi target files is a possible
future design, not part of this refactor.

### Phase 90: Monthly Maintenance

Preserve the current monthly content-change technique and initially retain only
the existing approved behavior:

```bash
uv tool upgrade --all
```

Do not add Homebrew, APT, npm, Cargo, or system-wide upgrades as part of this
refactor.

## Core Shell Contract

`core.bash` should be approximately 50 to 80 lines and remain compatible with
Bash 3.2, which is the bootstrap baseline on macOS.

It provides:

- `set -Eeuo pipefail`.
- A phase name used in every message.
- Simple `info`, `notice`, and `die` functions.
- `require_command`.
- Secure temporary-directory creation.
- An `EXIT` trap that only performs cleanup.
- An `ERR` trap that reports phase, line, command, and exit status.

It does not provide:

- A configurable logging framework.
- Log-level parsing.
- Automatic dependency installation.
- GitHub API logic.
- Package-manager abstraction.
- Global `FORCE` or `DRYRUN` variables that no consumer implements.

Normal control flow uses `return` or `exit 0`; it does not call a generalized
safe-exit function.

## Failure and Retry Semantics

All configured packages and tools are required. The first failed install,
download, extraction, checksum, or post-install verification returns non-zero
and stops `chezmoi apply`.

Expected conditions are not errors:

- An already satisfied postcondition is skipped.
- A platform-inapplicable operation is omitted at template-render time.
- An empty configured package list completes successfully.

Package managers cannot provide transaction-wide rollback, so a failed phase
may leave earlier packages installed. Every operation must therefore be
idempotent. A retry skips completed work and attempts the failed operation
again.

## Update and Network Policy

- When triggered, regular phases enforce declared state; they do not upgrade
  every installed tool or repair drift on an otherwise unchanged
  `run_onchange` phase.
- Release APIs are not queried during an unchanged regular apply.
- Upgrade operations are explicit and isolated in phase 90.
- `curl` uses failure reporting, redirects, and bounded retries.
- Direct `curl | sh` execution is avoided.
- Package-manager installation is preferred over standalone installation.
- A bootstrap installer with no pre-existing package manager, such as initial
  Homebrew installation, may be a documented exception.

## Testing

### Render Matrix

Extend testing to render scripts for:

- macOS workstation.
- Ubuntu server.
- Ubuntu development server.
- Arch development workstation.
- CI/secretless.

Before using this matrix as a completion gate, fix or isolate the existing
secretless/Age baseline failure.

For every non-empty rendered script, run:

```bash
bash -n rendered-script.sh
shellcheck rendered-script.sh
```

The render tests must also assert:

- Ubuntu output does not contain Homebrew or Paru commands.
- macOS output does not contain APT or Paru commands.
- Arch output does not contain Homebrew or APT commands.
- A `none` secret provider does not invoke 1Password.
- Every rendered script has a valid shebang.
- Every source filename uses valid Chezmoi `before_` and `after_` attributes.

### Behavior Tests

Add a Bash-only test harness with fake executables for `brew`, `apt-get`,
`paru`, `mise`, `uv`, `npm`, and `cargo`. Fake commands record invocations and
return configured statuses.

Tests must verify:

- Phase and manager ordering.
- Already-installed packages are skipped.
- Language runtimes precede language packages.
- A failed package returns non-zero.
- Commands after the failure are not executed.
- Temporary directories are cleaned on success and failure.
- Error output names the phase and failed command.

No test may install packages, contact a release API, or require real
1Password credentials. Secret-provider rendering should use controlled test
data or a stub executable.

### Acceptance Commands

The implementation plan must define the exact commands, but completion requires
equivalents of:

```bash
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
chezmoi apply --dry-run --verbose
```

## Migration Strategy

Implement in independently verifiable stages:

1. Repair or isolate the secretless/Age baseline and add the script render
   matrix.
2. Introduce the minimal core and specialized template fragments.
3. Replace bootstrap and system-package scripts with phases 00 and 10.
4. Replace runtime and language-package scripts with phases 20 and 30.
5. Replace standalone installers with phase 40.
6. Replace post-install, security-material, and maintenance scripts with phases
   50, 60, and 90.
7. Remove superseded scripts and update all documentation references.
8. Run the complete render, static-analysis, behavior, and dry-run gates.

Do not remove an old script until its replacement renders and passes its focused
tests.

Renaming scripts changes their Chezmoi identity. The first apply after migration
will therefore execute the new `run_onchange` phases. Idempotency makes this
safe, but the first apply will take longer. Review
`chezmoi apply --dry-run --verbose` first, then validate on one representative
machine per platform before broad rollout.

## Documentation Updates

Update documentation that refers to the old script names or old utility API,
including:

- `README.md`
- `docs/01-remote-server-flow.md`
- `docs/02-homebrew-packages-flow.md`
- `docs/03-shell-scripting-chezmoi.md`
- `docs/security-review.md` where findings are resolved or paths change

Documentation should explain the three-layer model and list the eight phases,
not reproduce implementation details from every adapter.

## Completion Criteria

The refactor is complete when:

- Exactly eight intended executable phase entrypoints remain.
- Package and binary declarations have one clear data owner.
- Runtime dependencies are installed before language packages.
- All configured operations fail fast and are safe to retry.
- Unchanged regular applies perform no release-version checks.
- The missing Python installer reference and malformed removal logic are gone.
- Render tests pass for all representative profiles.
- Rendered scripts pass Bash syntax checks and ShellCheck.
- Fake-manager behavior tests prove fail-fast ordering.
- Chezmoi dry-run succeeds.
- Documentation references the new phase architecture.
