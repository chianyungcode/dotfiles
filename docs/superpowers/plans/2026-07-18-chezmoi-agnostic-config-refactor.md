# Chezmoi Agnostic Configuration Refactor Implementation Plan

> **For agentic workers:** Implement each task as a separately verified atomic `jj` change.

**Goal:** Finish the existing chezmoi configuration refactor so identity data is sourced from account profiles, optional tools are not required globally, and portable render paths are verifiable.

**Architecture:** Keep native chezmoi initialization and nested `[data]` namespaces. Account-specific values remain in `.chezmoidata/accounts.toml`; templates consume `.identity`, `.features`, `.secrets`, `.encrypted_files`, and `.xdg` only. Runtime CI detection remains derived from `CI`.

**Tech Stack:** Chezmoi 2.71 Go templates, TOML, shell templates, Jujutsu (`jj`).

## Global Constraints

- Preserve the native `chezmoi init --apply <repository-url>` flow.
- Do not add a bootstrap wrapper or distro-specific global fields.
- Keep secrets provider selection independent from Age-encrypted source selection.
- Use built-in `.chezmoi.os`, `.chezmoi.osRelease.id`, and `.chezmoi.arch` for OS detection.
- Every implementation slice ends with fresh verification and one atomic `jj` commit.

### Task 1: Source identity prompts from account data

**Files:**
- Modify: `chezmoi/.chezmoi.toml.tmpl`
- Modify: `chezmoi/.chezmoidata/accounts.toml`

Make predefined identity choices read the complete account record from `.accounts`; retain `custom` prompts with empty optional signing/token references. Verify generated data for personal, secondary, and custom identities.

Commit: `refactor(chezmoi): source identity from account profiles`

### Task 2: Remove optional global diff-tool requirements

**Files:**
- Modify: `chezmoi/dot_config/git/config.tmpl`
- Modify: `chezmoi/dot_config/jj/config.toml.tmpl`

Remove unconditional `difft`/difftastic and delta formatter configuration from generated Git/Jujutsu configuration while retaining normal built-in diff behavior and explicit user aliases only where they do not run automatically.

Commit: `refactor(chezmoi): avoid mandatory diff tooling`

### Task 3: Gate graphical targets independently

**Files:**
- Modify: `chezmoi/.chezmoiignore`
- Modify: `chezmoi/.chezmoiscripts/run_onchange_before_10-homebrew-packages.sh.tmpl`
- Modify: `chezmoi/.chezmoidata/packages.toml`

Represent GUI-only Homebrew casks in a graphical package group and gate graphical target directories with `.features.graphical`, without coupling the behavior to `machine.role`.

Commit: `refactor(chezmoi): gate graphical configuration capability`

### Task 4: Add render matrix verification and update docs

**Files:**
- Create: `tests/chezmoi-render-config.sh`
- Modify: `README.md`
- Modify: `docs/chianyung/chezmoi-agnostic-config-refactor-plan.md`

Add a shell verification matrix using temporary chezmoi config/data overrides to check nested data, secretless rendering, custom XDG paths, CI-derived ignores, and absence of legacy fields. Document the commands and mark the plan status/acceptance items that are actually verified.

Commit: `test(chezmoi): add configuration render matrix`
