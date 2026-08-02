# Unified CLI Theme

## Purpose

This repository keeps the appearance of supported command-line tools aligned
through one Chezmoi theme selector. The current unified theme is
`kanagawa-dragon`.

Text editors such as Neovim, Helix, and Zed are intentionally outside this
configuration layer.

## Source of truth

The shared theme contract is defined in Chezmoi data files:

- [`chezmoi/.chezmoidata/shell_env.toml`](../chezmoi/.chezmoidata/shell_env.toml)
  defines the default selector:

  ```toml
  [shell_env.common]
  UNIFIED_THEME_CLI = "kanagawa-dragon"
  ```

- [`chezmoi/.chezmoidata/constants.toml`](../chezmoi/.chezmoidata/constants.toml)
  defines the semantic Kanagawa Dragon palette under
  `[theme.kanagawa_dragon]`.

The palette is the source of truth for shared roles such as background,
foreground, border, selection, accent, success, warning, and error colors.
Individual CLI theme files adapt those semantic roles to each program's native
format.

## Selector resolution

Every conditional Chezmoi template resolves the selector in this order:

1. A non-empty `UNIFIED_THEME_CLI` environment variable supplied to Chezmoi.
2. `shell_env.common.UNIFIED_THEME_CLI` from `.chezmoidata`.
3. The CLI's existing local fallback when the selector is unsupported.

For example, this makes it possible to preview another selector without
changing the repository default:

```bash
UNIFIED_THEME_CLI=kanagawa-dragon \
  chezmoi -S /Users/chianyung/.local/share/chezmoi.unified-theme-clis/chezmoi apply
```

When this repository is not the configured Chezmoi source directory, always
pass it with `-S`. A path after `chezmoi apply` is interpreted as a target path,
not as a source directory.

## Per-CLI theme ownership

There is no universal generated theme file. Each CLI owns a custom theme in its
native format and its own Chezmoi configuration loads that theme.

<!-- markdownlint-disable MD013 -->

| CLI | Custom theme or native section | Loaded by |
| --- | --- | --- |
| Ghostty | `dot_config/ghostty/themes/kanagawa-dragon` | `ghostty/config.tmpl` via `theme = kanagawa-dragon` |
| WezTerm | `dot_config/wezterm/themes/kanagawa-dragon.lua` | `wezterm.lua.tmpl` via `dofile(...)` |
| Hunk | `custom_theme` in `dot_config/hunk/config.toml.tmpl` | Hunk's `theme = "custom"` setting |
| Bottom | Kanagawa Dragon `[styles]` sections in `dot_config/bottom/bottom.toml.tmpl` | Bottom's native styles configuration |
| btop | `dot_config/btop/themes/kanagawa-dragon.theme` | `btop.conf.tmpl` via `color_theme` |
| Bat | `dot_config/bat/themes/kanagawa-dragon.tmTheme` | Fish/Zsh `BAT_THEME=kanagawa-dragon` |
| eza | `dot_config/eza/theme.yml.tmpl` | eza's native theme file |
| lla | `dot_config/lla/themes/kanagawa-dragon.toml` | `lla/config.toml.tmpl` via `theme` |
| Yazi | `dot_config/yazi/flavors/kanagawa-dragon.yazi/` | `yazi/theme.toml.tmpl` via the dark flavor |
| Superfile | `dot_config/superfile/theme/kanagawa-dragon.toml` | `superfile/config.toml.tmpl` via `theme` |
| Leaf | `dot_config/leaf/kanagawa-dragon.toml` | `leaf/config.toml.tmpl` via `theme` |
| Pi | `dot_pi/agent/themes/kanagawa-dragon.json` | `dot_pi/agent/settings.json.tmpl` via `theme` |
| Starship | `palettes."kanagawa-dragon"` in `dot_config/starship/starship.toml.tmpl` | Starship's `palette` setting |
| Git-Delta | `[delta "kanagawa-dragon"]` in `dot_config/git/config.tmpl` | Git's Delta `features` setting |
| Herdr | `[theme.custom]` in `dot_config/herdr/config.toml.tmpl` | Herdr's `name = "custom"` setting |

<!-- markdownlint-enable MD013 -->

The Herdr `custom` name is an exception to the kebab-case theme identifier
rule because Herdr requires the literal `custom` selector for an inline custom
palette.

## Bat cache lifecycle

Bat compiles `.tmTheme` files into a cache. The
[`run_onchange_after_75-bat-theme-cache.sh.tmpl`](../chezmoi/.chezmoiscripts/run_onchange_after_75-bat-theme-cache.sh.tmpl)
script includes a fingerprint of the Kanagawa Dragon theme asset. When that
asset changes, Chezmoi reruns the script and executes:

```bash
bat cache --build
```

This keeps the native Bat theme name available to both Bat and Git-Delta.

## Adding another unified theme

1. Add a new semantic palette to `chezmoi/.chezmoidata/constants.toml`.
2. Change or select the default in `chezmoi/.chezmoidata/shell_env.toml`.
3. Add one native theme asset or native theme section per supported CLI.
4. Update each CLI's `.tmpl` configuration to select and load its own asset.
5. Preserve the existing local fallback for unsupported selectors.
6. Extend `tests/unified-kanagawa-theme.sh` with asset, selector, and render
   assertions.
7. Run the Chezmoi render and native-format validation tests before committing.
