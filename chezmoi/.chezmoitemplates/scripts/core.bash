set -Eeuo pipefail

: "${PHASE:?PHASE must be set before loading scripts/core.bash}"

printf '\n✨ %s ✨\n' "$PHASE"

TEMP_DIR=""

info() {
    printf '[%s] %s\n' "$PHASE" "$*"
}

notice() {
    printf '[%s] NOTICE: %s\n' "$PHASE" "$*"
}

die() {
    printf '[%s] ERROR: %s\n' "$PHASE" "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "required command not found: $1"
}

make_temp_dir() {
    local prefix=${1:-chezmoi-script}
    [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && return 0
    TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX") ||
        die "could not create temporary directory"
    chmod 700 "$TEMP_DIR"
}

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

report_error() {
    local status=$1
    local line=$2
    local command=$3
    trap - ERR
    printf '[%s] ERROR line %s: %s (status %s)\n' \
        "$PHASE" "$line" "$command" "$status" >&2
    return "$status"
}

trap cleanup EXIT
trap 'report_error "$?" "$LINENO" "$BASH_COMMAND"' ERR
