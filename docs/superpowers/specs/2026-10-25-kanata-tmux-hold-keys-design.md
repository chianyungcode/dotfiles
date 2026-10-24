# Kanata tmux hold keys

- **Intent:** Make `a` and `;` behave like existing tmux hold keys: tap sends the key; hold activates the `tmux` layer. `'` remains a plain key.
- **Goals:** Change only the base-layer aliases/key mappings in `chezmoi/dot_config/kanata/parts/core.kbd.tmpl`.
- **Non-goals:** Change tap/hold timings or tmux-layer mappings.
- **Tradeoff/approaches:** Preserve `a`'s existing `sublayers` hold (does not satisfy the request for `a`); instead, replace it with tmux hold behavior and add tmux hold behavior to `;`. This is selected.
- **Verification:** Render/check the resulting Kanata config if the repository's available tooling supports it; this is a config-only change, so no test fixture is planned.
