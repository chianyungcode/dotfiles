#!/usr/bin/env bash

set -euo pipefail

fail() {
	printf '%s\n' "$1" >&2
	exit 1
}

assert_contains() {
    local file=$1
    local pattern=$2
    rg -q "$pattern" "$file" ||
        fail "$file does not contain pattern: $pattern"
}

assert_not_contains() {
    local file=$1
    local pattern=$2
    if rg -q "$pattern" "$file"; then
        fail "$file unexpectedly contains pattern: $pattern"
    fi
}

make_profile() {
    local output_file=$1
    local os=$2
    local distribution=$3
    local architecture=$4
    local development=$5
    local personal=$6
    local homelab=$7
    local graphical=$8

    jq \
        --arg os "$os" \
        --arg distribution "$distribution" \
        --arg architecture "$architecture" \
        --argjson development "$development" \
        --argjson personal "$personal" \
        --argjson homelab "$homelab" \
        --argjson graphical "$graphical" \
        '.chezmoi.os = $os
         | .chezmoi.osRelease.id = $distribution
         | .chezmoi.arch = $architecture
         | .features = {
             development: $development,
             personal: $personal,
             homelab: $homelab,
             graphical: $graphical
           }
         | .secrets.provider = "none"
         | .encrypted_files.enabled = false' \
        "$base_data_file" >"$output_file"
}

render_script() {
    local profile=$1
    local source_script=$2
    local output_file=$3
    chezmoi -S "$source_dir" execute-template \
        --override-data-file "$profile" \
        --file "$source_script" >"$output_file"
}

render_script_ci() {
    local profile=$1
    local source_script=$2
    local output_file=$3
    CI=true chezmoi -S "$source_dir" execute-template \
        --override-data-file "$profile" \
        --file "$source_script" >"$output_file"
}

check_rendered_script() {
    local script=$1
    [[ ! -s "$script" ]] && return 0
    head -n 1 "$script" | rg -q '^#!/usr/bin/env bash$' ||
        fail "$script has no Bash shebang"
    bash -n "$script"
    shfmt -d -i 4 "$script"
    shellcheck -S warning "$script"
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stale_docs_pattern='shared_script_utils|run_after_20-create-ssh-keys|run_onchange_before_10-homebrew-packages|run_after_30-instal-atuin|install-binary\.py'
if rg -n "$stale_docs_pattern" \
    "$repo_root/README.md" \
    "$repo_root/docs/01-remote-server-flow.md" \
    "$repo_root/docs/02-homebrew-packages-flow.md" \
    "$repo_root/docs/03-shell-scripting-chezmoi.md" \
    "$repo_root/docs/security-review.md"; then
    fail "documentation still refers to legacy script architecture"
fi

for command_name in bash chezmoi jq rg shellcheck shfmt; do
	command -v "$command_name" >/dev/null ||
		{
			printf 'missing command: %s\n' "$command_name" >&2
			exit 1
		}
done

base_data_file="$tmp_dir/base.json"
chezmoi -S "$source_dir" data >"$base_data_file"

[[ -f "$source_dir/.chezmoidata/packages-system.toml" ]] ||
	fail "packages-system.toml is missing"
[[ -f "$source_dir/.chezmoidata/packages-language.toml" ]] ||
	fail "packages-language.toml is missing"
[[ ! -e "$source_dir/.chezmoidata/packages.toml" ]] ||
	fail "legacy packages.toml still exists"

jq -e '
    .packages
    | has("homebrew")
      and has("mas")
      and has("apt")
      and has("pacman")
      and has("python")
      and has("cargo")
      and has("node")
' "$base_data_file" >/dev/null

jq -e '
    [.runtimes[] | {name, version, features}]
    == [
      {name:"node", version:"latest", features:["development","personal"]},
      {name:"go", version:"latest", features:["development"]},
      {name:"rust", version:"latest", features:["development","personal"]},
      {name:"bun", version:"latest", features:["development"]},
      {name:"deno", version:"latest", features:["development"]},
      {name:"taplo", version:"latest", features:["development"]}
    ]
' "$base_data_file" >/dev/null

mac_data="$tmp_dir/mac.json"
ubuntu_data="$tmp_dir/ubuntu.json"
arch_data="$tmp_dir/arch.json"
make_profile "$mac_data" darwin darwin arm64 true true false true
make_profile "$ubuntu_data" linux ubuntu amd64 true false false false
make_profile "$arch_data" linux arch amd64 true true false true

bootstrap_source="$source_dir/.chezmoiscripts/run_before_00-bootstrap.sh.tmpl"
for profile in mac ubuntu arch; do
    render_script "$tmp_dir/$profile.json" "$bootstrap_source" \
        "$tmp_dir/$profile-bootstrap.sh"
    check_rendered_script "$tmp_dir/$profile-bootstrap.sh"
done

assert_contains "$tmp_dir/mac-bootstrap.sh" 'Installing Homebrew'
assert_not_contains "$tmp_dir/mac-bootstrap.sh" 'paru'
assert_contains "$tmp_dir/ubuntu-bootstrap.sh" 'apt-get install'
assert_not_contains "$tmp_dir/ubuntu-bootstrap.sh" 'pacman'
assert_contains "$tmp_dir/arch-bootstrap.sh" 'command -v paru'
assert_contains "$tmp_dir/arch-bootstrap.sh" 'makepkg -si'
assert_not_contains "$tmp_dir/arch-bootstrap.sh" 'apt-get'

system_source="$source_dir/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl"
for profile in mac ubuntu arch; do
    render_script "$tmp_dir/$profile.json" "$system_source" \
        "$tmp_dir/$profile-system.sh"
    check_rendered_script "$tmp_dir/$profile-system.sh"
done

assert_contains "$tmp_dir/mac-system.sh" 'brew install'
assert_contains "$tmp_dir/mac-system.sh" 'mas install'
assert_not_contains "$tmp_dir/mac-system.sh" 'apt-get|paru'

assert_contains "$tmp_dir/ubuntu-system.sh" 'apt-get install'
assert_contains "$tmp_dir/ubuntu-system.sh" 'deb.gierens.de'
assert_not_contains "$tmp_dir/ubuntu-system.sh" 'brew|paru'

assert_contains "$tmp_dir/arch-system.sh" 'paru -S'
assert_not_contains "$tmp_dir/arch-system.sh" 'brew|apt-get'

runtime_source="$source_dir/.chezmoiscripts/run_onchange_after_20-language-runtimes.sh.tmpl"
language_source="$source_dir/.chezmoiscripts/run_onchange_after_30-language-packages.sh.tmpl"
render_script "$ubuntu_data" "$runtime_source" "$tmp_dir/ubuntu-runtime.sh"
render_script "$ubuntu_data" "$language_source" "$tmp_dir/ubuntu-language.sh"
check_rendered_script "$tmp_dir/ubuntu-runtime.sh"
check_rendered_script "$tmp_dir/ubuntu-language.sh"

assert_contains "$tmp_dir/ubuntu-runtime.sh" 'node@latest'
assert_contains "$tmp_dir/ubuntu-runtime.sh" 'rust@latest'
assert_contains "$tmp_dir/ubuntu-language.sh" '@go-task/cli'
assert_contains "$tmp_dir/ubuntu-language.sh" 'cargo-binstall'

server_data="$tmp_dir/server.json"
make_profile "$server_data" linux ubuntu amd64 false false false false
render_script "$server_data" "$runtime_source" "$tmp_dir/server-runtime.sh"
check_rendered_script "$tmp_dir/server-runtime.sh"
assert_contains "$tmp_dir/server-runtime.sh" 'ensure_uv'
assert_not_contains "$tmp_dir/server-runtime.sh" 'node@latest'
assert_not_contains "$tmp_dir/server-runtime.sh" 'rust@latest'
assert_not_contains "$tmp_dir/server-runtime.sh" 'ensure_mise'

standalone_source="$source_dir/.chezmoiscripts/run_onchange_after_40-standalone-tools.sh.tmpl"
render_script "$mac_data" "$standalone_source" "$tmp_dir/mac-standalone.sh"
render_script "$ubuntu_data" "$standalone_source" "$tmp_dir/ubuntu-standalone.sh"
render_script "$arch_data" "$standalone_source" "$tmp_dir/arch-standalone.sh"
render_script "$server_data" "$standalone_source" "$tmp_dir/server-standalone.sh"
render_script_ci "$ubuntu_data" "$standalone_source" "$tmp_dir/ci-standalone.sh"

[[ ! -s "$tmp_dir/mac-standalone.sh" ]] ||
    fail "macOS standalone phase must render empty"
check_rendered_script "$tmp_dir/ubuntu-standalone.sh"
check_rendered_script "$tmp_dir/arch-standalone.sh"
check_rendered_script "$tmp_dir/server-standalone.sh"
[[ ! -s "$tmp_dir/ci-standalone.sh" ]] ||
    fail "CI standalone phase must render empty"

for repository in \
    'atuinsh/atuin' \
    'ClementTsang/bottom' \
    'mr-karan/doggo' \
    'dandavison/delta' \
    'jesseduffield/lazygit' \
    'MilesCranmer/rip2' \
    'ajeetdsouza/zoxide'; do
    assert_contains "$tmp_dir/ubuntu-standalone.sh" "$repository"
    assert_contains "$tmp_dir/arch-standalone.sh" "$repository"
done
assert_contains "$tmp_dir/ubuntu-standalone.sh" 'install_git_credential_manager'
assert_contains "$tmp_dir/ubuntu-standalone.sh" 'sudo dpkg -i'
assert_not_contains "$tmp_dir/arch-standalone.sh" 'install_git_credential_manager|dpkg'
assert_not_contains "$tmp_dir/server-standalone.sh" 'jesseduffield/lazygit'

post_install_source="$source_dir/.chezmoiscripts/run_after_50-post-install.sh.tmpl"
post_install="$tmp_dir/ubuntu-post-install.sh"
render_script "$ubuntu_data" "$post_install_source" "$post_install"
check_rendered_script "$post_install"
assert_contains "$post_install" 'ANTIDOTE_DIR='
assert_contains "$post_install" 'nanorc'
assert_contains "$post_install" 'fdfind'
assert_contains "$post_install" 'batcat'

security_source="$source_dir/.chezmoiscripts/run_onchange_after_60-security-material.sh.tmpl"
security_none="$tmp_dir/security-none.sh"
render_script "$ubuntu_data" "$security_source" "$security_none"
[[ ! -s "$security_none" ]] ||
    fail "security phase must be empty for provider none"

security_onepassword="$tmp_dir/security-onepassword.json"
jq '.secrets.provider = "onepassword"' "$ubuntu_data" >"$security_onepassword"
security_fake_bin="$tmp_dir/security-fake-bin"
mkdir -p "$security_fake_bin"
cat >"$security_fake_bin/op" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "signin" && "${2:-}" == "--raw" ]]; then
    printf '%s\n' 'test-session'
elif [[ "$1" == "item" && "${2:-}" == "get" ]] ||
    [[ "$1" == "--session" && "${3:-}" == "item" && "${4:-}" == "get" ]]; then
    printf '%s\n' '{"fields":[{"label":"private key","value":"PRIVATE-KEY-FIXTURE\n"},{"label":"public key","value":"ssh-ed25519 PUBLIC-FIXTURE\n"}]}'
else
    exit 64
fi
STUB
chmod +x "$security_fake_bin/op"
security_rendered="$tmp_dir/security-onepassword.sh"
PATH="$security_fake_bin:$PATH" chezmoi -S "$source_dir" execute-template \
    --override-data-file "$security_onepassword" \
    --file "$security_source" >"$security_rendered"
check_rendered_script "$security_rendered"

maintenance_source="$source_dir/.chezmoiscripts/run_once_after_90-monthly-maintenance.sh.tmpl"
maintenance="$tmp_dir/monthly-maintenance.sh"
render_script "$ubuntu_data" "$maintenance_source" "$maintenance"
check_rendered_script "$maintenance"
assert_contains "$maintenance" 'uv tool upgrade --all'
assert_contains "$maintenance_source" 'output "date" "\+%m"'

actual_scripts="$tmp_dir/actual-scripts.txt"
expected_scripts="$tmp_dir/expected-scripts.txt"

find "$source_dir/.chezmoiscripts" -maxdepth 1 -type f \
    -exec basename {} \; | sort >"$actual_scripts"

printf '%s\n' \
    run_after_50-post-install.sh.tmpl \
    run_before_00-bootstrap.sh.tmpl \
    run_onchange_after_20-language-runtimes.sh.tmpl \
    run_onchange_after_30-language-packages.sh.tmpl \
    run_onchange_after_40-standalone-tools.sh.tmpl \
    run_onchange_after_60-security-material.sh.tmpl \
    run_onchange_before_10-system-packages.sh.tmpl \
    run_once_after_90-monthly-maintenance.sh.tmpl |
    sort >"$expected_scripts"

diff -u "$expected_scripts" "$actual_scripts"

printf 'chezmoi script render tests passed\n'
