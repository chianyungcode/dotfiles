# Unified Vesper CLI Theme Design

## Goal

Provide a consistent Vesper-inspired appearance across the configured command-line tools while preserving each tool's existing local theme when the unified theme selector is disabled.

Text editors are explicitly out of scope for this iteration: Neovim, Helix, Zed, and other editor-specific themes will not be changed.

## Scope

The first implementation covers:

- Ghostty and WezTerm
- hunk
- bat and git-delta
- eza and lla
- pi
- bottom and btop
- yazi and superfile
- starship
- leaf

Each tool will receive a native configuration/theme asset in the directory it normally reads through XDG configuration paths. Existing repository conventions and platform-specific Chezmoi templates remain authoritative.

## Palette

The palette is based on the upstream Vesper VS Code theme:

```text
background       #101010
surface          #161616
input            #1C1C1C
selection        #232323
border           #282828
scrollbar       #343434
foreground       #FFFFFF
muted            #A0A0A0
dim              #7E7E7E
faint            #505050
orange           #FFC799
orange-bright    #FFCFA8
mint             #99FFE4
error            #FF8080
warning          #FF7300
separator        #65737E
```

The source palette is the upstream `Vesper-dark-color-theme.json`. Terminal-specific ANSI slots are adapters derived from these semantic colors; Vesper does not provide one universal ANSI mapping for every terminal emulator.

## Theme selection

Add the following default selector to `chezmoi/.chezmoidata/shell_env.toml`:

```toml
[shell_env.common]
UNIFIED_THEME_CLI = "vesper"
```

The shell environment templates will export the selector. CLI configuration templates will read the process environment with Chezmoi's Go template `env` function. The effective selector follows this precedence:

1. A non-empty `UNIFIED_THEME_CLI` already present in the environment of the Chezmoi process.
2. The repository default from `.chezmoidata/shell_env.toml`, used as bootstrap behavior.
3. The existing per-CLI theme/key when no supported unified selector is active.

The first supported selector is `vesper`. Unsupported or empty selectors must not silently replace the existing local fallback.

Because exported shell variables become available to newly started shells, the implementation must also support the initial apply where the data-file default has not yet been exported by the current shell.

## Configuration strategy

Use native theme files plus small Chezmoi templates rather than generating all themes from a runtime script. Keep the shared palette centralized where practical, while allowing each CLI's native format and semantic color names to remain readable.

For regular configuration files that need conditional rendering, convert the Chezmoi source to a `.tmpl` file without changing its target path. For tools with a separate theme directory, add a Vesper theme asset and update the main config to select it conditionally.

Preserve current local fallback values, including existing themes such as `oldworld-vibrant`, `vitesse-black`, `gruvbox`, `catppuccin-mocha`, and the current yazi flavor. Do not make the fallback depend on the Vesper assets.

## Native adapters

- Ghostty: add a Vesper theme file and select it from the existing Ghostty template.
- WezTerm: add a Vesper Lua color scheme and select it from the existing template.
- hunk: add Vesper custom color fields while retaining the current built-in theme fallback.
- bat: add a Vesper TextMate theme under `bat/themes`; rebuild the Bat theme cache through a Chezmoi post-apply script when Bat is installed.
- git-delta: add a Vesper delta feature/theme and select it conditionally while preserving the existing syntax theme and diff styles as fallback.
- eza: add a native XDG `theme.yml` adapter with Vesper semantic colors and a local default fallback.
- lla: use its native theme location and preserve its current configured theme when the selector is not active.
- pi: add a native Vesper JSON theme and select it from the agent settings template.
- bottom: add explicit Vesper style sections and retain the current built-in theme when disabled.
- btop: add a native Vesper color theme and select it from the btop configuration.
- yazi: add a Vesper flavor/theme and select it conditionally while preserving the current flavor.
- superfile: add its native Vesper theme and select it from the main config.
- starship: add a Vesper palette and conditionally activate it without changing the existing style fallback.
- leaf: verify its supported config/theme path and format, then add the Vesper adapter with the same selector/fallback contract.

Exact paths and keys will be verified against each tool's current native documentation or installed configuration format before editing that tool.

## Validation

Validate the implementation with:

- Chezmoi template parsing and dry-run output with `UNIFIED_THEME_CLI=vesper`.
- Dry-run output with the selector unset, confirming existing fallback values remain.
- TOML, JSON, YAML, Lua, and shell syntax checks where the corresponding tools are available.
- Bat cache rebuild behavior when Bat is installed.
- Jujutsu status and diff inspection before committing.

## Version control

All repository history operations must use Jujutsu. The implementation will be recorded in a JJ change with a concise Conventional Commit-style description.
