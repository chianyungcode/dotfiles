#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi jq rg; do
	command -v "$command_name" >/dev/null ||
		{
			printf 'missing command: %s\n' "$command_name" >&2
			exit 1
		}
done

assert_log_contains() {
	local pattern=$1
	rg -Fq "$pattern" "$COMMAND_LOG" || {
		printf 'missing command log entry: %s\n' "$pattern" >&2
		exit 1
	}
}

assert_file_contains() {
	local file=$1
	local pattern=$2
	rg -Fq "$pattern" "$file" || {
		printf 'missing file content: %s\n' "$pattern" >&2
		exit 1
	}
}

assert_file_mode() {
	local file=$1
	local expected_mode=$2
	local actual_mode

	if actual_mode=$(stat -f '%Lp' "$file" 2>/dev/null); then
		:
	else
		actual_mode=$(stat -c '%a' "$file")
	fi
	[[ "$actual_mode" == "$expected_mode" ]] || {
		printf 'unexpected mode for %s: %s\n' "$file" "$actual_mode" >&2
		exit 1
	}
}

assert_no_security_fixture_material() {
	local file=$1
	local material
	for material in \
		'PRIVATE-KEY-FIXTURE' \
		'ssh-ed25519 PUBLIC-FIXTURE' \
		'UFJJVkFURS1LRVktRklYVFVSRQo=' \
		'c3NoLWVkMjU1MTkgUFVCTElDLUZJWFRVUkUK'; do
		if rg -Fq "$material" "$file"; then
			printf '%s contains reversible security fixture material\n' \
				"$file" >&2
			exit 1
		fi
	done
}

core_fixture="$tmp_dir/core-fixture.sh"
{
	printf '%s\n' '#!/usr/bin/env bash'
	printf '%s\n' 'PHASE="core-test"'
	chezmoi -S "$source_dir" execute-template \
		--file "$source_dir/.chezmoitemplates/scripts/core.bash"
	printf '%s\n' 'make_temp_dir "core-test"'
	# shellcheck disable=SC2016 # Literal shell code for the fixture.
	printf '%s\n' 'printf "%s" "$TEMP_DIR" >"$TEMP_RECORD"'
	# shellcheck disable=SC2016 # Literal shell code for the fixture.
	printf '%s\n' '[[ "${FAIL_FIXTURE:-false}" == true ]] && false'
	printf '%s\n' 'info "fixture complete"'
} >"$core_fixture"
chmod +x "$core_fixture"

success_record="$tmp_dir/success-temp"
success_output=$(TEMP_RECORD="$success_record" "$core_fixture")
expected_success_output=$'\n✨ core-test ✨\n[core-test] fixture complete'
if [[ "$success_output" != "$expected_success_output" ]]; then
	printf 'unexpected core output:\n%s\n' "$success_output" >&2
	exit 1
fi
success_temp=$(<"$success_record")
[[ ! -d "$success_temp" ]]

failure_record="$tmp_dir/failure-temp"
set +e
failure_output=$(
	TEMP_RECORD="$failure_record" FAIL_FIXTURE=true "$core_fixture" 2>&1
)
failure_status=$?
set -e
[[ $failure_status -ne 0 ]]
rg -q '\[core-test\] ERROR line [0-9]+: false \(status [0-9]+\)' \
	<<<"$failure_output"
failure_temp=$(<"$failure_record")
[[ ! -d "$failure_temp" ]]

base_data_file="$tmp_dir/base.json"
chezmoi -S "$source_dir" data >"$base_data_file"

imperative_source="$source_dir/.chezmoiscripts/run_after_70-imperative-cli-tools.sh.tmpl"
imperative_default_fixture="$tmp_dir/imperative-default.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$base_data_file" \
	--file "$imperative_source" >"$imperative_default_fixture"
chmod +x "$imperative_default_fixture"
rg -q 'herdr plugin install qu8n/herdr-automatic-rename --yes' \
	"$imperative_default_fixture"
rg -q 'plugin_id == \\"jhochenbaum.hunkdiff\\"' \
	"$imperative_default_fixture"
rg -q 'skills add DietrichGebert/ponytail --skill ponytail' \
	"$imperative_default_fixture"
rg -q 'skills add JuliusBrussee/caveman --skill caveman' \
	"$imperative_default_fixture"

imperative_data="$tmp_dir/imperative-behavior.json"
jq \
	--argjson operations '[
      {
        "name": "primary operation",
        "cli": "fake-cli",
        "check": "fake-cli check",
        "run": "fake-cli run"
      },
      {
        "name": "later operation",
        "cli": "fake-cli",
        "check": "fake-cli later-check",
        "run": "fake-cli later-run"
      }
    ]' \
	'.imperative_cli_tools = $operations' \
	"$base_data_file" >"$imperative_data"

imperative_fixture="$tmp_dir/imperative-behavior.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$imperative_data" \
	--file "$imperative_source" >"$imperative_fixture"
chmod +x "$imperative_fixture"

imperative_fake_bin="$tmp_dir/imperative-fake-bin"
mkdir -p "$imperative_fake_bin"
cat >"$imperative_fake_bin/fake-cli" <<'STUB'
#!/usr/bin/env bash
set -u

printf 'fake-cli %s\n' "$*" >>"$COMMAND_LOG"

case "${1:-}" in
    check|later-check)
        [[ "${FAKE_CHECK_STATUS:-0}" -eq 0 ]]
        ;;
    run)
        [[ "${FAKE_FAIL_RUN:-false}" != true ]]
        ;;
    later-run)
        exit 0
        ;;
    *)
        exit 64
        ;;
esac
STUB
chmod +x "$imperative_fake_bin/fake-cli"

COMMAND_LOG="$tmp_dir/imperative-missing-cli.log"
: >"$COMMAND_LOG"
PATH="/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$imperative_fixture" >"$tmp_dir/imperative-missing-cli.out"
assert_file_contains "$tmp_dir/imperative-missing-cli.out" \
	'fake-cli is not installed'
if [[ -s "$COMMAND_LOG" ]]; then
	printf 'missing CLI should not run any command\n' >&2
	exit 1
fi

COMMAND_LOG="$tmp_dir/imperative-check-success.log"
: >"$COMMAND_LOG"
PATH="$imperative_fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$imperative_fixture" >"$tmp_dir/imperative-check-success.out"
assert_file_contains "$tmp_dir/imperative-check-success.out" \
	'primary operation: already satisfied'
assert_file_contains "$tmp_dir/imperative-check-success.out" \
	'later operation: already satisfied'
assert_log_contains 'fake-cli check'
assert_log_contains 'fake-cli later-check'
if rg -q 'fake-cli (run|later-run)' "$COMMAND_LOG"; then
	printf 'successful checks should skip run commands\n' >&2
	exit 1
fi

COMMAND_LOG="$tmp_dir/imperative-check-failure.log"
: >"$COMMAND_LOG"
PATH="$imperative_fake_bin:/usr/bin:/bin" \
	FAKE_CHECK_STATUS=1 \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$imperative_fixture" >"$tmp_dir/imperative-check-failure.out"
assert_log_contains 'fake-cli run'
assert_log_contains 'fake-cli later-run'

COMMAND_LOG="$tmp_dir/imperative-run-failure.log"
: >"$COMMAND_LOG"
set +e
PATH="$imperative_fake_bin:/usr/bin:/bin" \
	FAKE_CHECK_STATUS=1 \
	FAKE_FAIL_RUN=true \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$imperative_fixture" >"$tmp_dir/imperative-run-failure.out" 2>&1
imperative_failure_status=$?
set -e
[[ $imperative_failure_status -ne 0 ]]
assert_log_contains 'fake-cli run'
if rg -q 'fake-cli (later-check|later-run)' "$COMMAND_LOG"; then
	printf 'failed run should stop later operations\n' >&2
	exit 1
fi

arch_data="$tmp_dir/arch.json"
jq \
	--arg os linux \
	--arg distribution arch \
	--arg architecture amd64 \
	'.chezmoi.os = $os
     | .chezmoi.osRelease.id = $distribution
     | .chezmoi.arch = $architecture
     | .features = {
         development: true,
         personal: true,
         homelab: false,
         graphical: true
       }
     | .secrets.provider = "none"
     | .encrypted_files.enabled = false' \
	"$base_data_file" >"$arch_data"

bootstrap_fixture="$tmp_dir/arch-bootstrap.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$arch_data" \
	--file "$source_dir/.chezmoiscripts/run_once_before_00-bootstrap.sh.tmpl" \
	>"$bootstrap_fixture"
chmod +x "$bootstrap_fixture"

fake_bin="$tmp_dir/fake-bin"
mkdir -p "$fake_bin"
write_fake_command() {
	local command_name=$1
	local command_body=$2
	printf '%s\n%s\n' '#!/bin/bash' "$command_body" >"$fake_bin/$command_name"
	chmod +x "$fake_bin/$command_name"
}

for command_name in curl unzip wget; do
	write_fake_command "$command_name" 'exit 0'
done
# shellcheck disable=SC2016 # Expand these variables inside the generated stubs.
write_fake_command sudo 'printf "sudo %s\\n" "$*" >>"$COMMAND_LOG"; exec "$@"'
# shellcheck disable=SC2016 # Expand these variables inside the generated stubs.
write_fake_command pacman 'printf "pacman %s\\n" "$*" >>"$COMMAND_LOG"'
# shellcheck disable=SC2016 # Expand these variables inside the generated stubs.
write_fake_command git 'printf "git %s\\n" "$*" >>"$COMMAND_LOG"; mkdir -p "${@: -1}"'
# shellcheck disable=SC2016 # Expand these variables inside the generated stubs.
write_fake_command makepkg 'printf "makepkg %s\\n" "$*" >>"$COMMAND_LOG"; printf "%s\\n%s\\n" "#!/bin/bash" "exit 0" >"$FAKE_BIN/paru"; chmod +x "$FAKE_BIN/paru"'

COMMAND_LOG="$tmp_dir/commands.log"
PATH="$fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	FAKE_BIN="$fake_bin" \
	/bin/bash "$bootstrap_fixture"

assert_log_contains 'pacman -S --needed --noconfirm git base-devel'
assert_log_contains 'git clone --depth 1 https://aur.archlinux.org/paru.git'
assert_log_contains 'makepkg -si --noconfirm'

system_source="$source_dir/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl"
system_fake_bin="$tmp_dir/system-fake-bin"
mkdir -p "$system_fake_bin"
manager_stub="$system_fake_bin/manager-stub"
cat >"$manager_stub" <<'STUB'
#!/usr/bin/env bash
set -u
manager=${0##*/}
printf '%s %s\n' "$manager" "$*" >>"$COMMAND_LOG"

case "$manager:$*" in
    sudo:*) exec "$@" ;;
    brew:list*package-remove-fail*) exit 0 ;;
    brew:uninstall*package-remove-fail*|apt-get:remove*package-remove-fail*|paru:-R*package-remove-fail*) exit 42 ;;
    brew:list*) exit 1 ;;
    brew:*package-fail*|apt-get:*package-fail*|paru:*package-fail*) exit 42 ;;
    dpkg-query:*package-remove-fail*) printf 'ii \n' ;;
    dpkg-query:*) exit 1 ;;
    apt-cache:show*) exit 0 ;;
    pacman:-Q*package-remove-fail*) exit 0 ;;
    pacman:-Q*) exit 1 ;;
    paru:-Si*) exit 0 ;;
    mas:list*) exit 0 ;;
    *) exit 0 ;;
esac
STUB
chmod +x "$manager_stub"
for command_name in brew mas sudo apt-get apt-cache dpkg-query pacman paru eza; do
	ln -s manager-stub "$system_fake_bin/$command_name"
done

for profile in mac ubuntu arch; do
	system_data="$tmp_dir/$profile-system.json"
	case "$profile" in
	mac)
		jq \
			--argjson packages '["package-ok", "package-fail", "package-never"]' \
			'.chezmoi.os = "darwin"
             | .chezmoi.osRelease.id = "darwin"
             | .features = {
                 development: true,
                 personal: false,
                 homelab: false,
                 graphical: false
               }
             | .packages.homebrew.to_remove = []
             | .packages.homebrew.development.formulae = $packages
             | .packages.homebrew.development.casks = []' \
			"$base_data_file" >"$system_data"
		;;
	ubuntu)
		jq \
			--argjson packages '["package-ok", "package-fail", "package-never"]' \
			'.chezmoi.os = "linux"
             | .chezmoi.osRelease.id = "ubuntu"
             | .features = {
                 development: false,
                 personal: false,
                 homelab: false,
                 graphical: false
               }
             | .packages.apt.to_remove = []
             | .packages.apt.common.packages = $packages' \
			"$base_data_file" >"$system_data"
		;;
	arch)
		jq \
			--argjson packages '["package-ok", "package-fail", "package-never"]' \
			'.chezmoi.os = "linux"
             | .chezmoi.osRelease.id = "arch"
             | .features = {
                 development: false,
                 personal: false,
                 homelab: false,
                 graphical: false
               }
             | .packages.pacman.to_remove = []
             | .packages.pacman.common.packages = $packages' \
			"$base_data_file" >"$system_data"
		;;
	esac

	system_fixture="$tmp_dir/$profile-system.sh"
	chezmoi -S "$source_dir" execute-template \
		--override-data-file "$system_data" \
		--file "$system_source" >"$system_fixture"
	chmod +x "$system_fixture"

	COMMAND_LOG="$tmp_dir/$profile-system.log"
	: >"$COMMAND_LOG"
	set +e
	PATH="$system_fake_bin:/usr/bin:/bin" \
		CI=true \
		COMMAND_LOG="$COMMAND_LOG" \
		/bin/bash "$system_fixture" >"$tmp_dir/$profile-system.out" 2>&1
	status=$?
	set -e

	[[ $status -ne 0 ]]
	rg -q 'package-ok' "$COMMAND_LOG"
	rg -q 'package-fail' "$COMMAND_LOG"
	if rg -q 'package-never' "$COMMAND_LOG"; then
		printf 'manager continued after package-fail\n' >&2
		exit 1
	fi

	removal_data="$tmp_dir/$profile-removal.json"
	case "$profile" in
	mac)
		jq \
			'.packages.homebrew.to_remove = ["package-remove-fail"]
             | .packages.homebrew.development.formulae = ["package-removal-sentinel"]' \
			"$system_data" >"$removal_data"
		;;
	ubuntu)
		jq \
			'.packages.apt.to_remove = ["package-remove-fail"]
             | .packages.apt.common.packages = ["package-removal-sentinel"]' \
			"$system_data" >"$removal_data"
		;;
	arch)
		jq \
			'.packages.pacman.to_remove = ["package-remove-fail"]
             | .packages.pacman.common.packages = ["package-removal-sentinel"]' \
			"$system_data" >"$removal_data"
		;;
	esac

	chezmoi -S "$source_dir" execute-template \
		--override-data-file "$removal_data" \
		--file "$system_source" >"$system_fixture"
	COMMAND_LOG="$tmp_dir/$profile-removal.log"
	: >"$COMMAND_LOG"
	set +e
	PATH="$system_fake_bin:/usr/bin:/bin" \
		CI=true \
		COMMAND_LOG="$COMMAND_LOG" \
		/bin/bash "$system_fixture" >"$tmp_dir/$profile-removal.out" 2>&1
	status=$?
	set -e

	[[ $status -ne 0 ]]
	rg -q 'package-remove-fail' "$COMMAND_LOG"
	if rg -q 'package-removal-sentinel' "$COMMAND_LOG"; then
		printf 'manager continued after package-remove-fail\n' >&2
		exit 1
	fi
done

mas_required_data="$tmp_dir/mas-required.json"
jq \
	'.chezmoi.os = "darwin"
     | .chezmoi.osRelease.id = "darwin"
     | .features = {
         development: true,
         personal: false,
         homelab: false,
         graphical: true
       }
     | .packages.homebrew.to_remove = []
     | .packages.homebrew.development.formulae = []
     | .packages.homebrew.development.casks = []
     | .packages.mas.common.apps = ["123456789"]' \
	"$base_data_file" >"$mas_required_data"
mas_required_fixture="$tmp_dir/mas-required.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$mas_required_data" \
	--file "$system_source" >"$mas_required_fixture"
# shellcheck disable=SC2016 # Literal shell code appended to the fixture.
printf '%s\n' 'printf "mas-sentinel\n" >>"$COMMAND_LOG"' \
	>>"$mas_required_fixture"
chmod +x "$mas_required_fixture"

mas_missing_bin="$tmp_dir/mas-missing-bin"
mkdir -p "$mas_missing_bin"
ln -s "$manager_stub" "$mas_missing_bin/brew"
COMMAND_LOG="$tmp_dir/mas-required.log"
: >"$COMMAND_LOG"
set +e
PATH="$mas_missing_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$mas_required_fixture" >"$tmp_dir/mas-required.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
rg -Fq 'required command not found: mas' "$tmp_dir/mas-required.out"
if rg -Fq 'mas-sentinel' "$COMMAND_LOG"; then
	printf 'system phase continued after required mas was missing\n' >&2
	exit 1
fi

mas_optional_data="$tmp_dir/mas-optional.json"
jq '.packages.mas.common.apps = []' "$mas_required_data" >"$mas_optional_data"
mas_optional_fixture="$tmp_dir/mas-optional.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$mas_optional_data" \
	--file "$system_source" >"$mas_optional_fixture"
chmod +x "$mas_optional_fixture"
PATH="$mas_missing_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$mas_optional_fixture"

runtime_source="$source_dir/.chezmoiscripts/run_onchange_after_20-language-runtimes.sh.tmpl"
language_source="$source_dir/.chezmoiscripts/run_onchange_after_30-language-packages.sh.tmpl"
language_data="$tmp_dir/language.json"
jq \
	'.chezmoi.os = "linux"
     | .chezmoi.osRelease.id = "ubuntu"
     | .features = {
         development: true,
         personal: false,
         homelab: false,
         graphical: false
       }
     | .runtimes = [
         {name: "node", version: "latest", features: ["development"]}
       ]
     | .packages.python.to_remove = []
     | .packages.python.common.packages = ["python-tool"]
     | .packages.python.development.packages = []
     | .packages.python.homelab.packages = []
     | .packages.python.personal.packages = []
     | .packages.node.to_remove = []
     | .packages.node.common.packages = ["node-tool"]
     | .packages.node.development.packages = []
     | .packages.node.homelab.packages = []
     | .packages.node.personal.packages = []
     | .packages.cargo.to_remove = []
     | .packages.cargo.common.packages = ["cargo-tool"]
     | .packages.cargo.development.packages = []
     | .packages.cargo.homelab.packages = []
     | .packages.cargo.personal.packages = []' \
	"$base_data_file" >"$language_data"

runtime_fixture="$tmp_dir/language-runtime.sh"
language_fixture="$tmp_dir/language-packages.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$language_data" \
	--file "$runtime_source" >"$runtime_fixture"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$language_data" \
	--file "$language_source" >"$language_fixture"
chmod +x "$runtime_fixture" "$language_fixture"

language_fake_bin="$tmp_dir/language-fake-bin"
mkdir -p "$language_fake_bin"
language_stub="$language_fake_bin/language-stub"
cat >"$language_stub" <<'STUB'
#!/usr/bin/env bash
set -u
manager=${0##*/}
printf '%s %s\n' "$manager" "$*" >>"$COMMAND_LOG"

case "$manager:$*" in
    uv:"tool list"*) exit 0 ;;
    npm:"list -g"*) exit 1 ;;
    cargo:"install --list"*) exit 0 ;;
    npm:*node-tool*)
        [[ "${FAIL_NPM:-false}" == true ]] && exit 42
        ;;
esac
exit 0
STUB
chmod +x "$language_stub"
for command_name in proto uv node npm go rustc cargo bun deno taplo; do
	ln -s language-stub "$language_fake_bin/$command_name"
done
language_proto_home="$tmp_dir/proto-home"
language_home="$tmp_dir/language-home"
mkdir -p "$language_proto_home/bin" "$language_proto_home/shims" "$language_home"
ln -s "$language_stub" "$language_proto_home/bin/proto"

COMMAND_LOG="$tmp_dir/language-commands.log"
: >"$COMMAND_LOG"
HOME="$language_home" \
PROTO_HOME="$language_proto_home" \
	PATH="$language_fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$runtime_fixture"
HOME="$language_home" \
PROTO_HOME="$language_proto_home" \
	PATH="$language_fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$language_fixture"

proto_line=$(rg -n 'proto install node latest --pin global -- --bundled-npm' "$COMMAND_LOG" | cut -d: -f1)
uv_line=$(rg -n 'uv tool install python-tool' "$COMMAND_LOG" | cut -d: -f1)
npm_line=$(rg -n 'npm install -g node-tool' "$COMMAND_LOG" | cut -d: -f1)
cargo_line=$(rg -n 'cargo install cargo-tool' "$COMMAND_LOG" | cut -d: -f1)

((proto_line < uv_line))
((uv_line < npm_line))
((npm_line < cargo_line))

: >"$COMMAND_LOG"
HOME="$language_home" \
PROTO_HOME="$language_proto_home" \
	PATH="$language_fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$runtime_fixture"
set +e
HOME="$language_home" \
PROTO_HOME="$language_proto_home" \
	PATH="$language_fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	FAIL_NPM=true \
	/bin/bash "$language_fixture" >"$tmp_dir/language-failure.out" 2>&1
status=$?
set -e

[[ $status -ne 0 ]]
assert_log_contains 'npm install -g node-tool'
if rg -Fq 'cargo install cargo-tool' "$COMMAND_LOG"; then
	printf 'cargo continued after npm install failure\n' >&2
	exit 1
fi

standalone_source="$source_dir/.chezmoiscripts/run_onchange_after_40-standalone-tools.sh.tmpl"
standalone_data="$tmp_dir/standalone.json"
jq \
	'.chezmoi.os = "linux"
     | .chezmoi.osRelease.id = "ubuntu"
     | .chezmoi.arch = "amd64"
     | .features = {
         development: false,
         personal: false,
         homelab: false,
         graphical: false
       }
     | .binaries |= with_entries(.value.systems = [])
     | .binaries.sample = {
           name: "sample",
           repository: "example/sample",
           systems: ["linux"],
           required_architecture: "",
           install_filter: "",
           executable_name: "sample",
           version_regex: "",
           remove_from_release: ""
       }' \
	"$base_data_file" >"$standalone_data"

standalone_fixture="$tmp_dir/standalone-tools.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$standalone_data" \
	--file "$standalone_source" >"$standalone_fixture"
chmod +x "$standalone_fixture"

release_json_fixture="$tmp_dir/release.json"
cat >"$release_json_fixture" <<'JSON'
{
  "tag_name": "v1.2.3",
  "prerelease": false,
  "draft": false,
  "assets": [
    {
      "name": "sample-v1.2.3-x86_64-unknown-linux-gnu.tar.gz",
      "browser_download_url": "https://fixtures.invalid/sample.tar.gz"
    },
    {
      "name": "SHA256SUMS",
      "browser_download_url": "https://fixtures.invalid/SHA256SUMS"
    }
  ]
}
JSON

fixture_root="$tmp_dir/release-fixture"
mkdir -p "$fixture_root/sample-v1.2.3"
cat >"$fixture_root/sample-v1.2.3/sample" <<'SAMPLE'
#!/usr/bin/env bash
printf 'sample 1.2.3\n'
SAMPLE
chmod +x "$fixture_root/sample-v1.2.3/sample"
ARCHIVE_FIXTURE="$tmp_dir/sample.tar.gz"
tar -czf "$ARCHIVE_FIXTURE" -C "$fixture_root" sample-v1.2.3
CHECKSUM_FIXTURE="$tmp_dir/SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
	digest=$(sha256sum "$ARCHIVE_FIXTURE" | awk '{print $1}')
else
	digest=$(shasum -a 256 "$ARCHIVE_FIXTURE" | awk '{print $1}')
fi
printf '%s  %s\n' "$digest" sample.tar.gz >"$CHECKSUM_FIXTURE"
export ARCHIVE_FIXTURE CHECKSUM_FIXTURE

standalone_fake_bin="$tmp_dir/standalone-fake-bin"
mkdir -p "$standalone_fake_bin"
cat >"$standalone_fake_bin/curl" <<'STUB'
#!/usr/bin/env bash
set -u
printf 'curl %s\n' "$*" >>"$COMMAND_LOG"
output_file=""
url=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            output_file=$2
            shift 2
            ;;
        -H)
            shift 2
            ;;
        --fail|--show-error|--silent|--location|--retry)
            if [[ "$1" == --retry ]]; then shift 2; else shift; fi
            ;;
        http*) url=$1; shift ;;
        *) shift ;;
    esac
done

case "$url" in
    */git-ecosystem/git-credential-manager/releases/latest)
        cat "$GCM_RELEASE_JSON_FIXTURE"
        ;;
    */releases/latest) cat "$RELEASE_JSON_FIXTURE" ;;
    */gcm-linux-x64.deb) cp "$GCM_DEB_FIXTURE" "$output_file" ;;
    */sample.tar.gz) cp "$ARCHIVE_FIXTURE" "$output_file" ;;
    */SHA256SUMS) cp "$CHECKSUM_FIXTURE" "$output_file" ;;
    */sample.tar.gz.sha256) cp "$CHECKSUM_FIXTURE" "$output_file" ;;
    *) exit 64 ;;
esac
STUB
chmod +x "$standalone_fake_bin/curl"
for command_name in awk bash cat chmod cp find grep head jq mkdir mktemp mv rm \
	sha256sum shasum tar touch; do
	command_path=$(command -v "$command_name") || continue
	ln -s "$command_path" "$standalone_fake_bin/$command_name"
done

COMMAND_LOG="$tmp_dir/standalone-commands.log"
: >"$COMMAND_LOG"
standalone_home="$tmp_dir/standalone-home"
PATH="$standalone_fake_bin" \
	HOME="$standalone_home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$release_json_fixture" \
	/bin/bash "$standalone_fixture" >"$tmp_dir/standalone-success.out" 2>&1 || {
	cat "$tmp_dir/standalone-success.out" >&2
	exit 1
}

[[ -x "$standalone_home/.local/bin/sample" ]]
"$standalone_home/.local/bin/sample" --version | rg -q '^sample 1.2.3$'
assert_log_contains 'releases/latest'
assert_log_contains 'sample.tar.gz'
assert_log_contains 'SHA256SUMS'

per_archive_release_json="$tmp_dir/release-with-per-archive-checksum.json"
jq '.assets[1].name = "other.tar.gz.sha256"
    | .assets[1].browser_download_url = "https://fixtures.invalid/other.tar.gz.sha256"
    | .assets += [{
          name: "sample.tar.gz.sha256",
          browser_download_url: "https://fixtures.invalid/sample.tar.gz.sha256"
       }]' \
	"$release_json_fixture" >"$per_archive_release_json"
per_archive_home="$tmp_dir/per-archive-checksum-home"
: >"$COMMAND_LOG"
PATH="$standalone_fake_bin" \
	HOME="$per_archive_home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$per_archive_release_json" \
	CHECKSUM_FIXTURE="$CHECKSUM_FIXTURE" \
	/bin/bash "$standalone_fixture" >"$tmp_dir/per-archive-checksum.out" 2>&1 || {
	cat "$tmp_dir/per-archive-checksum.out" >&2
	exit 1
}
[[ -x "$per_archive_home/.local/bin/sample" ]]
"$per_archive_home/.local/bin/sample" --version |
	rg -q '^sample 1.2.3$'
assert_log_contains 'sample.tar.gz.sha256'

wrong_checksum_fixture="$tmp_dir/wrong-SHA256SUMS"
printf '%064d  sample.tar.gz\n' 0 >"$wrong_checksum_fixture"
: >"$COMMAND_LOG"
set +e
PATH="$standalone_fake_bin" \
	HOME="$tmp_dir/wrong-checksum-home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$release_json_fixture" \
	CHECKSUM_FIXTURE="$wrong_checksum_fixture" \
	/bin/bash "$standalone_fixture" >"$tmp_dir/wrong-checksum.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
[[ ! -e "$tmp_dir/wrong-checksum-home/.local/bin/sample" ]]

checksumless_release_json="$tmp_dir/release-without-checksum.json"
jq 'del(.assets[1])' "$release_json_fixture" >"$checksumless_release_json"
: >"$COMMAND_LOG"
set +e
PATH="$standalone_fake_bin" \
	HOME="$tmp_dir/checksumless-home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$checksumless_release_json" \
	/bin/bash "$standalone_fixture" >"$tmp_dir/checksumless.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
[[ ! -e "$tmp_dir/checksumless-home/.local/bin/sample" ]]

no_op_home="$tmp_dir/no-op-home"
mkdir -p "$no_op_home/.local/bin"
cp "$standalone_home/.local/bin/sample" "$no_op_home/.local/bin/sample"
: >"$COMMAND_LOG"
PATH="$no_op_home/.local/bin:$standalone_fake_bin" \
	HOME="$no_op_home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$release_json_fixture" \
	/bin/bash "$standalone_fixture"
[[ ! -s "$COMMAND_LOG" ]]

bad_fixture_root="$tmp_dir/bad-release-fixture"
mkdir -p "$bad_fixture_root/sample-v1.2.3"
cat >"$bad_fixture_root/sample-v1.2.3/sample" <<'SAMPLE'
#!/usr/bin/env bash
exit 42
SAMPLE
chmod +x "$bad_fixture_root/sample-v1.2.3/sample"
bad_archive_fixture="$tmp_dir/bad-sample.tar.gz"
tar -czf "$bad_archive_fixture" -C "$bad_fixture_root" sample-v1.2.3
bad_checksum_fixture="$tmp_dir/bad-SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
	bad_digest=$(sha256sum "$bad_archive_fixture" | awk '{print $1}')
else
	bad_digest=$(shasum -a 256 "$bad_archive_fixture" | awk '{print $1}')
fi
printf '%s  %s\n' "$bad_digest" sample.tar.gz >"$bad_checksum_fixture"

verification_retry_home="$tmp_dir/verification-retry-home"
: >"$COMMAND_LOG"
set +e
PATH="$standalone_fake_bin" \
	HOME="$verification_retry_home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$release_json_fixture" \
	ARCHIVE_FIXTURE="$bad_archive_fixture" \
	CHECKSUM_FIXTURE="$bad_checksum_fixture" \
	/bin/bash "$standalone_fixture" \
	>"$tmp_dir/verification-failure.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
[[ ! -e "$verification_retry_home/.local/bin/sample" ]]
if find "$verification_retry_home/.local/bin" -name '.sample.*' \
	-print -quit | rg -q .; then
	printf 'failed standalone verification left a staged executable\n' >&2
	exit 1
fi

: >"$COMMAND_LOG"
PATH="$standalone_fake_bin" \
	HOME="$verification_retry_home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$release_json_fixture" \
	ARCHIVE_FIXTURE="$ARCHIVE_FIXTURE" \
	CHECKSUM_FIXTURE="$CHECKSUM_FIXTURE" \
	/bin/bash "$standalone_fixture"
[[ -x "$verification_retry_home/.local/bin/sample" ]]
"$verification_retry_home/.local/bin/sample" --version |
	rg -q '^sample 1.2.3$'
assert_log_contains 'releases/latest'

invalid_existing_home="$tmp_dir/invalid-existing-home"
mkdir -p "$invalid_existing_home/.local/bin"
cp "$bad_fixture_root/sample-v1.2.3/sample" \
	"$invalid_existing_home/.local/bin/sample"
: >"$COMMAND_LOG"
PATH="$invalid_existing_home/.local/bin:$standalone_fake_bin" \
	HOME="$invalid_existing_home" \
	COMMAND_LOG="$COMMAND_LOG" \
	RELEASE_JSON_FIXTURE="$release_json_fixture" \
	ARCHIVE_FIXTURE="$ARCHIVE_FIXTURE" \
	CHECKSUM_FIXTURE="$CHECKSUM_FIXTURE" \
	/bin/bash "$standalone_fixture"
"$invalid_existing_home/.local/bin/sample" --version |
	rg -q '^sample 1.2.3$'
assert_log_contains 'releases/latest'

cat >"$standalone_fake_bin/sudo" <<'STUB'
#!/usr/bin/env bash
set -u
printf 'sudo %s\n' "$*" >>"$COMMAND_LOG"
exec "$@"
STUB
cat >"$standalone_fake_bin/dpkg" <<'STUB'
#!/usr/bin/env bash
set -u
printf 'dpkg %s\n' "$*" >>"$COMMAND_LOG"
touch "$GCM_INSTALLED_RECORD"
STUB
cat >"$standalone_fake_bin/git" <<'STUB'
#!/usr/bin/env bash
set -u
if [[ "$1" == credential-manager && "${2:-}" == --version ]]; then
    [[ -e "$GCM_INSTALLED_RECORD" ]] && exit 0
    exit 1
fi
exit 64
STUB
chmod +x "$standalone_fake_bin/sudo" "$standalone_fake_bin/dpkg" \
	"$standalone_fake_bin/git"

gcm_data="$tmp_dir/gcm.json"
jq \
	'.features.development = true
     | .binaries |= with_entries(.value.systems = [])' \
	"$standalone_data" >"$gcm_data"
gcm_fixture="$tmp_dir/gcm-standalone-tools.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$gcm_data" \
	--file "$standalone_source" >"$gcm_fixture"
chmod +x "$gcm_fixture"

GCM_DEB_FIXTURE="$tmp_dir/gcm-linux-x64.deb"
printf 'gcm package fixture\n' >"$GCM_DEB_FIXTURE"
if command -v sha256sum >/dev/null 2>&1; then
	gcm_digest=$(sha256sum "$GCM_DEB_FIXTURE" | awk '{print $1}')
else
	gcm_digest=$(shasum -a 256 "$GCM_DEB_FIXTURE" | awk '{print $1}')
fi
gcm_release_json="$tmp_dir/gcm-release.json"
cat >"$gcm_release_json" <<JSON
{
  "assets": [
    {
      "name": "gcm-linux-x64.deb",
      "browser_download_url": "https://fixtures.invalid/gcm-linux-x64.deb",
      "digest": "sha256:$gcm_digest"
    }
  ]
}
JSON

COMMAND_LOG="$tmp_dir/gcm-commands.log"
gcm_installed_record="$tmp_dir/gcm-installed"
: >"$COMMAND_LOG"
PATH="$standalone_fake_bin" \
	HOME="$tmp_dir/gcm-home" \
	COMMAND_LOG="$COMMAND_LOG" \
	GCM_DEB_FIXTURE="$GCM_DEB_FIXTURE" \
	GCM_INSTALLED_RECORD="$gcm_installed_record" \
	GCM_RELEASE_JSON_FIXTURE="$gcm_release_json" \
	/bin/bash "$gcm_fixture"
assert_log_contains 'dpkg -i'
[[ -e "$gcm_installed_record" ]]

assert_gcm_rejects_digest() {
	local release_fixture=$1
	local label=$2
	local installed_record="$tmp_dir/gcm-$label-installed"

	: >"$COMMAND_LOG"
	set +e
	PATH="$standalone_fake_bin" \
		HOME="$tmp_dir/gcm-$label-home" \
		COMMAND_LOG="$COMMAND_LOG" \
		GCM_DEB_FIXTURE="$GCM_DEB_FIXTURE" \
		GCM_INSTALLED_RECORD="$installed_record" \
		GCM_RELEASE_JSON_FIXTURE="$release_fixture" \
		/bin/bash "$gcm_fixture" >"$tmp_dir/gcm-$label.out" 2>&1
	status=$?
	set -e
	[[ $status -ne 0 ]]
	[[ ! -e "$installed_record" ]]
	if rg -Fq 'dpkg -i' "$COMMAND_LOG"; then
		printf 'GCM dpkg ran with %s digest\n' "$label" >&2
		exit 1
	fi
}

wrong_gcm_digest_json="$tmp_dir/gcm-wrong-digest.json"
jq '.assets[0].digest = "sha256:0000000000000000000000000000000000000000000000000000000000000000"' \
	"$gcm_release_json" >"$wrong_gcm_digest_json"
assert_gcm_rejects_digest "$wrong_gcm_digest_json" wrong

malformed_gcm_digest_json="$tmp_dir/gcm-malformed-digest.json"
jq '.assets[0].digest = "sha512:not-a-sha256"' "$gcm_release_json" \
	>"$malformed_gcm_digest_json"
assert_gcm_rejects_digest "$malformed_gcm_digest_json" malformed

missing_gcm_digest_json="$tmp_dir/gcm-missing-digest.json"
jq 'del(.assets[0].digest)' "$gcm_release_json" >"$missing_gcm_digest_json"
assert_gcm_rejects_digest "$missing_gcm_digest_json" missing

post_install_source="$source_dir/.chezmoiscripts/run_once_after_50-post-install.sh.tmpl"
post_install_data="$tmp_dir/post-install.json"
post_install_home="$tmp_dir/post-install-home"
jq \
	--arg data_home "$post_install_home/.local/share" \
	'.chezmoi.os = "linux"
     | .chezmoi.osRelease.id = "ubuntu"
     | .xdg.data_home = $data_home
     | .secrets.provider = "none"' \
	"$base_data_file" >"$post_install_data"
post_install_fixture="$tmp_dir/post-install.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$post_install_data" \
	--file "$post_install_source" >"$post_install_fixture"
chmod +x "$post_install_fixture"

render_post_install_fixture() {
	local home=$1
	local fixture=$2
	local data_file="$fixture.json"
	jq --arg data_home "$home/.local/share" \
		'.xdg.data_home = $data_home' "$post_install_data" >"$data_file"
	chezmoi -S "$source_dir" execute-template \
		--override-data-file "$data_file" \
		--file "$post_install_source" >"$fixture"
	chmod +x "$fixture"
}

post_install_fake_bin="$tmp_dir/post-install-fake-bin"
mkdir -p "$post_install_fake_bin"
cat >"$post_install_fake_bin/git" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'git %s\n' "$*" >>"$COMMAND_LOG"
target=""
for argument in "$@"; do
    target=$argument
done
mkdir -p "$target"
printf '%s\n' '# antidote fixture' >"$target/antidote.zsh"
STUB
cat >"$post_install_fake_bin/curl" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'curl %s\n' "$*" >>"$COMMAND_LOG"
while [[ $# -gt 0 ]]; do
    case "$1" in
    --output)
        : >"$2"
        exit 0
        ;;
    *)
        shift
        ;;
    esac
done
exit 64
STUB
cat >"$post_install_fake_bin/unzip" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'unzip %s\n' "$*" >>"$COMMAND_LOG"
destination=""
while [[ $# -gt 0 ]]; do
    case "$1" in
    -d)
        destination=$2
        shift 2
        ;;
    *)
        shift
        ;;
    esac
done
mkdir -p "$destination/nanorc-master"
printf '%s\n' 'include ~/.nanorc' >"$destination/nanorc-master/conf.nanorc"
STUB
cat >"$post_install_fake_bin/cp" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'cp %s\n' "$*" >>"$COMMAND_LOG"
if [[ "${FAIL_NANORC_COPY:-false}" == true &&
    "$*" == *nanorc-master* ]]; then
    source_directory=${2%/.}
    destination=$3
    mkdir -p "$destination"
    /bin/cp "$source_directory/conf.nanorc" "$destination/conf.nanorc"
    exit 42
fi
exec /bin/cp "$@"
STUB
for command_name in batcat fdfind; do
	printf '%s\n%s\n' '#!/usr/bin/env bash' 'exit 0' \
		>"$post_install_fake_bin/$command_name"
	chmod +x "$post_install_fake_bin/$command_name"
done
chmod +x "$post_install_fake_bin/git" "$post_install_fake_bin/curl" \
	"$post_install_fake_bin/unzip" "$post_install_fake_bin/cp"

COMMAND_LOG="$tmp_dir/post-install-commands.log"
: >"$COMMAND_LOG"
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_home" \
	ZDOTDIR="$post_install_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_fixture"
assert_log_contains 'git clone --depth 1 https://github.com/mattmc3/antidote.git'
assert_log_contains 'curl --fail --show-error --silent --location --retry 3'
assert_log_contains 'unzip -q'
[[ -L "$post_install_home/.local/bin/bat" ]]
[[ -L "$post_install_home/.local/bin/fd" ]]
[[ -f "$post_install_home/.config/zsh/.antidote/antidote.zsh" ]]
[[ -f "$post_install_home/.local/share/nano/.chezmoi-complete" ]]

: >"$COMMAND_LOG"
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_home" \
	ZDOTDIR="$post_install_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_fixture"
[[ ! -s "$COMMAND_LOG" ]] || {
	printf 'post-install phase made clone or network calls on second run\n' >&2
	exit 1
}
[[ -L "$post_install_home/.local/bin/bat" ]]
[[ -L "$post_install_home/.local/bin/fd" ]]

post_install_partial_home="$tmp_dir/post-install-partial-home"
post_install_partial_fixture="$tmp_dir/post-install-partial.sh"
render_post_install_fixture "$post_install_partial_home" \
	"$post_install_partial_fixture"
mkdir -p "$post_install_partial_home/.config/zsh/.antidote" \
	"$post_install_partial_home/.local/share/nano"
printf '%s\n' 'incomplete nanorc fixture' \
	>"$post_install_partial_home/.local/share/nano/conf.nanorc"
COMMAND_LOG="$tmp_dir/post-install-partial-commands.log"
: >"$COMMAND_LOG"
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_partial_home" \
	ZDOTDIR="$post_install_partial_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_partial_fixture"
assert_log_contains 'git clone --depth 1 https://github.com/mattmc3/antidote.git'
assert_log_contains 'curl --fail --show-error --silent --location --retry 3'
[[ -f "$post_install_partial_home/.config/zsh/.antidote/antidote.zsh" ]]
[[ -f "$post_install_partial_home/.local/share/nano/.chezmoi-complete" ]]

post_install_copy_retry_home="$tmp_dir/post-install-copy-retry-home"
post_install_copy_retry_fixture="$tmp_dir/post-install-copy-retry.sh"
render_post_install_fixture "$post_install_copy_retry_home" \
	"$post_install_copy_retry_fixture"
mkdir -p "$post_install_copy_retry_home/.config/zsh/.antidote"
printf '%s\n' '# existing antidote' \
	>"$post_install_copy_retry_home/.config/zsh/.antidote/antidote.zsh"
COMMAND_LOG="$tmp_dir/post-install-copy-retry-commands.log"
: >"$COMMAND_LOG"
set +e
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_copy_retry_home" \
	ZDOTDIR="$post_install_copy_retry_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	FAIL_NANORC_COPY=true \
	/bin/bash "$post_install_copy_retry_fixture" \
	>"$tmp_dir/post-install-copy-failure.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
[[ -f "$post_install_copy_retry_home/.local/share/nano/conf.nanorc" ]]
[[ ! -e "$post_install_copy_retry_home/.local/share/nano/.chezmoi-complete" ]]

: >"$COMMAND_LOG"
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_copy_retry_home" \
	ZDOTDIR="$post_install_copy_retry_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_copy_retry_fixture"
assert_log_contains 'curl --fail --show-error --silent --location --retry 3'
[[ -f "$post_install_copy_retry_home/.local/share/nano/.chezmoi-complete" ]]

prepare_complete_post_install_home() {
	local home=$1
	mkdir -p "$home/.config/zsh/.antidote" \
		"$home/.local/share/nano" \
		"$home/.local/bin"
	printf '%s\n' '# existing antidote' \
		>"$home/.config/zsh/.antidote/antidote.zsh"
	printf '%s\n' 'complete nanorc fixture' \
		>"$home/.local/share/nano/conf.nanorc"
	: >"$home/.local/share/nano/.chezmoi-complete"
}

post_install_correct_home="$tmp_dir/post-install-correct-home"
post_install_correct_fixture="$tmp_dir/post-install-correct.sh"
render_post_install_fixture "$post_install_correct_home" \
	"$post_install_correct_fixture"
prepare_complete_post_install_home "$post_install_correct_home"
ln -s "$post_install_fake_bin/batcat" \
	"$post_install_correct_home/.local/bin/bat"
ln -s "$post_install_fake_bin/fdfind" \
	"$post_install_correct_home/.local/bin/fd"
COMMAND_LOG="$tmp_dir/post-install-correct-commands.log"
: >"$COMMAND_LOG"
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_correct_home" \
	ZDOTDIR="$post_install_correct_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_correct_fixture"
[[ ! -s "$COMMAND_LOG" ]]
[[ $(readlink "$post_install_correct_home/.local/bin/bat") == "$post_install_fake_bin/batcat" ]]
[[ $(readlink "$post_install_correct_home/.local/bin/fd") == "$post_install_fake_bin/fdfind" ]]

post_install_wrong_home="$tmp_dir/post-install-wrong-home"
post_install_wrong_fixture="$tmp_dir/post-install-wrong.sh"
render_post_install_fixture "$post_install_wrong_home" \
	"$post_install_wrong_fixture"
prepare_complete_post_install_home "$post_install_wrong_home"
ln -s "$tmp_dir/wrong-bat" "$post_install_wrong_home/.local/bin/bat"
ln -s "$tmp_dir/missing-fd" "$post_install_wrong_home/.local/bin/fd"
COMMAND_LOG="$tmp_dir/post-install-wrong-commands.log"
: >"$COMMAND_LOG"
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_wrong_home" \
	ZDOTDIR="$post_install_wrong_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_wrong_fixture"
[[ $(readlink "$post_install_wrong_home/.local/bin/bat") == "$post_install_fake_bin/batcat" ]]
[[ $(readlink "$post_install_wrong_home/.local/bin/fd") == "$post_install_fake_bin/fdfind" ]]

post_install_conflict_home="$tmp_dir/post-install-conflict-home"
post_install_conflict_fixture="$tmp_dir/post-install-conflict.sh"
render_post_install_fixture "$post_install_conflict_home" \
	"$post_install_conflict_fixture"
prepare_complete_post_install_home "$post_install_conflict_home"
printf '%s\n' 'user-owned bat path' \
	>"$post_install_conflict_home/.local/bin/bat"
COMMAND_LOG="$tmp_dir/post-install-conflict-commands.log"
: >"$COMMAND_LOG"
set +e
PATH="$post_install_fake_bin:/usr/bin:/bin" \
	HOME="$post_install_conflict_home" \
	ZDOTDIR="$post_install_conflict_home/.config/zsh" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$post_install_conflict_fixture" \
	>"$tmp_dir/post-install-conflict.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
rg -Fq 'refusing to replace non-symlink path' \
	"$tmp_dir/post-install-conflict.out"
rg -Fxq 'user-owned bat path' \
	"$post_install_conflict_home/.local/bin/bat"

maintenance_source="$source_dir/.chezmoiscripts/run_once_after_90-monthly-maintenance.sh.tmpl"
maintenance_fixture="$tmp_dir/monthly-maintenance.sh"
chezmoi -S "$source_dir" execute-template \
	--override-data-file "$post_install_data" \
	--file "$maintenance_source" >"$maintenance_fixture"
chmod +x "$maintenance_fixture"

maintenance_fake_bin="$tmp_dir/maintenance-fake-bin"
mkdir -p "$maintenance_fake_bin"
cat >"$maintenance_fake_bin/uv" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
printf 'uv %s\n' "$*" >>"$COMMAND_LOG"
STUB
chmod +x "$maintenance_fake_bin/uv"
COMMAND_LOG="$tmp_dir/maintenance-commands.log"
: >"$COMMAND_LOG"
PATH="$maintenance_fake_bin:/usr/bin:/bin" \
	COMMAND_LOG="$COMMAND_LOG" \
	/bin/bash "$maintenance_fixture"
[[ $(wc -l <"$COMMAND_LOG") -eq 1 ]]
assert_log_contains 'uv tool upgrade --all'

security_source="$source_dir/.chezmoiscripts/run_onchange_after_60-security-material.sh.tmpl"
security_keys_dir="$tmp_dir/security-keys"
security_data="$tmp_dir/security.json"
jq \
	--arg ssh_keys_dir "$security_keys_dir" \
	'.secrets.provider = "onepassword"
     | .directories.ssh_keys_dir = $ssh_keys_dir
     | .remote_servers = {
         fixture: {
           name: "fixture",
           op_id: "fixture-op-id",
           generate_public_key_only: false
         }
       }' \
	"$base_data_file" >"$security_data"

security_fake_bin="$tmp_dir/security-fake-bin"
mkdir -p "$security_fake_bin"
cat >"$security_fake_bin/op" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

printf 'op %s\n' "$*" >>"${OP_COMMAND_LOG:-/dev/null}"
if [[ "$1" == "signin" && "${2:-}" == "--raw" ]]; then
    printf '%s\n' 'test-session'
elif [[ "$1" == "item" && "${2:-}" == "get" ]] ||
    [[ "$1" == "--session" && "${3:-}" == "item" && "${4:-}" == "get" ]]; then
    if [[ -n "${OP_ITEM_JSON_FIXTURE:-}" ]]; then
        cat "$OP_ITEM_JSON_FIXTURE"
    else
        printf '%s\n' '{"fields":[{"label":"private key","value":"PRIVATE-KEY-FIXTURE\n"},{"label":"public key","value":"ssh-ed25519 PUBLIC-FIXTURE\n"}]}'
    fi
    [[ "${FAIL_OP_AFTER_OUTPUT:-false}" == true ]] && exit 42
    exit 0
else
    exit 64
fi
STUB
chmod +x "$security_fake_bin/op"
security_fixture="$tmp_dir/security-material.sh"
security_render_op_log="$tmp_dir/security-render-op.log"
: >"$security_render_op_log"
PATH="$security_fake_bin:$PATH" \
	OP_COMMAND_LOG="$security_render_op_log" \
	chezmoi -S "$source_dir" execute-template \
	--override-data-file "$security_data" \
	--file "$security_source" >"$security_fixture"
chmod +x "$security_fixture"
assert_no_security_fixture_material "$security_fixture"
rg -Fq 'fixture-op-id' "$security_fixture"
[[ ! -s "$security_render_op_log" ]]

security_dry_run_root="$tmp_dir/security-dry-run-root"
mkdir -p "$security_dry_run_root"
security_dry_run_output="$tmp_dir/security-dry-run.out"
PATH="$security_fake_bin:$PATH" \
	OP_COMMAND_LOG="$security_render_op_log" \
	chezmoi -S "$source_dir" -D "$security_dry_run_root" \
	--override-data-file "$security_data" apply \
	--dry-run --verbose --no-tty --force --include scripts \
	>"$security_dry_run_output" 2>&1
assert_no_security_fixture_material "$security_dry_run_output"
[[ ! -s "$security_render_op_log" ]]

security_output="$tmp_dir/security-success.out"
OP_COMMAND_LOG="$tmp_dir/security-op-commands.log"
: >"$OP_COMMAND_LOG"
PATH="$security_fake_bin:/usr/bin:/bin" \
	OP_COMMAND_LOG="$OP_COMMAND_LOG" \
	/bin/bash "$security_fixture" >"$security_output" 2>&1
printf 'PRIVATE-KEY-FIXTURE\n' >"$tmp_dir/expected-private-key"
printf 'ssh-ed25519 PUBLIC-FIXTURE\n' >"$tmp_dir/expected-public-key"
cmp -s "$tmp_dir/expected-private-key" "$security_keys_dir/fixture"
cmp -s "$tmp_dir/expected-public-key" "$security_keys_dir/fixture.pub"
assert_file_mode "$security_keys_dir/fixture" 600
assert_file_mode "$security_keys_dir/fixture.pub" 644
assert_no_security_fixture_material "$security_output"
rg -Fq 'op item get fixture-op-id --format json' "$OP_COMMAND_LOG"
[[ $(rg -Fc 'op item get fixture-op-id --format json' "$OP_COMMAND_LOG") -eq 2 ]]

PATH="/usr/bin:/bin" /bin/bash "$security_fixture" \
	>"$tmp_dir/security-offline-existing.out" 2>&1
cmp -s "$tmp_dir/expected-private-key" "$security_keys_dir/fixture"
cmp -s "$tmp_dir/expected-public-key" "$security_keys_dir/fixture.pub"
assert_no_security_fixture_material "$tmp_dir/security-offline-existing.out"

render_security_case() {
	local item_json=$1
	local keys_dir=$2
	local output=$3
	local data_file="$output.json"
	jq --arg ssh_keys_dir "$keys_dir" \
		'.directories.ssh_keys_dir = $ssh_keys_dir' \
		"$security_data" >"$data_file"
	OP_ITEM_JSON_FIXTURE="$item_json" \
		PATH="$security_fake_bin:$PATH" \
		chezmoi -S "$source_dir" execute-template \
		--override-data-file "$data_file" \
		--file "$security_source" >"$output"
	chmod +x "$output"
}

assert_security_render_rejected() {
	local item_json=$1
	local label=$2
	local keys_dir="$tmp_dir/security-$label-keys"
	local fixture="$tmp_dir/security-$label.sh"
	render_security_case "$item_json" "$keys_dir" "$fixture"
	set +e
	PATH="$security_fake_bin:/usr/bin:/bin" \
		OP_ITEM_JSON_FIXTURE="$item_json" \
		/bin/bash "$fixture" >"$tmp_dir/security-$label.out" 2>&1
	status=$?
	set -e
	[[ $status -ne 0 ]]
	[[ ! -e "$keys_dir/fixture" ]]
	[[ ! -e "$keys_dir/fixture.pub" ]]
	assert_no_security_fixture_material "$tmp_dir/security-$label.out"
	if find "$keys_dir" -name '.fixture*.tmp.*' -print -quit | rg -q .; then
		printf 'security %s failure left a temporary key\n' "$label" >&2
		exit 1
	fi
}

missing_private_json="$tmp_dir/security-missing-private.json"
printf '%s\n' \
	'{"fields":[{"label":"public key","value":"ssh-ed25519 PUBLIC-FIXTURE\n"}]}' \
	>"$missing_private_json"
assert_security_render_rejected "$missing_private_json" missing-private

empty_public_json="$tmp_dir/security-empty-public.json"
printf '%s\n' \
	'{"fields":[{"label":"private key","value":"PRIVATE-KEY-FIXTURE\n"},{"label":"public key","value":""}]}' \
	>"$empty_public_json"
assert_security_render_rejected "$empty_public_json" empty-public

security_runtime_keys_dir="$tmp_dir/security-runtime-keys"
security_runtime_fixture="$tmp_dir/security-runtime-fetch.sh"
normal_security_json="$tmp_dir/security-normal.json"
printf '%s\n' \
	'{"fields":[{"label":"private key","value":"PRIVATE-KEY-FIXTURE\n"},{"label":"public key","value":"ssh-ed25519 PUBLIC-FIXTURE\n"}]}' \
	>"$normal_security_json"
render_security_case "$normal_security_json" "$security_runtime_keys_dir" \
	"$security_runtime_fixture"
set +e
PATH="$security_fake_bin:/usr/bin:/bin" \
	OP_ITEM_JSON_FIXTURE="$normal_security_json" \
	FAIL_OP_AFTER_OUTPUT=true \
	/bin/bash "$security_runtime_fixture" \
	>"$tmp_dir/security-runtime-fetch-failure.out" 2>&1
status=$?
set -e
[[ $status -ne 0 ]]
[[ ! -e "$security_runtime_keys_dir/fixture" ]]
[[ ! -e "$security_runtime_keys_dir/fixture.pub" ]]
assert_no_security_fixture_material "$tmp_dir/security-runtime-fetch-failure.out"
if find "$security_runtime_keys_dir" -name '.fixture*.tmp.*' \
	-print -quit | rg -q .; then
	printf 'failed runtime key fetch left a temporary key\n' >&2
	exit 1
fi

PATH="$security_fake_bin:/usr/bin:/bin" \
	OP_ITEM_JSON_FIXTURE="$normal_security_json" \
	/bin/bash "$security_runtime_fixture"
cmp -s "$tmp_dir/expected-private-key" "$security_runtime_keys_dir/fixture"
cmp -s "$tmp_dir/expected-public-key" "$security_runtime_keys_dir/fixture.pub"

security_public_only_keys_dir="$tmp_dir/security-public-only-keys"
security_public_only_data="$tmp_dir/security-public-only.json"
jq --arg ssh_keys_dir "$security_public_only_keys_dir" \
	'.directories.ssh_keys_dir = $ssh_keys_dir
     | .remote_servers.fixture.generate_public_key_only = true' \
	"$security_data" >"$security_public_only_data"
security_public_only_fixture="$tmp_dir/security-public-only.sh"
PATH="$security_fake_bin:$PATH" chezmoi -S "$source_dir" execute-template \
	--override-data-file "$security_public_only_data" \
	--file "$security_source" >"$security_public_only_fixture"
chmod +x "$security_public_only_fixture"
assert_no_security_fixture_material "$security_public_only_fixture"
public_only_item_json="$tmp_dir/security-public-only-item.json"
printf '%s\n' \
	'{"fields":[{"label":"pubkey","value":"ssh-ed25519 PUBLIC-FIXTURE\n"}]}' \
	>"$public_only_item_json"
public_only_op_log="$tmp_dir/security-public-only-op.log"
: >"$public_only_op_log"
PATH="$security_fake_bin:/usr/bin:/bin" \
	OP_ITEM_JSON_FIXTURE="$public_only_item_json" \
	OP_COMMAND_LOG="$public_only_op_log" \
	/bin/bash "$security_public_only_fixture" \
	>"$tmp_dir/security-public-only.out" 2>&1
[[ ! -e "$security_public_only_keys_dir/fixture" ]]
cmp -s "$tmp_dir/expected-public-key" \
	"$security_public_only_keys_dir/fixture.pub"
assert_file_mode "$security_public_only_keys_dir/fixture.pub" 644
assert_no_security_fixture_material "$tmp_dir/security-public-only.out"
[[ $(rg -Fc 'op item get fixture-op-id --format json' \
	"$public_only_op_log") -eq 1 ]]

prepare_existing_security_defaults() {
	local keys_dir=$1
	mkdir -p "$keys_dir"
	jq -r '.remote_servers[]?.name' "$base_data_file" |
		while IFS= read -r server_name; do
			printf '%s\n' 'existing key fixture' \
				>"$keys_dir/$server_name"
			printf '%s\n' 'existing public key fixture' \
				>"$keys_dir/$server_name.pub"
		done
}

assert_security_directory_conflict() {
	local key_suffix=$1
	local public_only=$2
	local label=$3
	local keys_dir="$tmp_dir/security-$label-keys"
	local data_file="$tmp_dir/security-$label.json"
	local fixture="$tmp_dir/security-$label.sh"
	local conflict_path="$keys_dir/fixture$key_suffix"
	local op_log="$tmp_dir/security-$label-op.log"
	local output="$tmp_dir/security-$label.out"

	prepare_existing_security_defaults "$keys_dir"
	mkdir -p "$conflict_path"
	jq \
		--arg ssh_keys_dir "$keys_dir" \
		--argjson public_only "$public_only" \
		'.directories.ssh_keys_dir = $ssh_keys_dir
         | .remote_servers.fixture.generate_public_key_only = $public_only' \
		"$security_data" >"$data_file"
	PATH="$security_fake_bin:$PATH" \
		chezmoi -S "$source_dir" execute-template \
		--override-data-file "$data_file" \
		--file "$security_source" >"$fixture"
	chmod +x "$fixture"
	: >"$op_log"

	set +e
	PATH="$security_fake_bin:/usr/bin:/bin" \
		OP_COMMAND_LOG="$op_log" \
		/bin/bash "$fixture" >"$output" 2>&1
	status=$?
	set -e
	[[ $status -ne 0 ]] || {
		printf 'security phase accepted %s directory target\n' "$label" >&2
		exit 1
	}
	rg -Fq 'refusing non-regular SSH key target' "$output"
	assert_no_security_fixture_material "$output"
	[[ ! -s "$op_log" ]]
	[[ -d "$conflict_path" ]]
	if find "$conflict_path" -mindepth 1 -print -quit | rg -q .; then
		printf 'security phase wrote inside %s directory target\n' \
			"$label" >&2
		exit 1
	fi
	if find "$keys_dir" -name '.fixture*.tmp.*' -print -quit | rg -q .; then
		printf 'security %s conflict left a temporary key\n' "$label" >&2
		exit 1
	fi
	if [[ "$key_suffix" == ".pub" ]]; then
		[[ ! -e "$keys_dir/fixture" ]]
	else
		[[ ! -e "$keys_dir/fixture.pub" ]]
	fi
}

assert_security_directory_conflict '' false private-directory
assert_security_directory_conflict '.pub' false public-directory
assert_security_directory_conflict '.pub' true public-only-directory

for key_suffix in '' '.pub'; do
	dangling_keys_dir="$tmp_dir/security-dangling-${key_suffix:-private}"
	outside_target="$tmp_dir/outside-${key_suffix:-private}"
	mkdir -p "$dangling_keys_dir"
	ln -s "$outside_target" "$dangling_keys_dir/fixture$key_suffix"
	dangling_security_data="$tmp_dir/security-dangling-${key_suffix:-private}.json"
	jq --arg ssh_keys_dir "$dangling_keys_dir" \
		'.directories.ssh_keys_dir = $ssh_keys_dir' \
		"$security_data" >"$dangling_security_data"
	dangling_security_fixture="$tmp_dir/security-dangling-${key_suffix:-private}.sh"
	PATH="$security_fake_bin:$PATH" chezmoi -S "$source_dir" execute-template \
		--override-data-file "$dangling_security_data" \
		--file "$security_source" >"$dangling_security_fixture"
	set +e
	PATH="$security_fake_bin:/usr/bin:/bin" \
		/bin/bash "$dangling_security_fixture" \
		>"$tmp_dir/security-dangling-${key_suffix:-private}.out" 2>&1
	security_status=$?
	set -e
	[[ $security_status -ne 0 ]]
	[[ ! -e "$outside_target" ]]
	[[ ! -f "$dangling_keys_dir/fixture" ]]
	[[ ! -f "$dangling_keys_dir/fixture.pub" ]]
done

printf 'chezmoi script behavior tests passed\n'
