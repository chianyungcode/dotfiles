# My Dotfiles

This repository contains my personal dotfiles and configuration files, managed
using [Chezmoi](https://www.twpayne.com/chezmoi/), a tool for managing dotfiles
across multiple machines.

## Features

- Shell configurations for zsh and fish
- Terminal setups (kitty, wezterm, ghostty)
- Editor configs (nvim)
- System tools (tmux, starship, etc.)
- Platform-specific setups for macOS and Linux

## Installation

To use this repo on a new machine:

1. **Install prerequisites**: Make sure `curl` and `git` are available. Their
   availability depends on the distribution and installation image; on Ubuntu
   you can install them with:

   ```bash
   sudo apt update
   sudo apt install -y curl git
   ```

2. **Install and initialize Chezmoi**: Run:

   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply chianyungcode
   ```

   This installs Chezmoi if needed, initializes the repository, and applies the
   configuration. Initialization asks for the machine role first.

   - A `server` automatically uses the local-only `server-minimal` identity,
     disables personal and graphical features, uses no secrets provider, and
     disables Age-encrypted files. Only development and homelab capabilities are
     prompted.
   - A `workstation` prompts for its identity profile, capabilities, secrets
     provider, and Age-encrypted files.

   The server path does not require `op` or an Age identity. See
   [Server Initialization](./docs/05-server-initialization.md) for migration,
   exceptional overrides, and emergency local commits.

3. **Inspect Configuration**:

   ```bash
   chezmoi data
   chezmoi execute-template '{{ .identity | toJson }}'
   chezmoi execute-template '{{ .features | toJson }}'
   chezmoi execute-template '{{ .secrets | toJson }}'
   chezmoi execute-template '{{ .xdg | toJson }}'
   chezmoi apply --dry-run --verbose
   ```

4. **Post-Installation**:
   - Install optional packages through the capability selections made during
     initialization.
   - Workstations can change their secrets provider or Age-encrypted file policy
     by updating Chezmoi's configuration and applying again. Server
     reinitialization restores both settings to their secretless defaults.
   - Workstations enable the configured `delta`/`difft` experience; server roles
     use built-in Git and Jujutsu diffs.

### Validate a configuration change

Run the local render matrix before applying changes to a real home directory:

```bash
./tests/chezmoi-render-config.sh
```

The matrix renders secretless server and development data, a graphical
workstation, CI-derived ignores, and custom XDG paths into temporary
destinations. It does not install packages or require `op` credentials.

## Usage

- **Edit Files**: Modify files in `~/.local/share/chezmoi/` and run
  `chezmoi apply` to update symlinks.
- **Add New Files**: Use `chezmoi add ~/.somefile` to track new dotfiles.
- **Templates**: Files ending in `.tmpl` use Go templates for dynamic content
  (e.g., paths, secrets).
- **Platform-Specific**: Check `.chezmoidata/` for shared package and account
  data; OS detection uses Chezmoi's built-in `.chezmoi` data.

## Scripts

Chezmoi automation uses three layers:

- `.chezmoidata` declares system, language, and standalone packages.
- `.chezmoitemplates/scripts` contains focused platform implementation
  fragments.
- `.chezmoiscripts` contains eight ordered execution phases from bootstrap
  through monthly maintenance.

Run `chezmoi apply --dry-run --verbose` to inspect rendered phases before the
first apply on a machine.

## Contributing

Fork the repo, make changes, and submit a pull request. Ensure compatibility
across platforms.

For more details, see the [docs/](./docs/) directory, including macOS-specific
setup in `readme-macos.md`.

## License

MIT License - see [LICENSE](LICENSE) file if present.
