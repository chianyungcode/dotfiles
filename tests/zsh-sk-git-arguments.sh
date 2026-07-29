#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
zsh_config="$repo_root/chezmoi/dot_config/zsh/conf.d/third-party/90_sk-git.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export GIT_CONFIG_GLOBAL="$tmp_dir/global-gitconfig"
export GIT_CONFIG_NOSYSTEM=1

for command_name in git zsh; do
    command -v "$command_name" >/dev/null ||
        fail "missing required command: $command_name"
done

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/sk" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\0' "$@" >"$SK_GIT_TEST_ARGS"
cat >/dev/null
STUB
chmod +x "$stub_bin/sk"

git_repo="$tmp_dir/repository"
mkdir -p "$git_repo"
git -C "$git_repo" init -q -b main
git -C "$git_repo" config user.name "sk-git argument test"
git -C "$git_repo" config user.email "sk-git-arguments@example.invalid"
git -C "$git_repo" config commit.gpgsign false
printf 'tracked\n' >"$git_repo/tracked.txt"
git -C "$git_repo" add tracked.txt
git -C "$git_repo" commit -q -m "initial commit"

assert_picker_arguments() {
    local picker=$1
    local expected_header=$2
    local argument
    local found_height=false
    local found_min_height=false
    local found_border=false
    local found_header=false
    local argument_log="$tmp_dir/arguments"

    : >"$argument_log"
    PATH="$stub_bin:$PATH" \
        SK_GIT_TEST_ARGS="$argument_log" \
        zsh -f -c '
            source "$1"
            cd "$2"
            "$3"
        ' zsh-sk-git-argument-test "$zsh_config" "$git_repo" "$picker"

    while IFS= read -r -d '' argument; do
        [[ "$argument" != *$'\n'* ]] ||
            fail "$picker passed multiple picker options in one argument"
        case "$argument" in
        --height=95%) found_height=true ;;
        --min-height=12) found_min_height=true ;;
        --border=rounded) found_border=true ;;
        "--header=$expected_header") found_header=true ;;
        esac
    done <"$argument_log"

    [[ "$found_height" == true ]] ||
        fail "$picker did not pass --height as a separate argument"
    [[ "$found_min_height" == true ]] ||
        fail "$picker did not pass --min-height as a separate argument"
    [[ "$found_border" == true ]] ||
        fail "$picker did not pass --border as a separate argument"
    [[ "$found_header" == true ]] ||
        fail "$picker did not pass the expected action header"
}

assert_picker_arguments \
    __sk_git_hashes \
    'CTRL-O open in browser | CTRL-D show diff | CTRL-S toggle sort | ALT-A all hashes | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_files \
    'CTRL-O open in browser | ALT-E edit file | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_branches \
    'CTRL-O open in browser | ALT-A all branches | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_tags \
    'CTRL-O open in browser | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_remotes \
    'CTRL-O open in browser | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_stashes \
    'CTRL-X drop stash | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_reflogs \
    'CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_each_ref \
    'CTRL-O open in browser | ALT-E view in editor | ALT-A all refs | CTRL-/ toggle preview'
assert_picker_arguments \
    __sk_git_worktrees \
    'CTRL-X remove worktree | CTRL-/ toggle preview'

printf 'zsh sk-git argument tests passed\n'
