# Package Installation Flow

This document describes how package declarations are selected and installed by
Chezmoi across the supported operating systems.

## Supported platforms

The system-package phase selects one package manager based on the operating
system:

| Platform | Package manager | Data section | Package types |
| --- | --- | --- | --- |
| macOS | Homebrew | `packages.homebrew` | Formulae, casks, and Mac App Store apps |
| Ubuntu/Debian | APT | `packages.apt` | Distribution packages |
| Arch Linux | `paru` with Pacman/AUR | `packages.pacman` | Repository and AUR packages |

Other platforms stop with an unsupported-platform error rather than running a
different package manager implicitly.

## Package definitions

Package declarations live in
[`.chezmoidata/packages-system.toml`](../chezmoi/.chezmoidata/packages-system.toml).
Each supported package manager has these feature groups where applicable:

- `common`: always installed;
- `development`: installed when the development feature is enabled;
- `personal`: installed when the personal feature is enabled; and
- `homelab`: installed when the homelab feature is enabled.

Homebrew also has a `graphical` group for graphical packages. The `graphical`
feature gates Homebrew casks and Mac App Store applications. Ubuntu/Debian and
Arch currently keep their package lists in the non-graphical groups.

The data shape is platform-specific, but follows the same pattern:

```toml
[packages.apt.common]
packages = ["curl", "git", "zsh"]

[packages.pacman.development]
packages = ["fd", "fzf", "neovim"]

[packages.homebrew.development]
formulae = ["git", "neovim", "fish"]
casks = ["ghostty"]
```

Each manager can also define a `to_remove` list for packages that should no
longer be present. The Homebrew data also contains Mac App Store entries under
`packages.mas`.

## Installation lifecycle

### 1. Bootstrap prerequisites

[`run_once_before_00-bootstrap.sh.tmpl`](../chezmoi/.chezmoiscripts/run_once_before_00-bootstrap.sh.tmpl)
prepares the platform before package installation:

- macOS installs Homebrew when `brew` is missing and makes it available in the
  current shell;
- Ubuntu/Debian installs missing `curl`, `unzip`, and `wget` with APT; and
- Arch installs the same prerequisites with Pacman and builds `paru` from the
  AUR when it is missing. Building `paru` also requires `git` and `base-devel`.

The initial Chezmoi bootstrap command still needs `curl` and `git` before this
script can run. See the prerequisites in the main [README](../README.md).

### 2. Render and run the package phase

[`run_onchange_before_10-system-packages.sh.tmpl`](../chezmoi/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl)
renders only the platform-specific package fragment and runs its installer.
The selected feature gates are evaluated while the template is rendered, so
the generated script contains only the packages relevant to that machine.

### 3. Keep the result idempotent

Installers check whether each package is already present before installing it.
They also remove configured packages from their platform's `to_remove` list.
Package updates are deliberately limited: Homebrew does not upgrade existing
formulae, while APT and `paru` use their package-manager-specific install
options without forcing upgrades of already-installed packages.

## macOS: Homebrew

The Homebrew fragment is defined in
[`homebrew.bash`](../chezmoi/.chezmoitemplates/scripts/system/homebrew.bash).
It:

- runs `brew update`;
- removes formulae listed in `packages.homebrew.to_remove`;
- installs missing formulae and casks;
- skips a cask when its application bundle already exists in `/Applications` or
  `/Applications/Setapp`; and
- installs configured Mac App Store applications with `mas` when graphical
  installation is enabled.

Homebrew formulae are checked with `brew list --formula`, and casks are checked
with `brew list --cask`. Casks and Mac App Store applications are skipped when
`CI` is set, while formulae are still processed.

When a cask is not managed by Homebrew, the script derives its expected
application name before checking for an existing application:

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

## Ubuntu/Debian: APT

The APT fragment is defined in
[`apt.bash`](../chezmoi/.chezmoitemplates/scripts/system/apt.bash). It:

- refreshes APT metadata with `apt-get update`;
- ensures `gpg` is available;
- configures the external repository used by `eza` when needed;
- removes installed packages listed in `packages.apt.to_remove`;
- verifies each requested package is available with `apt-cache show`; and
- installs missing packages with `apt-get install --no-upgrade`.

The package lists include `curl` and `git` as common packages, but those are
still prerequisites for the first Chezmoi bootstrap command and must be
available before the package phase can install them.

## Arch Linux: `paru` and Pacman/AUR

The Arch fragment is defined in
[`paru.bash`](../chezmoi/.chezmoitemplates/scripts/system/paru.bash). Although
the data section is named `packages.pacman`, the installer requires `paru` so
that both repository packages and AUR packages can be declared.

For each package, it:

- removes installed packages listed in `packages.pacman.to_remove` with
  `paru -R`;
- checks the local Pacman database with `pacman -Q`;
- verifies availability with `paru -Si`; and
- installs missing packages with `paru -S --needed` without prompting for
  confirmation or an AUR review.

## Applying package changes

After changing [`packages-system.toml`](../chezmoi/.chezmoidata/packages-system.toml),
inspect the rendered result before applying it to a real machine:

```bash
chezmoi apply --dry-run --verbose
```

The repository's render test also checks the generated package scripts:

```bash
./tests/chezmoi-render-scripts.sh
```
