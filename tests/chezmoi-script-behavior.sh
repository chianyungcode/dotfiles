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
                 development: false,
                 personal: false,
                 homelab: false,
                 graphical: false
               }
             | .packages.homebrew.to_remove = []
             | .packages.homebrew.common.formulae = $packages
             | .packages.homebrew.common.casks = []' \
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
             | .packages.homebrew.common.formulae = ["package-removal-sentinel"]' \
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

printf 'chezmoi script behavior tests passed\n'
