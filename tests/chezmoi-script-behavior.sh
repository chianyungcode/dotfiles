#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi rg; do
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
rg -q '\[core-test\] fixture complete' <<<"$success_output"
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
    --file "$source_dir/.chezmoiscripts/run_before_00-bootstrap.sh.tmpl" \
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
write_fake_command sudo 'printf "sudo %s\\n" "$*" >>"$COMMAND_LOG"; exec "$@"'
write_fake_command pacman 'printf "pacman %s\\n" "$*" >>"$COMMAND_LOG"'
write_fake_command git 'printf "git %s\\n" "$*" >>"$COMMAND_LOG"; mkdir -p "${@: -1}"'
write_fake_command makepkg 'printf "makepkg %s\\n" "$*" >>"$COMMAND_LOG"; printf "%s\\n%s\\n" "#!/bin/bash" "exit 0" >"$FAKE_BIN/paru"; chmod +x "$FAKE_BIN/paru"'

COMMAND_LOG="$tmp_dir/commands.log"
PATH="$fake_bin:/usr/bin:/bin" \
    COMMAND_LOG="$COMMAND_LOG" \
    FAKE_BIN="$fake_bin" \
    /bin/bash "$bootstrap_fixture"

assert_log_contains 'pacman -S --needed --noconfirm git base-devel'
assert_log_contains 'git clone --depth 1 https://aur.archlinux.org/paru.git'
assert_log_contains 'makepkg -si --noconfirm'

printf 'chezmoi script behavior tests passed\n'
