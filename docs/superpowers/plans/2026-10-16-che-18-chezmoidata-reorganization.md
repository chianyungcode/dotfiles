# CHE-18 `.chezmoidata` Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reorganize `.chezmoidata` into the agreed subfolders and filenames while keeping rendered data and script behavior unchanged.

**Architecture:** Keep the TOML tables and keys intact, moving each whole data table into its new file. Split the system package table at package-manager boundaries, then update repository references and test the rendered data and scripts.

**Tech Stack:** TOML, chezmoi, Bash render test, `jq`.

**Spec:** Linear issue [CHE-18](https://linear.app/dotfiles-workspace/issue/CHE-18/reorganize-chezmoidata-and-chezmoiscripts-into-subfolders).

## Global Constraints

- Keep template data keys/table names unchanged.
- Keep each array wholly in one TOML file; arrays are replaced, not concatenated.
- Keep `.chezmoiscripts/` flat; grouping is optional and no clear navigation gain was found.
- Preserve the current `chezmoi data` output and generated script behavior.
- Update references in the docs and tests when paths change.

## Review Focus

- Nested TOML files are still loaded recursively — pin with the new-path assertions and successful `chezmoi data` invocation.
- Package-manager arrays/tables survive the split — pin with the before/after normalized `chezmoi data` comparison and render-script test.
- No stale filenames remain in documentation or tests — pin with a repository search for the old paths.
- Existing `.chezmoiscripts` attributes and behavior stay intact — scripts remain unmoved; verify their paths are unchanged and render test passes.
- Account/secret data remains intact — these files keep their paths; verify the normalized data comparison.

---

### Task 1: Reorganize chezmoi data and update references

**Files:**
- Move/rename `chezmoi/.chezmoidata/constants.toml` to `directories.toml`.
- Move/rename `binaries.toml` to `packages/github-binaries.toml`.
- Move/rename `packages-language.toml` to `packages/languages.toml`.
- Move/rename `imperative-cli-tools.toml` to `cli-tool-setup.toml`.
- Move/rename `remote_servers.toml` to `ssh-hosts.toml`.
- Move `diff-name-apps.toml` to `apps/cask-app-names.toml` and `macos-external-apps.toml` to `apps/macos-external-apps.toml`.
- Split `packages-system.toml` into `packages/system/{apt,homebrew,mas,pacman}.toml`, preserving each manager's complete tables and arrays.
- Keep `accounts.toml`, `onepassword.toml`, and `shell_env.toml` unchanged.
- Modify `tests/chezmoi-render-scripts.sh`, `docs/01-shell-scripting-chezmoi.md`, `docs/02-packages-installation-flow.md`, `docs/04-remote-server-flow.md`, and `docs/06-cli-integrations.md`.

**Interfaces:**
- Consumes: CHE-18's approved layout and the current TOML data tables.
- Produces: The same merged chezmoi data keys, loaded from the new paths.

- [ ] **Step 1: Write the failing layout assertions** in `tests/chezmoi-render-scripts.sh` for the new paths and absence of the old paths; set the Ubuntu fixture's personal feature to `true` so its existing `cargo-binstall` assertion matches the data table it is meant to exercise; correct the existing Herdr assertion to match the enabled CLI entries rendered by the template.
- [ ] **Step 2: Run `./tests/chezmoi-render-scripts.sh` and verify it fails on a missing new path.**
- [ ] **Step 3: Move the files and split `packages-system.toml` by package manager**, without changing table names or array contents.
- [ ] **Step 4: Update the documentation paths and descriptions** to reflect the final layout.
- [ ] **Step 5: Verify behavior.** Compare normalized `chezmoi -S chezmoi data` output against the pre-migration capture; run `./tests/chezmoi-render-scripts.sh`; search for stale old paths.
- [ ] **Step 6: Commit the verified migration** as `refactor: reorganize chezmoi data`.
