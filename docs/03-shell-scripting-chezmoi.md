# Shell Scripting with Chezmoi

## Three-Layer Architecture

Automation is divided by responsibility:

- `.chezmoidata/packages-system.toml` declares Homebrew, MAS, APT, and
  Pacman/Paru packages.
- `.chezmoidata/packages-language.toml` declares runtimes and uv, npm, and Cargo
  packages.
- `.chezmoidata/binaries.toml` declares standalone GitHub-release tools.
- `.chezmoidata/imperative-cli-tools.toml` declares CLI operations that need
  explicit checks and commands.
- `.chezmoitemplates/scripts/` contains reusable Bash implementation fragments.
- `.chezmoiscripts/` contains the ordered Chezmoi entrypoints.

Changing package data changes the rendered content of its owning `run_onchange`
phase. Platform conditions are evaluated while rendering, so a Homebrew-only
change does not alter the Ubuntu system-package script.

## Execution Phases

<!-- markdownlint-disable MD013 -->

| Phase | Timing            | Responsibility                                          |
| ----- | ----------------- | ------------------------------------------------------- |
| 00    | before, always    | Bootstrap package managers and minimum commands         |
| 10    | before, on change | Install system packages                                 |
| 20    | after, on change  | Install uv, mise, and language runtimes                 |
| 30    | after, on change  | Install uv, npm, and Cargo packages                     |
| 40    | after, on change  | Install standalone GitHub-release tools                 |
| 50    | after, always     | Repair shell extras, nanorc, and compatibility symlinks |
| 60    | after, on change  | Create SSH key material                                 |
| 70    | after, always     | Reconcile imperative CLI-managed state                  |
| 90    | after, monthly    | Upgrade uv-managed tools                                |

<!-- markdownlint-enable MD013 -->

The numeric phase is a dependency boundary. Runtime phase 20 must complete
before language-package phase 30.

## Core Shell Contract

Every non-empty phase:

- uses Bash 3.2-compatible syntax;
- enables `set -Eeuo pipefail`;
- stops on the first failed configured operation;
- reports the phase, line, command, and exit status;
- removes its private temporary directory on exit; and
- treats an already satisfied postcondition as success.

Package-manager transactions cannot be rolled back as a unit. Each operation
must therefore be idempotent so a later `chezmoi apply` can safely retry after
partial completion.

## Adding a Package

1. Add OS-managed applications to the matching table in `packages-system.toml`.
2. Add uv, npm, Cargo, or runtime entries to `packages-language.toml`.
3. Add archive-based Linux tools to `binaries.toml`.
4. Run the render and behavior tests.

Do not add a new entrypoint for a single package. Add manager-specific behavior
to its focused template fragment only when data alone cannot express it.

## Adding an Imperative CLI Operation

Some CLI tools do not provide a declarative configuration file for installing
plugins or extensions. Add those operations to
`.chezmoidata/imperative-cli-tools.toml` instead of creating a new script:

```toml
[[imperative_cli_tools]]
name = "Herdr Automatic Rename plugin"
cli = "herdr"
check = "herdr plugin list --json | jq -e '.result.plugins[] | select(.plugin_id == \"herdr-automatic-rename\")' >/dev/null"
run = "herdr plugin install qu8n/herdr-automatic-rename --yes"
```

Each entry must define:

- `name`: the label shown in Chezmoi output;
- `cli`: the executable whose absence makes this entry optional;
- `check`: a Bash command that succeeds when the desired state exists; and
- `run`: the Bash command that creates the desired state.

The phase in
[`run_after_70-imperative-cli-tools.sh.tmpl`](../chezmoi/.chezmoiscripts/run_after_70-imperative-cli-tools.sh.tmpl)
runs on every `chezmoi apply`. It skips entries when the CLI is unavailable or
the check succeeds, and stops immediately if a needed `run` command fails. It
does not remove resources that are absent from the data file.

## Validation

Run:

```bash
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
chezmoi apply --dry-run --verbose
```

The tests render macOS, Ubuntu, and Arch profiles, run Bash syntax checks and
ShellCheck, and execute fake package managers to verify fail-fast ordering.
