#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

assert_contains() {
    local value=$1
    local pattern=$2
    printf '%s\n' "$value" | rg -q "$pattern" ||
        fail "rendered output does not contain: $pattern"
}

assert_file() {
    [[ -f "$1" ]] || fail "expected file is missing: $1"
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"

for command_name in chezmoi jq rg; do
    command -v "$command_name" >/dev/null || {
        printf 'missing required command: %s\n' "$command_name" >&2
        exit 1
    }
done

for file in \
    "$source_dir/dot_config/ghostty/themes/vesper" \
    "$source_dir/dot_config/wezterm/themes/vesper.lua" \
    "$source_dir/dot_config/bat/themes/Vesper.tmTheme" \
    "$source_dir/dot_config/btop/themes/vesper.theme" \
    "$source_dir/dot_config/eza/theme.yml.tmpl" \
    "$source_dir/dot_config/lla/themes/vesper.toml" \
    "$source_dir/dot_config/yazi/flavors/vesper.yazi/flavor.toml" \
    "$source_dir/dot_config/yazi/flavors/vesper.yazi/tmtheme.xml" \
    "$source_dir/dot_config/superfile/theme/vesper.toml" \
    "$source_dir/dot_pi/agent/themes/vesper.json"; do
    assert_file "$file"
done

assert_file "$source_dir/dot_config/starship/starship.toml.tmpl"
[[ ! -e "$source_dir/dot_config/starship/starship.toml" ]] ||
    fail "Starship source must be a Chezmoi template"

tmp_dir=$(mktemp -d)
base_data_file="$tmp_dir/base.json"
trap 'rm -rf "$tmp_dir"' EXIT
chezmoi -S "$source_dir" data >"$base_data_file"

theme_data=$(jq -r '.shell_env.common.UNIFIED_THEME_CLI' "$base_data_file")
[[ "$theme_data" == vesper ]] || fail "UNIFIED_THEME_CLI default is not vesper"

render() {
    local selector=$1
    local source_file=$2
    UNIFIED_THEME_CLI="$selector" chezmoi -S "$source_dir" execute-template \
        --override-data-file "$base_data_file" --file "$source_dir/$source_file"
}

ghostty=$(render vesper dot_config/ghostty/config.tmpl)
assert_contains "$ghostty" '^theme = vesper$'

ghostty_fallback=$(render unsupported dot_config/ghostty/config.tmpl)
assert_contains "$ghostty_fallback" '^theme = oldworld-vibrant$'

hunk=$(render vesper dot_config/hunk/config.toml.tmpl)
assert_contains "$hunk" '^theme\s+= "custom"'
assert_contains "$hunk" '^\[custom_theme\]$'

pi=$(render vesper dot_pi/agent/settings.json.tmpl)
assert_contains "$pi" '"theme": "vesper"'

pi_fallback=$(render unsupported dot_pi/agent/settings.json.tmpl)
assert_contains "$pi_fallback" '"theme": "catppuccin-mocha"'

fish_bat=$(render vesper dot_config/fish/conf.d/90_bat.fish.tmpl)
assert_contains "$fish_bat" 'BAT_THEME "Vesper"'

zsh_bat=$(render vesper dot_config/zsh/conf.d/third-party/bat.sh.tmpl)
assert_contains "$zsh_bat" 'BAT_THEME="Vesper"'

printf 'unified Vesper theme render checks passed\n'
