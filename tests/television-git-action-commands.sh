#!/usr/bin/env bash

set -euo pipefail

fail() {
	printf '%s\n' "$1" >&2
	exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
channel_dir="$repo_root/chezmoi/dot_config/television/cable"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

render_action() {
	local channel=$1 action_name=$2 identifier=$3
	python3 - "$channel_dir/$channel.toml" "$action_name" "$identifier" <<'PY'
import pathlib
import shlex
import sys
import tomllib

filename, action_name, identifier = sys.argv[1:]
with pathlib.Path(filename).open("rb") as source:
    command = tomllib.load(source)["actions"][action_name]["command"]

selectors = (
    r"{split:\n:0|strip_ansi|split:\t:0}",
    r"{split:\n:0|split:\t:0}",
    r"{split:\n:0}",
)
matches = [selector for selector in selectors if selector in command]
if len(matches) != 1:
    raise SystemExit(f"expected exactly one known selector in {command!r}")
print(command.replace(f"'{matches[0]}'", shlex.quote(identifier)))
PY
}

run_action() {
	local directory=$1 channel=$2 action_name=$3 identifier=$4
	local command
	command=$(render_action "$channel" "$action_name" "$identifier")
	(
		cd "$directory"
		GIT_EDITOR=true bash -c "$command" >/dev/null 2>&1
	)
}

repo="$tmp_dir/repo"
remote="$tmp_dir/remote.git"
git init -q "$repo"
git init -q --bare "$remote"
git -C "$repo" config user.name "Television test"
git -C "$repo" config user.email "television@example.invalid"
git -C "$repo" config commit.gpgsign false
printf 'base\n' >"$repo/file with spaces.txt"
git -C "$repo" add "file with spaces.txt"
git -C "$repo" commit -qm "base"
git -C "$repo" branch -M main
git -C "$repo" remote add origin "$remote"
git -C "$repo" push -q -u origin main

printf 'staged\n' >"$repo/file with spaces.txt"
run_action "$repo" git-files stage "file with spaces.txt"
git -C "$repo" diff --cached --quiet &&
	fail "stage action did not update the index"
git -C "$repo" reset -q --hard HEAD

printf 'changed\n' >"$repo/file with spaces.txt"
run_action "$repo" git-files restore "file with spaces.txt"
git -C "$repo" diff --quiet ||
	fail "restore action left a worktree diff"

git -C "$repo" branch switch-target
run_action "$repo" git-branches switch switch-target
[[ $(git -C "$repo" branch --show-current) == switch-target ]] ||
	fail "branch switch action did not change branches"
git -C "$repo" switch -q main

git -C "$repo" branch merged
run_action "$repo" git-branches delete merged
if git -C "$repo" show-ref --verify --quiet refs/heads/merged; then
	fail "branch delete action left the merged branch"
fi

git --git-dir="$remote" update-ref \
	refs/heads/fetched "$(git -C "$repo" rev-parse HEAD)"
run_action "$repo" git-remotes fetch origin
git -C "$repo" show-ref --verify --quiet refs/remotes/origin/fetched ||
	fail "fetch action did not update remote-tracking refs"
git --git-dir="$remote" update-ref -d refs/heads/fetched
run_action "$repo" git-remotes fetch-prune origin
if git -C "$repo" show-ref --verify --quiet refs/remotes/origin/fetched; then
	fail "fetch-prune action left a stale remote-tracking ref"
fi

printf 'stash\n' >>"$repo/file with spaces.txt"
git -C "$repo" stash push -qm "action test"
run_action "$repo" git-stashes apply 'stash@{0}'
git -C "$repo" diff --quiet &&
	fail "stash apply action did not restore changes"
git -C "$repo" reset -q --hard HEAD
run_action "$repo" git-stashes drop 'stash@{0}'
[[ -z $(git -C "$repo" stash list) ]] ||
	fail "stash drop action left the stash"

printf 'pop\n' >>"$repo/file with spaces.txt"
git -C "$repo" stash push -qm "pop test"
run_action "$repo" git-stashes pop 'stash@{0}'
[[ -z $(git -C "$repo" stash list) ]] ||
	fail "stash pop action left the stash"
git -C "$repo" diff --quiet &&
	fail "stash pop action did not restore changes"
git -C "$repo" reset -q --hard HEAD

git -C "$repo" tag v1.0
run_action "$repo" git-tags push-origin v1.0
git --git-dir="$remote" show-ref --verify --quiet refs/tags/v1.0 ||
	fail "tag push action did not update origin"
run_action "$repo" git-tags delete v1.0
if git -C "$repo" show-ref --verify --quiet refs/tags/v1.0; then
	fail "tag delete action left the local tag"
fi

old_head=$(git -C "$repo" rev-parse HEAD)
printf 'second\n' >"$repo/second.txt"
git -C "$repo" add second.txt
git -C "$repo" commit -qm "second"
run_action "$repo" git-reflogs checkout-detached "$old_head"
[[ -z $(git -C "$repo" branch --show-current) ]] ||
	fail "reflog checkout action did not detach HEAD"
[[ $(git -C "$repo" rev-parse HEAD) == "$old_head" ]] ||
	fail "reflog checkout action selected the wrong commit"
git -C "$repo" switch -q main
run_action "$repo" git-reflogs hard-reset "$old_head"
[[ $(git -C "$repo" rev-parse HEAD) == "$old_head" ]] ||
	fail "hard-reset action did not move HEAD"

worktree="$tmp_dir/linked worktree"
git -C "$repo" worktree add -q -b removable "$worktree"
run_action "$repo" git-worktrees remove "$worktree"
[[ ! -d "$worktree" ]] ||
	fail "worktree remove action left the directory"

git -C "$repo" switch -qc guarded-base
printf 'guarded\n' >"$repo/guarded.txt"
git -C "$repo" add guarded.txt
git -C "$repo" commit -qm "guarded branch"
git -C "$repo" switch -q main
if run_action "$repo" git-branches delete guarded-base; then
	fail "unmerged branch deletion unexpectedly succeeded"
fi
git -C "$repo" show-ref --verify --quiet refs/heads/guarded-base ||
	fail "guarded branch disappeared"

dirty_worktree="$tmp_dir/dirty worktree"
git -C "$repo" worktree add -q -b dirty-branch "$dirty_worktree"
printf 'dirty\n' >>"$dirty_worktree/file with spaces.txt"
if run_action "$repo" git-worktrees remove "$dirty_worktree"; then
	fail "dirty worktree removal unexpectedly succeeded"
fi
[[ -d "$dirty_worktree" ]] ||
	fail "guarded dirty worktree disappeared"

printf 'television Git action command smoke test passed\n'
