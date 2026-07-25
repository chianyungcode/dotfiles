# Homebrew Packages Installation Flow

This document describes how Homebrew formulae and casks are managed through
Chezmoi's templating system.

## Overview

The system-package phase renders the Homebrew fragment only on macOS. It reads
the package declarations, filters them by the selected feature gates, and
installs missing formulae, casks, and supported Mac App Store applications.

## Package Definition

Homebrew packages are configured in
[`.chezmoidata/packages-system.toml`](../chezmoi/.chezmoidata/packages-system.toml).
The feature tables use these gates:

- `development`: development-focused packages;
- `personal`: personal-use packages; and
- `homelab`: homelab-specific tools.

Example configuration:

```toml
[packages]
  [packages.homebrew]
    [packages.homebrew.development]
    taps = ["homebrew/bundle"]
    casks = ["1password-cli", "cursor", "ghostty"]
    formulae = ["git", "neovim", "fish", "gh", "act", "direnv"]

    [packages.homebrew.personal]
    casks = ["arc", "raycast", "obsidian"]
    formulae = ["qmk/qmk/qmk"]
```

The `graphical` feature also gates casks. The current data file includes
separate `development`, `personal`, `homelab`, and `graphical` tables where
applicable.

## Installation Script

[`run_onchange_before_10-system-packages.sh.tmpl`](../chezmoi/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl)
renders the Homebrew fragment on macOS. The fragment updates Homebrew, removes
configured formulae, and then processes each configured formula and cask.

For every formula, `brew list --formula` determines whether installation is
already satisfied. For every cask, `brew list --cask` first determines whether
Homebrew already manages it.

## Cask Skip Behavior

If Homebrew does not already manage a cask, the fragment derives its expected
application name. It then checks both `/Applications` and
`/Applications/Setapp` before installing.

```bash
brew list --cask "$cask" >/dev/null 2>&1 && continue
app_name=$(homebrew_app_name "$cask")
if [[ -d "/Applications/$app_name.app" ||
    -d "/Applications/Setapp/$app_name.app" ]]; then
    notice "Skipping $cask because $app_name.app already exists"
    continue
fi
brew install --cask "$cask"
```

The notice means that a matching application bundle already exists outside the
current Homebrew cask record. This avoids a duplicate installation while making
the skipped package visible in Chezmoi output.

## Best Practices

- Prefer Homebrew installs for consistent updates and removal.
- Review a skipped cask if its existing application has a different source or
  version than the desired Homebrew cask.
- Run `chezmoi apply --dry-run --verbose` before applying a package-data
  change on a machine.
