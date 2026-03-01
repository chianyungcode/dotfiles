# ZSH Configuration Documentation

This document describes the active ZSH configuration managed by chezmoi in:

- `chezmoi/dot_config/zsh/`

It replaces older references to `zsh-source/`.

## Directory Structure

```text
chezmoi/dot_config/zsh/
├── dot_zshenv.tmpl
├── dot_zshrc.tmpl
├── env.d/
│   ├── 000-xdg.sh.tmpl
│   ├── 010-homebrew.sh.tmpl
│   ├── 020-common.sh.tmpl
│   ├── private_030-secrets.sh.tmpl
│   ├── encrypted_private_030-secrets-age.sh
│   └── 040-path.sh.tmpl
├── conf.d/
│   ├── 001-bind-keys.zsh
│   ├── 002-options.bash
│   ├── 002-options.zsh.tmpl
│   ├── 003-zsh-mode.zsh.tmpl
│   ├── 004-plugin-manager.zsh.tmpl
│   ├── 020-alerting.sh
│   ├── 020-colors.sh.tmpl
│   ├── 060-common-aliases.sh.tmpl
│   ├── 060-common-functions.sh.tmpl
│   ├── 070-better-defaults.sh.tmpl
│   ├── 080-linux.sh.tmpl
│   ├── 080-macos.sh.tmpl
│   ├── 090-personal.sh.tmpl
│   └── third-party/
└── completions/
```

## Loading Flow

1. `dot_zshenv.tmpl` loads every readable `*.zsh` and `*.sh` file from `env.d/`.
2. `dot_zshrc.tmpl` loads interactive configuration from `conf.d/`.
3. Files are designed to run in lexical order (numeric prefixes).

## env.d Modules

### `000-xdg.sh.tmpl`

Sets XDG base directories and XDG user directories:

- `XDG_DATA_HOME`, `XDG_CONFIG_HOME`, `XDG_STATE_HOME`, `XDG_CACHE_HOME`
- `XDG_DATA_DIRS` (ensures `$XDG_DATA_HOME` is included)
- `XDG_*_DIR` values via `xdg-user-dir` (if available)

### `010-homebrew.sh.tmpl`

macOS-only Homebrew environment setup:

- `HOMEBREW_PREFIX`, `HOMEBREW_CELLAR`, `HOMEBREW_REPOSITORY`
- ensures `/opt/homebrew/bin` and `/opt/homebrew/sbin` are in `PATH`
- updates `MANPATH` and `INFOPATH`

### `020-common.sh.tmpl`

Shared non-secret environment variables:

- editor/tool vars (`EDITOR`, `DOTFILES`, `LM_STUDIO_BIN`, `TMUXIFIER_LAYOUT_PATH`)
- config/data paths (`GIT_CONFIG_GLOBAL`, `PROTO_HOME`, `STARSHIP_CONFIG`, `_ZO_DATA_DIR`, etc.)
- platform-specific vars (e.g. Arch `TERMINFO*`, macOS `DISABLE_AUTO_TITLE`)
- state vars (`LESSHISTFILE`, `PYTHON_HISTORY`)
- `SSH_AUTH_SOCK` defaults when not in SSH TTY

### `private_030-secrets.sh.tmpl` / `encrypted_private_030-secrets-age.sh`

Secret environment variables (optional, gated by `.use_secrets`):

- `CONTEXT7_MCP_API_KEY`
- `GITHUB_TOKEN`
- `OPENROUTER_OPENCODE_APIKEY`
- `WAKATIME_API_KEY`

### `040-path.sh.tmpl`

Builds `PATH` from an ordered list of common/tooling directories and prepends only existing, non-duplicate entries.

## conf.d Modules

`conf.d/` contains interactive shell behavior and tooling integrations:

- keybindings, shell options, plugin manager, aliases, functions
- OS-specific modules (`080-linux`, `080-macos`)
- third-party integration scripts in `conf.d/third-party/`

## Notes

- Keep environment variables in `env.d/` (loaded by `.zshenv`).
- Keep interactive behavior in `conf.d/` (loaded by `.zshrc`).
- Keep numeric prefixes to preserve deterministic load order.
