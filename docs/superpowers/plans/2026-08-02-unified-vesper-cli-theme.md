# Unified Vesper CLI Theme Implementation Plan

## Objective

Implement the approved Vesper theme across the non-editor CLI tools in the repository, with `UNIFIED_THEME_CLI=vesper` as the default selector and existing per-tool themes preserved as the fallback.

## Phase 1: Shared selector and palette

1. Add `UNIFIED_THEME_CLI = "vesper"` to `.chezmoidata/shell_env.toml` under `[shell_env.common]`.
2. Export the value from the existing zsh and fish common environment templates.
3. Add a small reusable Chezmoi template/data source for the Vesper semantic palette so adapters do not invent divergent colors.
4. In every conditional config template, resolve the selector with `env "UNIFIED_THEME_CLI"`, falling back to the repository data default for the initial apply. Only the supported value `vesper` selects the new adapter; other values preserve the local configuration value.

## Phase 2: Terminal and display tools

1. Add `ghostty/themes/vesper` using the approved background, foreground, selection, cursor, and ANSI adapter colors; update `ghostty/config.tmpl` to select it for Vesper and retain `oldworld-vibrant` otherwise.
2. Add `wezterm/themes/vesper.lua`; update `wezterm.lua.tmpl` to select the file and use matching Vesper tab colors while retaining the current tab behavior and fallback scheme.
3. Convert `hunk/config.toml` to a template. Use Hunk's custom-theme fields for Vesper and retain `vitesse-black` when the selector is not Vesper.
4. Convert `bottom/bottom.toml` to a template. Keep `theme = "gruvbox"` in the fallback branch and add explicit Vesper styles for widgets, tables, graphs, CPU, memory, network, and battery in the Vesper branch.
5. Add a native `btop/themes/vesper.theme` and template `btop/btop.conf` so `color_theme` selects Vesper while preserving the current/default theme otherwise.

## Phase 3: Listing, preview, and file-management tools

1. Add `bat/themes/Vesper.tmTheme` with Vesper syntax scopes. Add a change-triggered Chezmoi script that runs `bat cache --build` only when Bat is installed.
2. Add `eza/theme.yml.tmpl` using the native eza theme schema. Keep a local/default theme mapping in the non-Vesper branch and document the XDG/eza config-directory behavior.
3. Convert `lla/config.toml` to a template and add `lla/themes/vesper.toml`; select the custom theme only for Vesper and retain its current `vesper`/local value otherwise.
4. Convert `yazi/theme.toml` to a template. Add `yazi/flavors/vesper.yazi/flavor.toml` and `tmtheme.xml`, then select `vesper` only in the Vesper branch while retaining `lain` as fallback.
5. Convert `superfile/config.toml` to a template and add `superfile/theme/vesper.toml` using the documented native theme keys. Keep `gruvbox` as fallback.
6. Verify the installed leaf configuration format and path, then add a Vesper custom theme file that inherits from a built-in theme. Template the leaf config so the Vesper path is selected only for the Vesper selector.

## Phase 4: Agent, prompt, and diff tools

1. Add `dot_pi/agent/themes/vesper.json` using pi's theme schema and Vesper semantic/token colors.
2. Convert `dot_pi/agent/settings.json` to a template and select `vesper` for the Vesper selector while retaining `catppuccin-mocha` otherwise.
3. Convert `starship/starship.toml` to a template. Add a Vesper palette and explicit styles for prompt, git, directory, duration, status, and error/success states; leave existing named-color styles in the fallback branch.
4. Add a Vesper delta feature/theme in the Git config template. Select Vesper syntax and diff styles conditionally while preserving `DarkNeon` and the existing plus/minus styles as fallback.

## Phase 5: Tests and verification

1. Run Chezmoi dry-runs with the repository default and with `UNIFIED_THEME_CLI=vesper` explicitly set.
2. Render with the selector unset/unsupported and verify fallback values such as `oldworld-vibrant`, `vitesse-black`, `gruvbox`, `catppuccin-mocha`, and `lain` remain present.
3. Validate TOML with `taplo` where schemas/formats are supported; validate JSON with an available JSON parser; validate YAML and Lua with available tooling.
4. Run native config/theme listing commands when installed: `bat --list-themes`, `delta --show-themes`, `lla theme`, and relevant btop/superfile/yazi checks.
5. Confirm the Bat cache script is idempotent and skips cleanly when Bat is absent.
6. Inspect the complete JJ diff and status, then commit the implementation with Jujutsu.

## Expected files

The implementation is expected to add or modify only Chezmoi source files under `chezmoi/` plus the committed plan/spec documentation. No Neovim, Helix, Zed, or other editor theme files will be changed.

## Risks and mitigations

- CLI theme schemas differ significantly; validate every adapter against the tool's native documentation and available binary before relying on it.
- Chezmoi's `env` reads the environment of the rendering process; the `.chezmoidata` default is needed so the first apply works before a newly generated shell environment is reloaded.
- Bat and delta depend on the Bat theme cache; make cache refresh conditional and idempotent.
- Some tools may not be installed in the current environment; still validate syntax statically and report unavailable runtime checks explicitly.
