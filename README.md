# My Dotfiles

This repository contains my personal dotfiles and configuration files, managed using [Chezmoi](https://www.twpayne.com/chezmoi/), a tool for managing dotfiles across multiple machines.

## Features
- Shell configurations for zsh and fish
- Terminal setups (kitty, wezterm, ghostty)
- Editor configs (nvim)
- System tools (tmux, starship, etc.)
- Platform-specific setups for macOS and Linux

## Installation
To use this repo on a new machine:

1. **Install Chezmoi**:
   Follow the [official installation guide](https://www.twpayne.com/chezmoi/getting-started.html). For example, on macOS with Homebrew:
   ```
   brew install chezmoi
   ```

2. **Initialize Chezmoi**:
   Use Chezmoi's native initialization flow:
   ```
   chezmoi init --apply https://github.com/chianyungcode/dotfiles.git
   ```

   During initialization, choose an identity profile, machine role, capabilities,
   secrets provider, and whether Age-encrypted files should be enabled. A
   secretless Ubuntu server can use the defaults `server`, `none`, and `false`
   without `op` or an Age identity.

3. **Apply Configurations**:
   Run `chezmoi apply` to apply all dotfiles to your home directory.

4. **Inspect Configuration**:
   ```
   chezmoi data
   chezmoi execute-template '{{ .identity | toJson }}'
   chezmoi execute-template '{{ .features | toJson }}'
   chezmoi execute-template '{{ .secrets | toJson }}'
   chezmoi execute-template '{{ .xdg | toJson }}'
   chezmoi apply --dry-run --verbose
   ```

5. **Post-Installation**:
   - Install optional packages through the capability selections made during initialization.
   - Enable `onepassword` or Age-encrypted files later by updating Chezmoi's configuration and applying again.
   - Add optional tools such as `difft` through a machine-local Chezmoi config after installing them.

### Validate a configuration change

Run the local render matrix before applying changes to a real home directory:

```bash
./tests/chezmoi-render-config.sh
```

The matrix renders secretless server and development data, a graphical
workstation, CI-derived ignores, and custom XDG paths into temporary
destinations. It does not install packages or require `op` credentials.

## Usage
- **Edit Files**: Modify files in `~/.local/share/chezmoi/` and run `chezmoi apply` to update symlinks.
- **Add New Files**: Use `chezmoi add ~/.somefile` to track new dotfiles.
- **Templates**: Files ending in `.tmpl` use Go templates for dynamic content (e.g., paths, secrets).
- **Platform-Specific**: Check `.chezmoidata/` for shared package and account data; OS detection uses Chezmoi's built-in `.chezmoi` data.

## Scripts
- Pre- and post-apply scripts in `.chezmoiscripts/` automate installations (e.g., packages, symlinks).
- Run `chezmoi apply --verbose` for detailed output.

## Contributing
Fork the repo, make changes, and submit a pull request. Ensure compatibility across platforms.

For more details, see the [docs/](./docs/) directory, including macOS-specific setup in `readme-macos.md`.

## License
MIT License - see [LICENSE](LICENSE) file if present.
