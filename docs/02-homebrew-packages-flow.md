# Homebrew Packages Installation Flow

This document describes how Homebrew packages (formulae and casks) are managed through chezmoi's templating system.

## Overview

The Homebrew package installation process follows a two-step approach:

1. **Package Definition**: Packages are defined in `.chezmoidata/packages.toml` with optional filtering based on system roles
2. **Installation Execution**: A shell script template installs the defined packages while handling edge cases

## Package Definition

Packages are configured in [`.chezmoidata/packages.toml`](chezmoi/.chezmoidata/packages.toml) with support for conditional installation based on:

- `dev_computer`: Development-focused packages
- `personal_computer`: Personal use packages
- `homelab_member`: Homelab-specific tools

Example configuration:

```toml
[packages]
  [packages.homebrew]
    [packages.homebrew.common]
    taps = ["homebrew/bundle"]
    casks = ["1password", "ghostty"]
    formulae = ["git", "neovim", "fish"]

    [packages.homebrew.dev_computer]
    casks = ["cursor", "datagrip"]
    formulae = ["gh", "act", "direnv"]

    [packages.homebrew.personal_computer]
    casks = ["arc", "raycast", "obsidian"]
    formulae = ["qmk/qmk/qmk"]
```

## Installation Script

The installation is handled by [`run_onchange_before_10-homebrew-packages.sh.tmpl`](chezmoi/.chezmoiscripts/run_onchange_before_10-homebrew-packages.sh.tmpl), which:

1. Reads package definitions from `.chezmoidata/packages.toml`
2. Installs formulae and casks based on system role filters
3. Handles pre-existing applications gracefully

## Skip Notification Behavior

### When the Notice Appears

The script displays a notice message: `"Skipping ${cask} - already exists in /Applications"` **only** when both conditions are met:

1. **The cask is NOT installed via Homebrew** (not in `currently_installed_casks`)
2. **The application already exists in `/Applications`** (installed manually via DMG or other methods)

### Logic Flow

```bash
if ! _inArray_ -i "${cask}" "${currently_installed_casks[@]}"; then
    # Condition: Cask is not managed by Homebrew

    if [[ ! -d "/Applications/${app_name}.app" ]]; then
        # Application doesn't exist → Install via Homebrew
        brew install -q --cask ${cask}
    else
        # Application exists → Show skip notice
        notice "Skipping ${cask} - already exists in /Applications"
    fi
fi
```

### Behavior Scenarios

| Scenario             | Homebrew Status | App in /Applications | Result                       |
| -------------------- | --------------- | -------------------- | ---------------------------- |
| **Manual Install**   | Not installed   | ✅ Exists            | **Notice displayed**         |
| **Homebrew Install** | ✅ Installed    | May or may not exist | No notice (skipped entirely) |
| **Fresh Install**    | Not installed   | ❌ Doesn't exist     | Install via Homebrew         |

### Key Insight

The notice serves as a **helpful indicator** that an application was installed manually rather than through Homebrew, preventing duplicate installations while informing the user about potential version/source mismatches.

## Best Practices

- **Manual installations**: Consider uninstalling and reinstalling via Homebrew for better version management
- **Version conflicts**: The notice helps identify when you might have different versions (manual vs Homebrew)
- **Clean setup**: For new systems, prefer Homebrew installations for consistent package management
