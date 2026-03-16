#!/usr/bin/env bash

set -euo pipefail

selection="$(
  sesh list -i |
    gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡' ||
    true
)"

[ -n "$selection" ] || exit 0

session="$(printf '%s\n' "$selection" | sed -E 's/^[^[:space:]]+[[:space:]]+//')"

[ -n "$session" ] || exit 0

exec sesh connect "$session"
