# Chezmoi Repository Structure

This repository stores the Chezmoi source state for the dotfiles. The important
distinction is between the repository root, the `chezmoi/` source directory,
and the rendered files in a user's home directory.

## Repository model

```text
repository root/
├── chezmoi/       Chezmoi source state
├── docs/          Contributor documentation
├── tests/         Render and behavior checks
└── others/        Supplemental assets and notes
```

The `chezmoi/` directory is the source directory passed to Chezmoi. Its source
names are transformed into target paths when `chezmoi apply` runs. For example:

```text
chezmoi/dot_config/fish/config.fish.tmpl
        │       │    │
        │       │    └─ rendered as ~/.config/fish/config.fish
        │       └────── dot_config becomes .config
        └────────────── source file is rendered as a target file
```

Chezmoi naming conventions used in this repository:

- `dot_` becomes a leading dot in the target path;
- `private_` marks a file or directory for private permissions;
- `executable_` marks a target as executable;
- `empty_` creates an empty target file; and
- `.tmpl` means the file is rendered as a Go template before installation.

The source directory also contains Chezmoi control directories. These are
inputs to rendering or lifecycle execution, not ordinary dotfiles installed in
the home directory.

## Chezmoi source tree

| Source path | Responsibility |
| --- | --- |
| `.chezmoi.toml.tmpl` | Generates the machine-specific Chezmoi configuration, including role, identity, feature, secrets, XDG, and encryption settings. |
| `.chezmoiignore` | Excludes target paths based on operating system, features, CI, and encryption settings. |
| `.chezmoidata/` | Stores structured data consumed by templates. |
| `.chezmoiexternals/` | Declares repositories and downloads managed outside the normal source tree. |
| `.chezmoiscripts/` | Defines ordered scripts that run before or after applying files. |
| `.chezmoitemplates/` | Stores reusable template fragments included by lifecycle scripts. |
| `bin/` | Installs executable helper scripts into the user's `bin` directory. |
| `dot_*`, `private_*`, and `empty_*` | Represent files and directories installed into the home directory. |

## `.chezmoidata/`: structured template data

Files under `.chezmoidata/` are loaded into Chezmoi's template data context.
They describe identities, packages, paths, secrets, and other choices without
being installed as files themselves.

| File | Purpose |
| --- | --- |
| `accounts.toml` | Identity profiles containing Git author and GitHub account settings. |
| `binaries.toml` | Metadata for standalone binaries downloaded from GitHub releases. |
| `constants.toml` | Shared directory constants such as repository, SSH-key, and user-bin paths. |
| `diff-name-apps.toml` | Homebrew cask-to-application-name mappings used when checking existing macOS apps. |
| `imperative-cli-tools.toml` | Checks and commands for CLI plugins or extensions that need imperative installation. |
| `macos-external-apps.toml` | macOS application download records consumed by the external-app template. |
| `onepassword.toml` | 1Password item references and document values used by secret-aware templates. |
| `packages-language.toml` | Python, Node, Cargo, and runtime package declarations. |
| `packages-system.toml` | Homebrew, Mac App Store, APT, and Pacman/`paru` package declarations. |
| `remote_servers.toml` | Remote host, SSH, key-generation, and 1Password item settings. |
| `shell_env.toml` | XDG paths, Homebrew paths, common environment variables, and PATH entries. |

The generated machine configuration from `.chezmoi.toml.tmpl` adds values such
as `.identity`, `.machine`, `.features`, `.secrets`, and `.xdg` to the same
template context.

## `.chezmoiscripts/`: lifecycle entrypoints

Chezmoi executes these templates according to their filename prefixes. The
prefix describes whether a script runs once or on change, whether it runs
before or after file application, and its numeric phase.

| Script | Phase and responsibility |
| --- | --- |
| `run_once_before_00-bootstrap.sh.tmpl` | Prepares platform prerequisites and package managers, including Homebrew or `paru`. |
| `run_onchange_before_10-system-packages.sh.tmpl` | Installs and removes OS-level packages selected for the machine. |
| `run_onchange_after_20-language-runtimes.sh.tmpl` | Installs configured language runtimes through `uv` and `mise`. |
| `run_onchange_after_30-language-packages.sh.tmpl` | Installs Python, npm, and Cargo packages. |
| `run_onchange_after_40-standalone-tools.sh.tmpl` | Installs selected Linux tools from GitHub release archives. |
| `run_once_after_50-post-install.sh.tmpl` | Performs one-time post-install setup such as shell plugins, nanorc, and compatibility links. |
| `run_onchange_after_60-security-material.sh.tmpl` | Reconciles secret-backed SSH key material when the 1Password provider is enabled. |
| `run_after_70-imperative-cli-tools.sh.tmpl` | Reconciles configured CLI plugins and extensions on every apply. |
| `run_once_after_90-monthly-maintenance.sh.tmpl` | Runs periodic maintenance for tools managed by `uv`. |

`run_once_` scripts are intended for one-time transitions, `run_onchange_`
scripts rerun when their rendered content changes, and `run_after_` scripts
run after the normal file and change-triggered work. The numeric phase creates
the dependency order: bootstrap and system packages come before runtimes,
language packages, security material, and post-apply integrations.

The [Package Installation Flow](./02-packages-installation-flow.md) explains
the system-package phase in detail. Shell-specific configuration is covered in
the [Shells](./03-shells.md) guide.

## `.chezmoitemplates/`: reusable script fragments

Lifecycle entrypoints include these fragments while Chezmoi renders them into
standalone Bash scripts.

| Template | Purpose |
| --- | --- |
| `scripts/core.bash` | Shared logging, failure reporting, command checks, temporary directories, and cleanup. |
| `scripts/language/packages.bash` | Installation helpers for `uv`, npm, and Cargo packages. |
| `scripts/language/runtimes.bash` | Download and installation helpers for `uv` and `mise` runtimes. |
| `scripts/standalone/github-release.bash` | GitHub API, release-asset selection, checksum verification, extraction, and installation helpers. |
| `scripts/system/apt.bash` | APT package checks, repository setup, installation, and removal. |
| `scripts/system/homebrew.bash` | Homebrew formula, cask, and Mac App Store installation behavior. |
| `scripts/system/paru.bash` | Pacman/AUR package checks, installation, and removal through `paru`. |

Keeping these helpers separate lets each lifecycle entrypoint remain focused on
selecting data and invoking the appropriate platform or package workflow.

## `.chezmoiexternals/`: externally managed resources

External declarations are resolved by Chezmoi but are not copied from ordinary
source files in the repository.

| File | Purpose |
| --- | --- |
| `external-mac-apps.toml.tmpl` | Downloads configured graphical macOS applications into the external-app staging paths. |
| `miscellaneous.toml` | Fetches shared Git repositories such as Tmux Plugin Manager and Tmuxifier. |
| `my-project.toml.tmpl` | Fetches private project and document repositories when the required identity and SSH key are available. |

## Target configuration tree

The target portion of `chezmoi/` is grouped by the configuration it installs:

- `dot_config/` contains application configuration, including Fish, Zsh,
  editors, terminals, window managers, Git, Jujutsu, and CLI tools.
- `dot_agents/`, `dot_codex/`, `dot_grok/`, and `dot_pi/` contain AI-agent
  instructions, settings, and prompts.
- `dot_proto/` contains Proto's toolchain configuration.
- `dot_ssh/` contains the managed SSH configuration.
- `dot_bashrc`, `dot_profile`, and `dot_zshenv` provide shell entrypoints;
  `empty_dot_zprofile` and `empty_dot_zshrc` intentionally create empty
  compatibility files.
- `dot_config/zsh-abbr/` stores Zsh abbreviation data.
- `bin/` contains executable personal helper commands.
- `private_Library/` and `private_dot_opencommit.tmpl` contain private or
  platform-specific targets.

For the loading order and module conventions inside Fish and Zsh, see the
[Shells](./03-shells.md) guide. For shared CLI integrations across both shells,
see [CLI Integrations](./06-cli-integrations.md).

## Rendering and apply flow

```text
ChezMoi data and machine prompts
            │
            ▼
   .tmpl files and reusable templates
            │
            ▼
 rendered target files and lifecycle scripts
            │
            ▼
       chezmoi apply
            │
            ▼
 files, directories, external resources, and packages in $HOME
```

Use `chezmoi data` or `chezmoi execute-template` to inspect the values selected
for the current machine. Use a dry run to inspect target changes before
applying them:

```bash
chezmoi data
chezmoi execute-template '{{ .features | toJson }}'
chezmoi apply --dry-run --verbose
```

## Related documentation

- [Package Installation Flow](./02-packages-installation-flow.md) — platform
  package managers and idempotent installation behavior.
- [Shells](./03-shells.md) — Zsh and Fish directory layout and loading rules.
- [Remote Server Flow](./04-remote-server-flow.md) — server-oriented data and
  initialization behavior.
- [Server Initialization](./05-server-initialization.md) — server migration and
  exceptional initialization paths.
- [CLI Integrations](./06-cli-integrations.md) — shared command integrations in
  Fish and Zsh.
- [Security Review](./security-review.md) — security-sensitive files and flows.

For repository-level validation, run:

```bash
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```
