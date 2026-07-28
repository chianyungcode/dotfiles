#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
channel_dir="$source_dir/dot_config/television/cable"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi python3 rg; do
    command -v "$command_name" >/dev/null ||
        fail "missing required command: $command_name"
done

channels=(
    git-hashes
    git-branches
    git-files
    git-remotes
    git-worktrees
    git-stashes
    git-reflogs
    git-tags
)

assert_contains() {
    local file=$1
    local pattern=$2
    rg -Fq -- "$pattern" "$file" ||
        fail "$file is missing: $pattern"
}

for channel in "${channels[@]}"; do
    file="$channel_dir/$channel.toml"
    [[ -f "$file" ]] || fail "$file is missing"

    assert_contains "$file" "name = \"$channel\""
    assert_contains "$file" 'requirements = ["git"]'
    assert_contains "$file" 'no_sort = true'
    assert_contains "$file" 'frecency = false'
    assert_contains "$file" '[source]'
    assert_contains "$file" '[preview]'

    case "$channel" in
    git-hashes)
        assert_contains "$file" 'git log'
        assert_contains "$file" 'git show'
        assert_contains "$file" '{strip_ansi|split:\\t:0}'
        ;;
    git-branches)
        assert_contains "$file" 'refs/heads'
        assert_contains "$file" 'git log --oneline --graph'
        assert_contains "$file" '{strip_ansi|split:\\t:0}'
        ;;
    git-files)
        assert_contains "$file" 'git ls-files'
        assert_contains "$file" 'git log --oneline --graph'
        ;;
    git-remotes)
        assert_contains "$file" 'git remote -v'
        assert_contains "$file" '--remotes='
        assert_contains "$file" '{split:\\t:0}'
        ;;
    git-worktrees)
        assert_contains "$file" 'git worktree list'
        assert_contains "$file" 'git -c color.status=always -C'
        assert_contains "$file" '{split: :0}'
        ;;
    git-stashes)
        assert_contains "$file" 'git stash list'
        assert_contains "$file" 'git show'
        assert_contains "$file" '{strip_ansi|split:\\t:0}'
        ;;
    git-reflogs)
        assert_contains "$file" 'git reflog'
        assert_contains "$file" 'git show'
        assert_contains "$file" '{strip_ansi|split:\\t:0}'
        ;;
    git-tags)
        assert_contains "$file" 'refs/tags'
        assert_contains "$file" 'git show'
        assert_contains "$file" '{strip_ansi|split:\\t:0}'
        ;;
    esac

    target=$(chezmoi -S "$source_dir" -D "$tmp_dir/home" \
        target-path "$file")
    expected="$tmp_dir/home/.config/television/cable/$channel.toml"
    [[ "$target" == "$expected" ]] ||
        fail "$file maps to $target instead of $expected"
done

python3 - "$channel_dir"/*.toml <<'PY'
import pathlib
import sys
import tomllib

for filename in sys.argv[1:]:
    with pathlib.Path(filename).open("rb") as channel_file:
        tomllib.load(channel_file)
PY

printf 'television Git channel contract passed\n'
