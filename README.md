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

2. **Clone the Repository**:
   Initialize Chezmoi with this repo (replace `username` with the actual GitHub username if public):
   ```
   chezmoi init --apply https://github.com/username/dotfiles.git
   ```
   Or manually clone:
   ```
   git clone https://github.com/username/dotfiles.git ~/.local/share/chezmoi
   chezmoi apply
   ```

3. **Apply Configurations**:
   Run `chezmoi apply` to symlink all dotfiles to your home directory. This will set up your environment.

4. **Post-Installation**:
   - Install required packages via the provided scripts (e.g., `run_onchange` scripts in `.chezmoiscripts/`).
   - For macOS, run Homebrew and MAS installations as per `run_onchange_before_10-homebrew-packages.sh.tmpl`.
   - Customize private files (e.g., API keys) using Chezmoi's templates.

## Usage
- **Edit Files**: Modify files in `~/.local/share/chezmoi/` and run `chezmoi apply` to update symlinks.
- **Add New Files**: Use `chezmoi add ~/.somefile` to track new dotfiles.
- **Templates**: Files ending in `.tmpl` use Go templates for dynamic content (e.g., paths, secrets).
- **Platform-Specific**: Check `.chezmoidata/` for OS-specific configs (macOS, Linux).

## Scripts
- Pre- and post-apply scripts in `.chezmoiscripts/` automate installations (e.g., packages, symlinks).
- Run `chezmoi apply --verbose` for detailed output.

## Contributing
Fork the repo, make changes, and submit a pull request. Ensure compatibility across platforms.

For more details, see the [docs/](./docs/) directory, including macOS-specific setup in `readme-macos.md`.

## License
MIT License - see [LICENSE](LICENSE) file if present.