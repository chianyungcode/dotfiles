# Kanagawa Dragon Unified CLI Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Kanagawa Dragon as the default unified theme for the supported non-editor CLI tools, including a native custom Herdr theme when supported.

**Architecture:** Keep `UNIFIED_THEME_CLI` as the single selector, with the repository data value set to `kanagawa-dragon` and environment variables taking precedence during Chezmoi rendering. Add native theme assets beside each CLI's existing configuration and use small `.tmpl` selectors to retain each CLI's current fallback theme when the selector is unsupported. Herdr will use its documented `theme.name = "custom"` plus a complete `[theme.custom]` palette, avoiding overrides on a built-in theme.

**Tech Stack:** Chezmoi Go templates, TOML/YAML/JSON/Lua/XML/native CLI theme formats, Bash regression tests, Jujutsu.

## Global Constraints

- `UNIFIED_THEME_CLI` from the process environment takes precedence over `.chezmoidata/shell_env.toml`.
- The default selector is exactly `kanagawa-dragon`.
- Neovim, Helix, and Zed remain out of scope.
- Unsupported selectors preserve each CLI's current local fallback theme.
- Herdr must use a custom theme, not `[theme.custom]` overrides layered on a built-in theme.
- Use the Kanagawa palette from the upstream `rebelot/kanagawa.nvim` reference.
- Use Jujutsu for version control and commit each coherent task.

---

### Task 1: Add failing selector and asset regression coverage

**Files:**
- Create: `tests/unified-kanagawa-theme.sh`
- Modify: `tests/chezmoi-render-config.sh` only if the test suite has an explicit file list that needs the new test

**Interfaces:**
- Consumes: Chezmoi source tree and `chezmoi execute-template`.
- Produces: A regression test that fails until the default selector, Kanagawa assets, selector branches, and Herdr custom theme exist.

- [ ] **Step 1: Write the failing test**

  Assert that the default data selector is `kanagawa-dragon`, all native Kanagawa assets exist, each representative template renders the Kanagawa branch, unsupported selectors retain fallbacks, and rendered Herdr config contains `name = "custom"` plus `[theme.custom]`.

- [ ] **Step 2: Run the test to verify it fails**

  Run: `bash tests/unified-kanagawa-theme.sh`

  Expected: FAIL because the current default is `vesper` and Kanagawa assets/config branches do not exist.

- [ ] **Step 3: Commit the failing test**

  Run: `jj commit -m "test: cover kanagawa dragon cli theme"`

### Task 2: Add the shared Kanagawa Dragon palette and selector default

**Files:**
- Modify: `chezmoi/.chezmoidata/constants.toml`
- Modify: `chezmoi/.chezmoidata/shell_env.toml`

**Interfaces:**
- Consumes: Upstream Kanagawa palette names and semantic roles.
- Produces: `.theme.kanagawa_dragon` data and default `UNIFIED_THEME_CLI = "kanagawa-dragon"` for all templates.

- [ ] **Step 1: Add semantic palette values**

  Define background, surface, selection, border, foreground, muted, blue, green, red, yellow, violet, orange, aqua, and diagnostic colors using the upstream Dragon-compatible palette.

- [ ] **Step 2: Run the selector regression test**

  Run: `bash tests/unified-kanagawa-theme.sh`

  Expected: Still FAIL on missing native assets and template branches, but the default-selector assertion passes.

- [ ] **Step 3: Commit the shared palette**

  Run: `jj commit -m "feat: add kanagawa dragon palette"`

### Task 3: Add terminal, status, preview, listing, and agent adapters

**Files:**
- Create/modify: `chezmoi/dot_config/ghostty/config.tmpl`, `ghostty/themes/kanagawa-dragon`
- Create/modify: `chezmoi/dot_config/wezterm/wezterm.lua.tmpl`, `wezterm/themes/kanagawa-dragon.lua`
- Modify: `chezmoi/dot_config/hunk/config.toml.tmpl`
- Create/modify: `chezmoi/dot_config/bottom/bottom.toml.tmpl`, `btop/btop.conf.tmpl`, `btop/themes/kanagawa-dragon.theme`
- Create/modify: `chezmoi/dot_config/bat/themes/Kanagawa Dragon.tmTheme`, Bat selector templates, and cache script expectations
- Modify: `chezmoi/dot_config/eza/theme.yml.tmpl`, `lla/config.toml.tmpl`, `lla/themes/kanagawa-dragon.toml`
- Modify: `chezmoi/dot_config/yazi/theme.toml.tmpl`, `yazi/flavors/kanagawa-dragon.yazi/*`, `superfile/config.toml.tmpl`, `superfile/theme/kanagawa-dragon.toml`
- Modify: `chezmoi/dot_config/leaf/config.toml.tmpl`, add `leaf/kanagawa-dragon.toml`
- Modify: `chezmoi/dot_pi/agent/settings.json.tmpl`, add `dot_pi/agent/themes/kanagawa-dragon.json`

**Interfaces:**
- Consumes: `.theme.kanagawa_dragon` and selector precedence logic.
- Produces: Native Kanagawa Dragon theme files and conditional selectors for every already-supported non-editor CLI adapter.

- [ ] **Step 1: Add native theme asset assertions to the test**

  Include exact paths for Ghostty, WezTerm, Bat, btop, lla, Yazi, Superfile, Leaf, and Pi; assert Hunk/Bottom/eza selectors render Kanagawa values.

- [ ] **Step 2: Run the test to verify the new assertions fail**

  Run: `bash tests/unified-kanagawa-theme.sh`

  Expected: FAIL with missing Kanagawa asset or selector output.

- [ ] **Step 3: Implement native assets and template branches**

  Preserve unsupported-selector fallbacks. For Hunk, use its native custom-theme section. For Bat, use a TextMate theme and keep the cache rebuild script. For Yazi, provide both flavor TOML and syntax XML. For Pi, select the native theme id `kanagawa-dragon`.

- [ ] **Step 4: Render and validate formats**

  Run: `bash tests/unified-kanagawa-theme.sh`, `bash tests/chezmoi-render-config.sh`, and `bash tests/chezmoi-render-scripts.sh`.

  Expected: PASS with valid TOML/YAML/JSON/Lua/XML output.

- [ ] **Step 5: Commit the CLI adapters**

  Run: `jj commit -m "feat: add kanagawa dragon cli adapters"`

### Task 4: Add Herdr custom theme support

**Files:**
- Rename: `chezmoi/dot_config/herdr/config.toml` to `config.toml.tmpl`
- Modify: `chezmoi/dot_config/herdr/config.toml.tmpl`
- Modify: `tests/unified-kanagawa-theme.sh`

**Interfaces:**
- Consumes: Herdr's supported `[theme]` and `[theme.custom]` schema from `herdr --default-config`.
- Produces: `theme.name = "custom"` and a complete Kanagawa Dragon token set, selected only when `UNIFIED_THEME_CLI=kanagawa-dragon`; current `gruvbox` remains fallback.

- [ ] **Step 1: Add the Herdr-specific failing assertions**

  Assert the Kanagawa render contains `name = "custom"`, `[theme.custom]`, and Dragon values such as `#1F1F28`, `#DCD7BA`, `#957FB8`, and `#98BB6C`; assert fallback renders `name = "gruvbox"`.

- [ ] **Step 2: Run the test to verify it fails**

  Run: `bash tests/unified-kanagawa-theme.sh`

  Expected: FAIL because Herdr is not templated and has no custom-theme branch.

- [ ] **Step 3: Implement the template**

  Put the Go-template selector at the top of the `.toml.tmpl` source so the rendered target is valid TOML. In the Kanagawa branch set `name = "custom"` and define every Herdr custom token supported by the default config without using a built-in theme override.

- [ ] **Step 4: Validate Herdr configuration**

  Render both selectors, parse them with Python `tomllib`, and run `herdr config check` against a temporary rendered config when the binary is available.

- [ ] **Step 5: Commit Herdr support**

  Run: `jj commit -m "feat: add kanagawa dragon herdr theme"`

### Task 5: Full verification and handoff

**Files:**
- Modify: `tests/unified-kanagawa-theme.sh` or related render tests only for verified regressions
- Modify: documentation only if the current theme documentation explicitly says Vesper is the default

**Interfaces:**
- Consumes: all committed Kanagawa Dragon adapters.
- Produces: verified Chezmoi renders and a clean Jujutsu working copy.

- [ ] **Step 1: Run the complete regression suite**

  Run: `bash tests/unified-kanagawa-theme.sh`, `bash tests/chezmoi-render-config.sh`, and `bash tests/chezmoi-render-scripts.sh`.

- [ ] **Step 2: Run native checks where installed**

  Run: `herdr config check`, `bat --list-themes`, `delta --show-themes`, `lla theme`, `starship print-config`, and TOML/YAML/JSON/Lua/XML parsers as available.

- [ ] **Step 3: Inspect the final Jujutsu state**

  Run: `jj status --color never` and `jj show -r @- --stat`.

  Expected: working copy clean, with only the pre-existing `neovim-config` bookmark conflict warning.

- [ ] **Step 4: Report the result**

  Include the default selector, Herdr custom-theme behavior, verification commands, and the required `chezmoi apply`/shell reload step.
