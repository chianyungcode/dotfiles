#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
template_file="$source_dir/.chezmoi.toml.tmpl"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
for command_name in chezmoi jq rg; do command -v "$command_name" >/dev/null || {
	printf 'missing required command: %s\n' "$command_name" >&2
	exit 1
}; done
missing_config="$tmp_dir/missing.toml"
render_config() {
	local output_file=$1 input_config=$2
	shift 2
	chezmoi -S "$source_dir" -c "$input_config" execute-template --init "$@" --file "$template_file" >"$output_file"
}
config_data() { chezmoi -S "$source_dir" -c "$1" data >"$2"; }
server_config="$tmp_dir/server.toml"
server_data="$tmp_dir/server.json"
render_config "$server_config" "$missing_config"
config_data "$server_config" "$server_data"
jq -e '.machine.role == "server" and .identity == {profile: "server-minimal", git_name: "chianyungcode-server", git_email: "chianyungcode-server@local.invalid", github_username: "", signing_key: "", github_token: ""} and .features == {development: false, homelab: false, personal: false, graphical: false} and .secrets.provider == "none" and .encrypted_files.enabled == false' "$server_data" >/dev/null
workstation_config="$tmp_dir/workstation.toml"
workstation_data="$tmp_dir/workstation.json"
render_config "$workstation_config" "$missing_config" --promptChoice "Choose this machine's primary role=workstation"
config_data "$workstation_config" "$workstation_data"
jq -e '.machine.role == "workstation" and .identity.profile == "personal" and .features == {development: true, homelab: false, personal: true, graphical: true} and .secrets.provider == "onepassword" and .encrypted_files.enabled == true' "$workstation_data" >/dev/null
custom_config="$tmp_dir/custom.toml"
custom_data="$tmp_dir/custom.json"
render_config "$custom_config" "$missing_config" --promptChoice "Choose this machine's primary role=workstation" --promptChoice "Choose your identity profile=custom" --promptString "Git author name=Emergency" --promptString "Git author email=emergency@example.invalid" --promptString "GitHub username=emergency" --promptChoice "Choose the secrets provider=none" --promptBool "Enable Age-encrypted files?=false"
config_data "$custom_config" "$custom_data"
jq -e '.identity.profile == "custom" and .identity.git_name == "Emergency" and .identity.git_email == "emergency@example.invalid" and .identity.github_username == "emergency" and .identity.signing_key == "" and .identity.github_token == ""' "$custom_data" >/dev/null
server_to_workstation_input="$tmp_dir/server-to-workstation-input.toml"
printf '%s\n' '[data.machine]' 'role = "workstation"' '' '[data.identity]' 'profile = "server-minimal"' 'git_name = "chianyungcode-server"' 'git_email = "chianyungcode-server@local.invalid"' 'github_username = ""' 'signing_key = ""' 'github_token = ""' >"$server_to_workstation_input"
server_to_workstation_config="$tmp_dir/server-to-workstation.toml"
server_to_workstation_data="$tmp_dir/server-to-workstation.json"
render_config "$server_to_workstation_config" "$server_to_workstation_input"
config_data "$server_to_workstation_config" "$server_to_workstation_data"
jq -e '.machine.role == "workstation" and .identity.profile == "personal" and .features.personal == true and .features.graphical == true and .secrets.provider == "onepassword" and .encrypted_files.enabled == true' "$server_to_workstation_data" >/dev/null
workstation_to_server_input="$tmp_dir/workstation-to-server-input.toml"
printf '%s\n' '[data.machine]' 'role = "server"' '' '[data.identity]' 'profile = "personal"' >"$workstation_to_server_input"
workstation_to_server_config="$tmp_dir/workstation-to-server.toml"
workstation_to_server_data="$tmp_dir/workstation-to-server.json"
render_config "$workstation_to_server_config" "$workstation_to_server_input"
config_data "$workstation_to_server_config" "$workstation_to_server_data"
jq -e '.machine.role == "server" and .identity.profile == "server-minimal" and .features.personal == false and .features.graphical == false and .secrets.provider == "none" and .encrypted_files.enabled == false' "$workstation_to_server_data" >/dev/null
unknown_profile_input="$tmp_dir/unknown-profile-input.toml"
printf '%s\n' '[data.machine]' 'role = "workstation"' '' '[data.identity]' 'profile = "mystery"' >"$unknown_profile_input"
if render_config "$tmp_dir/unknown-profile.toml" "$unknown_profile_input" 2>"$tmp_dir/unknown-profile.err"; then
	printf 'unknown workstation profile unexpectedly rendered\n' >&2
	exit 1
fi
rg -q 'unknown workstation identity profile "mystery"' "$tmp_dir/unknown-profile.err"
if render_config "$tmp_dir/empty-custom.toml" "$missing_config" --promptChoice "Choose this machine's primary role=workstation" --promptChoice "Choose your identity profile=custom" --promptString "Git author name=" --promptString "Git author email=emergency@example.invalid" --promptString "GitHub username=" 2>"$tmp_dir/empty-custom.err"; then
	printf 'empty custom Git name unexpectedly rendered\n' >&2
	exit 1
fi
rg -q 'must define non-empty git_name and git_email' "$tmp_dir/empty-custom.err"
missing_account_source="$tmp_dir/missing-server-account-source"
mkdir -p "$missing_account_source/.chezmoidata"
cp "$template_file" "$missing_account_source/.chezmoi.toml.tmpl"
awk '/^\[accounts\.server-minimal\]$/ { exit } { print }' "$source_dir/.chezmoidata/accounts.toml" >"$missing_account_source/.chezmoidata/accounts.toml"
if chezmoi -S "$missing_account_source" -c "$missing_config" execute-template --init --file "$missing_account_source/.chezmoi.toml.tmpl" >"$tmp_dir/missing-account.toml" 2>"$tmp_dir/missing-account.err"; then
	printf 'missing server account unexpectedly rendered\n' >&2
	exit 1
fi
rg -q 'identity profile "server-minimal" is missing' "$tmp_dir/missing-account.err"
printf 'chezmoi init data passed\n'
