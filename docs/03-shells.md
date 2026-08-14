# Shell Configuration

This repository configures both Zsh and Fish through Chezmoi. The two shells
use similar directory conventions, but each shell has its own startup and
module-loading rules.

## Shared layout

Shell configuration lives under `chezmoi/dot_config/`:

| Directory | Purpose |
| --- | --- |
| `env.d/` | Environment variables and path setup |
| `conf.d/` | Interactive shell behavior and integrations |
| `completions/` | Shell completion definitions |
| `functions/` | Fish functions and other autoloaded helpers |

Use numeric prefixes when one module must run before another. Keep environment
setup in `env.d/` and interactive behavior in `conf.d/`.

## Zsh

The main files are in
[`chezmoi/dot_config/zsh`](../chezmoi/dot_config/zsh):

- `dot_zshenv.tmpl` sources readable `env.d/*.zsh` and `env.d/*.sh` files in
  lexical order;
- `dot_zshrc.tmpl` exits for non-interactive shells, adds custom completions,
  and sources `conf.d/*.{zsh,sh}` plus one nested directory level; and
- `conf.d/third-party/` contains integrations for tools such as Atuin,
  Homebrew, Starship, and Zoxide.

Typical prefixes are `000`–`099` in `env.d/` and `001`–`090` in `conf.d/`.
The `ZSH_DEBUG` environment variable prints each configuration file as it is
loaded:

```bash
ZSH_DEBUG=1 zsh -ic exit
```

## Fish

The Fish configuration is in
[`chezmoi/dot_config/fish`](../chezmoi/dot_config/fish):

- `config.fish.tmpl` handles interactive initialization and creates Fish's XDG
  directories;
- Fish automatically loads `conf.d/*.fish` modules;
- `private_10_00-login_env.fish.tmpl` loads `env.d/*.fish` for login shells and
  adds platform-specific environment setup; and
- `completions/`, `functions/`, and `fish_plugins` provide completions,
  autoloaded functions, and Fisher's plugin list.

Fish modules use prefixes such as `00_`, `10_`, and `90_` when ordering matters.
The `private_` source prefix marks files that Chezmoi should install with
private permissions; template conditions can further control their contents.

## Validate shell changes

Check syntax and inspect the rendered configuration before applying changes:

```bash
zsh -n ~/.config/zsh/.zshenv
zsh -n ~/.config/zsh/.zshrc
fish -n ~/.config/fish/config.fish
chezmoi apply --dry-run --verbose
```

Keep shell-specific implementations in the corresponding Zsh or Fish module;
shared behavior should remain conceptually consistent without forcing one
shell to source the other's syntax.
