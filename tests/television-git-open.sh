#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
helper="$repo_root/chezmoi/dot_config/television/scripts/executable_git-open"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

[[ -f "$helper" ]] || fail "missing Television Git browser helper"
sh -n "$helper"

stub_bin="$tmp_dir/bin"
repo="$tmp_dir/repo"
mkdir -p "$stub_bin" "$repo"
git -C "$repo" init -q
git -C "$repo" config user.name "Television test"
git -C "$repo" config user.email "television@example.invalid"
git -C "$repo" config commit.gpgsign false
printf 'tracked\n' >"$repo/tracked.txt"
git -C "$repo" add tracked.txt
git -C "$repo" commit -qm "initial"
git -C "$repo" branch -M main
head_hash=$(git -C "$repo" rev-parse --short HEAD)

cat >"$stub_bin/uname" <<'STUB'
#!/bin/sh
printf 'Darwin\n'
STUB
cat >"$stub_bin/open" <<'STUB'
#!/bin/sh
printf '%s\n' "$1" >"$TV_GIT_OPEN_LOG"
STUB
cat >"$stub_bin/ssh" <<'STUB'
#!/bin/sh
if [ "$1" = -G ] && [ "$2" = ghcny ]; then
    printf 'hostname github.com\n'
fi
STUB
chmod +x "$stub_bin/uname" "$stub_bin/open" "$stub_bin/ssh"

run_open() {
    local directory=$1 kind=$2 value=$3 expected=$4
    : >"$tmp_dir/open.log"
    (
        cd "$directory"
        PATH="$stub_bin:$PATH" TV_GIT_OPEN_LOG="$tmp_dir/open.log" \
            sh "$helper" "$kind" "$value"
    )
    [[ $(<"$tmp_dir/open.log") == "$expected" ]] ||
        fail "$kind URL mismatch"
}

git -C "$repo" remote add origin git@github.com:owner/project.git
run_open "$repo" commit "$head_hash" \
    "https://github.com/owner/project/commit/$head_hash"
run_open "$repo" branch main \
    "https://github.com/owner/project/tree/main"
run_open "$repo" file tracked.txt \
    "https://github.com/owner/project/blob/main/tracked.txt"

git -C "$repo" remote set-url origin https://gitlab.com/owner/project.git
run_open "$repo" remote origin \
    "https://gitlab.com/owner/project/tree/main"

git -C "$repo" tag v1.0
run_open "$repo" tag v1.0 \
    "https://gitlab.com/owner/project/releases/tag/v1.0"

git -C "$repo" remote set-url origin ghcny:owner/project.git
run_open "$repo" branch main \
    "https://github.com/owner/project/tree/main"

mkdir -p "$repo/nested"
run_open "$repo/nested" file tracked.txt \
    "https://github.com/owner/project/blob/main/nested/tracked.txt"

if (cd "$repo" && PATH="$stub_bin:$PATH" sh "$helper" unknown value); then
    fail "unknown object kind unexpectedly succeeded"
fi

printf 'television Git browser helper passed\n'
