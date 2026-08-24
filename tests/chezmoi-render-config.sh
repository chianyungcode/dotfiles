#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi jq rg ssh; do
	command -v "$command_name" >/dev/null || {
		printf 'missing required command: %s\n' "$command_name" >&2
		exit 1
	}
done

server_config_file="$tmp_dir/server-chezmoi.toml"
workstation_config_file="$tmp_dir/workstation-chezmoi.toml"
custom_config_file="$tmp_dir/custom-chezmoi.toml"
missing_config="$tmp_dir/missing.toml"

chezmoi -S "$source_dir" -c "$missing_config" execute-template --init \
	--file "$source_dir/.chezmoi.toml.tmpl" >"$server_config_file"
chezmoi -S "$source_dir" -c "$missing_config" execute-template --init \
	--promptChoice "Choose this machine's primary role=workstation" \
	--promptChoice "Choose the secrets provider=none" \
	--promptBool "Enable Age-encrypted files?=false" \
	--file "$source_dir/.chezmoi.toml.tmpl" >"$workstation_config_file"
chezmoi -S "$source_dir" -c "$missing_config" execute-template --init \
	--promptChoice "Choose this machine's primary role=workstation" \
	--promptChoice "Choose your identity profile=custom" \
	--promptString "Git author name=Emergency" \
	--promptString "Git author email=emergency@example.invalid" \
	--promptString "GitHub username=emergency" \
	--promptChoice "Choose the secrets provider=none" \
	--promptBool "Enable Age-encrypted files?=false" \
	--file "$source_dir/.chezmoi.toml.tmpl" >"$custom_config_file"

server_base_data=$(chezmoi -S "$source_dir" -c "$server_config_file" data)
workstation_base_data=$(chezmoi -S "$source_dir" -c "$workstation_config_file" data)
custom_base_data=$(chezmoi -S "$source_dir" -c "$custom_config_file" data)

make_data() {
	local output_file=$1
	local base_data=$2
	local role=$3
	local development=$4
	local homelab=$5
	local personal=$6
	local graphical=$7
	local provider=$8
	local encrypted=$9
	local xdg_root=${10}

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
	local config_file=$2
	local data_file=$3
	local ci=${4:-false}
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
homelab_server_data="$tmp_dir/homelab-server.json"
workstation_data="$tmp_dir/workstation.json"
custom_identity_data="$tmp_dir/custom-identity.json"
custom_xdg_data="$tmp_dir/custom-xdg.json"

make_data "$server_data" "$server_base_data" server false false false false none false /tmp/chezmoi-server
make_data "$development_server_data" "$server_base_data" server true false false false none false /tmp/chezmoi-development
make_data "$homelab_server_data" "$server_base_data" server false true false false none false /tmp/chezmoi-homelab
make_data "$workstation_data" "$workstation_base_data" workstation true true true true none false /tmp/chezmoi-workstation
make_data "$custom_identity_data" "$custom_base_data" workstation true false true true none false /tmp/chezmoi-custom
make_data "$custom_xdg_data" "$workstation_base_data" workstation true false true true none false /tmp/custom-xdg

render_apply server "$server_config_file" "$server_data"
render_apply development-server "$server_config_file" "$development_server_data"
render_apply homelab-server "$server_config_file" "$homelab_server_data"
render_apply workstation "$workstation_config_file" "$workstation_data"
render_apply custom-identity "$custom_config_file" "$custom_identity_data"
render_apply ci "$server_config_file" "$server_data" true
render_apply custom-xdg "$workstation_config_file" "$custom_xdg_data"

server_config=$(<"$server_config_file")
if printf '%s\n' "$server_config" | rg -q '^encryption =|^\[age\]'; then
	printf 'secretless configuration unexpectedly enables Age encryption\n' >&2
	exit 1
fi
printf '%s\n' "$server_config" | rg -q '^\[data\.identity\]$'
printf '%s\n' "$server_config" | rg -q '^\[data\.features\]$'
printf '%s\n' "$server_config" | rg -q '^\[data\.xdg\]$'
printf '%s\n' "$server_config" | rg -q '^profile = "server-minimal"$'
printf '%s\n' "$server_config" | rg -q '^git_email = "chianyungcode-server@local.invalid"$'

workstation_config=$(<"$workstation_config_file")
printf '%s\n' "$workstation_config" | rg -q '^profile = "personal"$'

custom_config=$(<"$custom_config_file")
printf '%s\n' "$custom_config" | rg -q '^profile = "custom"$'
printf '%s\n' "$custom_config" | rg -q '^git_email = "emergency@example.invalid"$'

custom_xdg=$(chezmoi -S "$source_dir" -c "$workstation_config_file" \
	execute-template --override-data-file "$custom_xdg_data" \
	--file "$source_dir/dot_config/fish/env.d/000-xdg.fish.tmpl")
printf '%s\n' "$custom_xdg" | rg -q '/tmp/custom-xdg/data'
printf '%s\n' "$custom_xdg" | rg -q '/tmp/custom-xdg/state'

ssh_fake_bin="$tmp_dir/ssh-fake-bin"
mkdir -p "$ssh_fake_bin"
cat >"$ssh_fake_bin/op" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' \
	'{"fields":[{"label":"user","value":"test"},{"label":"hostname","value":"example.invalid"},{"label":"tailscale_ip","value":"100.64.0.1"},{"label":"port","value":"22"}]}'
STUB
chmod +x "$ssh_fake_bin/op"
ssh_data="$tmp_dir/ssh.json"
jq '.secrets.provider = "onepassword" | .chezmoi.os = "darwin"' \
	"$server_data" >"$ssh_data"
ssh_config="$tmp_dir/ssh-config"
PATH="$ssh_fake_bin:$PATH" chezmoi -S "$source_dir" \
	execute-template --override-data-file "$ssh_data" \
	--file "$source_dir/dot_ssh/config.tmpl" >"$ssh_config"
ssh_identity_count=$(rg -c '^    IdentityAgent ' "$ssh_config")
expected_identity_count=$(jq '[.remote_servers[] | select(.use_op_identity_agent == true)] | length' \
	"$ssh_data")
[[ "$ssh_identity_count" -eq "$expected_identity_count" ]]
rg -Fq 'IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"' \
	"$ssh_config"
ssh_local_config=$(env -u SSH_TTY ssh -G -F "$ssh_config" tailmbp)
printf '%s\n' "$ssh_local_config" | rg -q '^identityagent .+2BUA8C4S2C.com.1password/t/agent.sock$'
ssh_forwarded_config=$(SSH_TTY=/tmp/tty ssh -G -F "$ssh_config" tailmbp)
if printf '%s\n' "$ssh_forwarded_config" | rg -q '^identityagent '; then
	printf 'forwarded SSH agent unexpectedly overridden\n' >&2
	exit 1
fi

jq '.chezmoi.os = "linux"' "$ssh_data" >"$tmp_dir/ssh-linux.json"
PATH="$ssh_fake_bin:$PATH" chezmoi -S "$source_dir" \
	execute-template --override-data-file "$tmp_dir/ssh-linux.json" \
	--file "$source_dir/dot_ssh/config.tmpl" >"$tmp_dir/ssh-linux-config"
rg -Fq 'IdentityAgent ~/.1password/agent.sock' "$tmp_dir/ssh-linux-config"

jq '.remote_servers |= with_entries(.value.use_op_identity_agent = false)' \
	"$ssh_data" >"$tmp_dir/ssh-disabled.json"
PATH="$ssh_fake_bin:$PATH" chezmoi -S "$source_dir" \
	execute-template --override-data-file "$tmp_dir/ssh-disabled.json" \
	--file "$source_dir/dot_ssh/config.tmpl" >"$tmp_dir/ssh-disabled-config"
if rg -q '^    IdentityAgent ' "$tmp_dir/ssh-disabled-config"; then
	printf 'disabled 1Password SSH agent unexpectedly rendered\n' >&2
	exit 1
fi

ci_ignore=$(CI=1 chezmoi -S "$source_dir" -c "$server_config_file" \
	execute-template --override-data-file "$server_data" \
	--file "$source_dir/.chezmoiignore")
printf '%s\n' "$ci_ignore" | rg -q '^\.codex$'
printf '%s\n' "$ci_ignore" | rg -q '^\.config/fish/env.d/030-secrets-age.fish$'

server_git=$(chezmoi -S "$source_dir" -c "$server_config_file" \
	execute-template --override-data-file "$server_data" \
	--file "$source_dir/dot_config/git/config.tmpl")
workstation_git=$(chezmoi -S "$source_dir" -c "$workstation_config_file" \
	execute-template --override-data-file "$workstation_data" \
	--file "$source_dir/dot_config/git/config.tmpl")
if printf '%s\n' "$server_git" | rg -q '^    pager = delta$|^    external = difft$|^    tool = difftastic$'; then
	printf 'server configuration unexpectedly enables optional diff tools\n' >&2
	exit 1
fi
printf '%s\n' "$workstation_git" | rg -q '^    pager = delta$'
printf '%s\n' "$workstation_git" | rg -q '^    external = difft$'

server_jj=$(chezmoi -S "$source_dir" -c "$server_config_file" \
	execute-template --override-data-file "$server_data" \
	--file "$source_dir/dot_config/jj/config.toml.tmpl")
workstation_jj=$(chezmoi -S "$source_dir" -c "$workstation_config_file" \
	execute-template --override-data-file "$workstation_data" \
	--file "$source_dir/dot_config/jj/config.toml.tmpl")
if printf '%s\n' "$server_jj" | rg -q 'diff-formatter|diff-tool'; then
	printf 'server Jujutsu configuration unexpectedly enables optional diff tools\n' >&2
	exit 1
fi
printf '%s\n' "$workstation_jj" | rg -q '^  diff-formatter = \["difft"'
printf '%s\n' "$workstation_jj" | rg -q '^  diff-tool = "difft"$'

legacy_pattern='\.(git_user|git_email|github_user|dev_computer|homelab_member|personal_computer|is_ci_workflow|use_secrets|xdgCacheDir|xdgConfigDir|xdgDataDir|xdgStateDir)\b'
legacy_matches=$(rg -n "$legacy_pattern" "$source_dir" \
	--glob '*.tmpl' --glob '*.toml' --glob '*.fish' --glob '*.sh' --glob '*.bash' \
	--glob '!.chezmoi.toml.tmpl' |
	rg -v '\.identity\.(git_email|git_name|github_username)\b' || true)
if [[ -n "$legacy_matches" ]]; then
	printf '%s\n' "$legacy_matches"
	printf 'legacy template references remain\n' >&2
	exit 1
fi

printf 'chezmoi render matrix passed\n'
