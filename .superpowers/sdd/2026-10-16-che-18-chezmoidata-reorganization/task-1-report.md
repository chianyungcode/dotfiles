# CHE-18 Task 1 implementation report

## Summary

Reorganized `.chezmoidata` to the approved layout, updated documentation references, and added layout assertions to the render test. The package-manager data was partitioned by retaining each manager's complete source section and table/array content. `.chezmoiscripts` remains flat.

## TDD evidence

- **RED:** After adding assertions for the new layout and correcting the Ubuntu fixture's personal feature, `./tests/chezmoi-render-scripts.sh` failed with `new data path is missing: directories.toml`.
- After the migration, the render suite exposed a separate pre-existing expectation mismatch: the macOS imperative-tools render does contain `herdr plugin install`. The enabled Herdr records are present in source data and the template renders all enabled records without an OS filter. Per supervisor ruling, corrected the test to assert the rendered Herdr commands are present; no data/template behavior was changed for this issue.
- **GREEN:** With that test-only assertion correction, the full render suite passed: `chezmoi script render tests passed`.

## Changes

- Renamed/moved data files to the approved paths: `directories.toml`, `packages/github-binaries.toml`, `packages/languages.toml`, `cli-tool-setup.toml`, `ssh-hosts.toml`, `apps/cask-app-names.toml`, and `apps/macos-external-apps.toml`.
- Split the former package-system file into `packages/system/{apt,homebrew,mas,pacman}.toml`.
- Left `accounts.toml`, `onepassword.toml`, and `shell_env.toml` unchanged.
- Updated `tests/chezmoi-render-scripts.sh` with positive new-path/negative old-path assertions, Ubuntu `personal=true`, and the corrected Herdr output expectation.
- Updated the four requested documentation files.

## Validation

Commands run:

1. `./tests/chezmoi-render-scripts.sh` before migration — failed as intended on missing `directories.toml`.
2. `chezmoi -S chezmoi data | jq -S . > /tmp/che18-current.json` and `jq -S . .superpowers/sdd/2026-10-16-che-18-chezmoidata-reorganization/base-data.json > /tmp/che18-base.json`, followed by `diff -u /tmp/che18-base.json /tmp/che18-current.json` — passed with no output; normalized merged data is identical to the capture.
3. `./tests/chezmoi-render-scripts.sh` — passed (`chezmoi script render tests passed`).
4. `rg` search over docs/source/tests for old `.toml` paths — no stale references; remaining matches are correct new paths containing old-name substrings.
5. `find chezmoi/.chezmoiscripts -mindepth 1 -maxdepth 1 -type d -print` — no directories; scripts remain flat.
6. `git diff --check` — passed.

## Self-review / residual risks

- The render test's previous macOS assertion contradicted the existing enabled imperative-tool data and the unconditional template loop. Its expectation now matches actual unchanged rendering; this is test-only and avoids an unapproved behavior change.
- No observed changes to merged data or arrays. The four manager sections were preserved as whole TOML sections. Commit hooks normalized trailing whitespace and corrected the spelling in two inactive package-name example comments to satisfy the repository typo check; neither affects data values.
- No other known residual risks.
