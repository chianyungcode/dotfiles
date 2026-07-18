#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi jq rg; do
    command -v "$command_name" >/dev/null || {
        printf 'missing required command: %s\n' "$command_name" >&2
        exit 1
    }
done

config_file="$tmp_dir/chezmoi.toml"
chezmoi -S "$source_dir" execute-template --init \
    --file "$source_dir/.chezmoi.toml.tmpl" >"$config_file"

base_data=$(chezmoi -S "$source_dir" -c "$config_file" data)

make_data() {
    local output_file=$1
    local role=$2
    local development=$3
    local homelab=$4
    local personal=$5
    local graphical=$6
    local provider=$7
    local encrypted=$8
    local xdg_root=$9

    printf '%s\n' "$base_data" | jq \
        --arg role "$role" \
        --argjson development "$development" \
        --argjson homelab "$homelab" \
        --argjson personal "$personal" \
        --argjson graphical "$graphical" \
        --arg provider "$provider" \
        --argjson encrypted "$encrypted" \
        --arg xdg_root "$xdg_root" \
        '.machine.role = $role
         | .features = {
             development: $development,
             homelab: $homelab,
             personal: $personal,
             graphical: $graphical
           }
         | .secrets.provider = $provider
         | .encrypted_files.enabled = $encrypted
         | .xdg = {
             cache_home: ($xdg_root + "/cache"),
             config_home: ($xdg_root + "/config"),
             data_home: ($xdg_root + "/data"),
             state_home: ($xdg_root + "/state")
           }' >"$output_file"
}

render_apply() {
    local name=$1
    local data_file=$2
    local ci=${3:-false}
    local destination="$tmp_dir/$name"
    mkdir -p "$destination"

    if [[ "$ci" == true ]]; then
        CI=1 chezmoi -S "$source_dir" -c "$config_file" \
            -D "$destination" --override-data-file "$data_file" apply \
            --dry-run --no-tty --force --exclude externals
    else
        chezmoi -S "$source_dir" -c "$config_file" \
            -D "$destination" --override-data-file "$data_file" apply \
            --dry-run --no-tty --force --exclude externals
    fi
}

server_data="$tmp_dir/server.json"
development_server_data="$tmp_dir/development-server.json"
workstation_data="$tmp_dir/workstation.json"
custom_xdg_data="$tmp_dir/custom-xdg.json"

make_data "$server_data" server false false false false none false /tmp/chezmoi-server
make_data "$development_server_data" server true false false false none false /tmp/chezmoi-development
make_data "$workstation_data" workstation true true true true none false /tmp/chezmoi-workstation
make_data "$custom_xdg_data" workstation true false true true none false /tmp/custom-xdg

render_apply server "$server_data"
render_apply development-server "$development_server_data"
render_apply workstation "$workstation_data"
render_apply ci "$server_data" true
render_apply custom-xdg "$custom_xdg_data"

server_config=$(<"$config_file")
if printf '%s\n' "$server_config" | rg -q '^encryption =|^\[age\]'; then
    printf 'secretless configuration unexpectedly enables Age encryption\n' >&2
    exit 1
fi
printf '%s\n' "$server_config" | rg -q '^\[data\.identity\]$'
printf '%s\n' "$server_config" | rg -q '^\[data\.features\]$'
printf '%s\n' "$server_config" | rg -q '^\[data\.xdg\]$'

custom_xdg=$(chezmoi -S "$source_dir" -c "$config_file" \
    execute-template --override-data-file "$custom_xdg_data" \
    --file "$source_dir/dot_config/fish/env.d/000-xdg.fish.tmpl")
printf '%s\n' "$custom_xdg" | rg -q '/tmp/custom-xdg/data'
printf '%s\n' "$custom_xdg" | rg -q '/tmp/custom-xdg/state'

ci_ignore=$(CI=1 chezmoi -S "$source_dir" -c "$config_file" \
    execute-template --override-data-file "$server_data" \
    --file "$source_dir/.chezmoiignore")
printf '%s\n' "$ci_ignore" | rg -q '^\.codex$'
printf '%s\n' "$ci_ignore" | rg -q '^\.config/fish/env.d/030-secrets-age.fish$'

legacy_pattern='\.(git_user|git_email|github_user|dev_computer|homelab_member|personal_computer|is_ci_workflow|use_secrets|xdgCacheDir|xdgConfigDir|xdgDataDir|xdgStateDir)\b'
legacy_matches=$(rg -n "$legacy_pattern" "$source_dir" \
    --glob '*.tmpl' --glob '*.toml' --glob '*.fish' --glob '*.sh' --glob '*.bash' \
    --glob '!.chezmoi.toml.tmpl' \
    | rg -v '\.identity\.(git_email|git_name|github_username)\b' || true)
if [[ -n "$legacy_matches" ]]; then
    printf '%s\n' "$legacy_matches"
    printf 'legacy template references remain\n' >&2
    exit 1
fi

printf 'chezmoi render matrix passed\n'
