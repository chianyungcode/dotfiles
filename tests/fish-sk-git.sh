#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
fish_config="$repo_root/chezmoi/dot_config/fish/conf.d/90_sk-git.fish"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/home"
export HOME="$tmp_dir/home"
export GIT_CONFIG_GLOBAL="$tmp_dir/global-gitconfig"
export GIT_CONFIG_NOSYSTEM=1

for command_name in fish git rg; do
    command -v "$command_name" >/dev/null ||
        fail "missing required command: $command_name"
done

[[ -f "$fish_config" ]] || fail "90_sk-git.fish is missing"
fish --no-config -n "$fish_config"

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"
mkdir -p "$tmp_dir/empty-path"
cat >"$stub_bin/sk" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$@" >"$SK_GIT_TEST_ARGS"
cat >"$SK_GIT_TEST_INPUT"

if [[ -v NO_COLOR ]]; then
    printf 'NO_COLOR_PRESENT\n' >"$SK_GIT_TEST_ENV"
else
    printf 'NO_COLOR_UNSET\n' >"$SK_GIT_TEST_ENV"
fi

if [[ ${SK_GIT_TEST_CANCEL:-false} == true ]]; then
    exit 130
fi

awk -F '\t' -v selected="${SK_GIT_TEST_SELECT:-}" '
    BEGIN {
        count = split(selected, wanted, ",")
    }
    {
        for (position = 1; position <= count; position++) {
            if ($1 == wanted[position]) {
                print
            }
        }
    }
' "$SK_GIT_TEST_INPUT"
STUB
chmod +x "$stub_bin/sk"

cat >"$stub_bin/open" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$1" >"$SK_GIT_TEST_OPEN"
STUB
chmod +x "$stub_bin/open"

cat >"$stub_bin/ssh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail

if [[ ${1:-} == -G ]]; then
    printf 'hostname github.com\n'
fi
STUB
chmod +x "$stub_bin/ssh"

git_repo="$tmp_dir/repository"
mkdir -p "$git_repo"
git -C "$git_repo" init -q -b main
git -C "$git_repo" config user.name "sk-git test"
git -C "$git_repo" config user.email "sk-git@example.invalid"
printf 'first\n' >"$git_repo/tracked.txt"
git -C "$git_repo" add tracked.txt
git -C "$git_repo" commit -q -m "first commit"
git -C "$git_repo" branch 'feature/$cash'
printf 'second\n' >>"$git_repo/tracked.txt"
git -C "$git_repo" commit -q -am "second commit"
printf 'stashed change\n' >>"$git_repo/tracked.txt"
git -C "$git_repo" stash push -q -m "stashed change"
git -C "$git_repo" tag -a v1.0 -m "release v1.0"
git -C "$git_repo" tag v0.9 HEAD~1
git -C "$git_repo" remote add origin git@github.com:sk-git/test-repository.git
git -C "$git_repo" remote add https https://gitlab.com/sk-git/test-repository.git
git -C "$git_repo" remote add alias ghcny:sk-git/alias-repository.git
git -C "$git_repo" config 'branch.feature/$cash.remote' https
git -C "$git_repo" config branch.alias-branch.remote alias

head_hash=$(git -C "$git_repo" rev-parse --short HEAD)
feature_branch='feature/$cash'

run_widget() {
    local widget=$1
    local directory=$2
    local selection=${3:-}
    local cancel=${4:-false}

    : >"$tmp_dir/sk-args"
    : >"$tmp_dir/sk-input"
    : >"$tmp_dir/sk-env"
    : >"$tmp_dir/commandline"

    PATH="$stub_bin:$PATH" \
        SK_GIT_TEST_ARGS="$tmp_dir/sk-args" \
        SK_GIT_TEST_INPUT="$tmp_dir/sk-input" \
        SK_GIT_TEST_ENV="$tmp_dir/sk-env" \
        SK_GIT_TEST_COMMANDLINE="$tmp_dir/commandline" \
        SK_GIT_TEST_SELECT="$selection" \
        SK_GIT_TEST_CANCEL="$cancel" \
        fish --no-config -c '
            function commandline
                string join \t -- $argv >>"$SK_GIT_TEST_COMMANDLINE"
            end

            source "$argv[1]"
            cd "$argv[2]"
            $argv[3]
        ' "$fish_config" "$directory" "$widget"
}

run_open_branch() {
    local branch=$1

    : >"$tmp_dir/open-url"
    : >"$tmp_dir/commandline"
    PATH="$stub_bin:$PATH" \
        SK_GIT_TEST_OPEN="$tmp_dir/open-url" \
        fish --no-config -c '
            source "$argv[1]"
            cd "$argv[2]"
            __sk_git_open_branch "$argv[3]"
        ' "$fish_config" "$git_repo" "$branch"
}

assert_picker_window() {
    for picker_option in '--height=60%' '--min-height=12' '--border=rounded'; do
        rg -Fxq -- "$picker_option" "$tmp_dir/sk-args" ||
            fail "picker window is missing $picker_option"
    done
}

run_widget sk_git_hashes "$git_repo" "$head_hash"
assert_picker_window
rg -Fq 'second commit' "$tmp_dir/sk-input"
rg -Fxq -- '--multi' "$tmp_dir/sk-args"
rg -Fxq -- '--no-sort' "$tmp_dir/sk-args"
rg -Fq 'ctrl-/:toggle-preview' "$tmp_dir/sk-args"
rg -Fq 'git show --ext-diff --color=always {1}' "$tmp_dir/sk-args"
rg -Fq 'DFT_COLOR=always git show --ext-diff --color=always {1}' "$tmp_dir/sk-args"
rg -Fxq 'NO_COLOR_UNSET' "$tmp_dir/sk-env"
rg -Fxq -- $'-it\t--\t'"$head_hash" "$tmp_dir/commandline"
rg -Fxq -- $'-it\t--\t ' "$tmp_dir/commandline"
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

run_widget sk_git_branches "$git_repo" "main,$feature_branch"
rg -Fq $'feature/$cash\t' "$tmp_dir/sk-input"
rg -Fxq -- '--multi' "$tmp_dir/sk-args"
if rg -Fq -- '--ext-diff' "$tmp_dir/sk-args"; then
    fail "branch preview unexpectedly runs external difft for the full log"
fi
rg -Fq 'git log --oneline --graph' "$tmp_dir/sk-args"
rg -Fxq 'NO_COLOR_UNSET' "$tmp_dir/sk-env"
rg -Fxq -- $'-it\t--\tmain' "$tmp_dir/commandline"
escaped_branch=$(fish --no-config -c \
    'string escape -- "$argv[1]"' "$feature_branch")
rg -Fxq -- $'-it\t--\t'"$escaped_branch" "$tmp_dir/commandline"
[[ $(rg -Fxc -- $'-it\t--\t ' "$tmp_dir/commandline") == 2 ]] ||
    fail "multi-select did not insert two separating spaces"
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"
rg -Fxq -- '--height=60%' "$tmp_dir/sk-args"
rg -Fxq -- '--min-height=12' "$tmp_dir/sk-args"
rg -Fxq -- '--border=rounded' "$tmp_dir/sk-args"
rg -Fxq -- '--header=CTRL-O open branch in remote' "$tmp_dir/sk-args"
rg -Fq -- "ctrl-o:execute-silent(fish -c '__sk_git_open_branch" \
    "$tmp_dir/sk-args"
rg -Fq -- ' -- {1}' "$tmp_dir/sk-args"

run_open_branch main
rg -Fxq -- \
    'https://github.com/sk-git/test-repository/tree/main' \
    "$tmp_dir/open-url"

run_open_branch 'feature/$cash'
rg -Fxq -- \
    'https://gitlab.com/sk-git/test-repository/tree/feature/$cash' \
    "$tmp_dir/open-url"

run_open_branch alias-branch
rg -Fxq -- \
    'https://github.com/sk-git/alias-repository/tree/alias-branch' \
    "$tmp_dir/open-url"
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "opening branch remote inserted text"
fi

run_widget sk_git_help "$git_repo"
assert_picker_window
for help_entry in \
    'ctrl-g ?  show this help' \
    'ctrl-g h  show commit hashes' \
    'ctrl-g b  show local branches' \
    'ctrl-g t  show Git tags' \
    'ctrl-g f  show tracked files' \
    'ctrl-g r  show remotes' \
    'ctrl-g w  show worktrees' \
    'ctrl-g s  show stashes' \
    'ctrl-g l  show reflogs'; do
    rg -Fq -- "$help_entry" "$tmp_dir/sk-input"
done
rg -Fxq -- '--no-multi' "$tmp_dir/sk-args"
rg -Fxq -- '--no-sort' "$tmp_dir/sk-args"
rg -Fxq -- '--prompt=help> ' "$tmp_dir/sk-args"
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "help picker inserted text"
fi
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

run_widget sk_git_tags "$git_repo" v1.0
assert_picker_window
rg -Fq $'v1.0\t' "$tmp_dir/sk-input"
rg -Fq 'DFT_COLOR=always git show --ext-diff --color=always {1}' \
    "$tmp_dir/sk-args"
escaped_tag=$(fish --no-config -c \
    'string escape -- "$argv[1]"' v1.0)
rg -Fxq -- $'-it\t--\t'"$escaped_tag" "$tmp_dir/commandline"
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

run_widget sk_git_tags "$git_repo" v1.0 true
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "cancelled tag picker inserted text"
fi

run_widget sk_git_stashes "$git_repo" 'stash@{0}'
assert_picker_window
rg -Fq $'stash@{0}\t' "$tmp_dir/sk-input"
rg -Fq 'DFT_COLOR=always git show --ext-diff --color=always {1}' "$tmp_dir/sk-args"
escaped_stash=$(fish --no-config -c \
    'string escape -- "$argv[1]"' 'stash@{0}')
rg -Fxq -- $'-it\t--\t'"$escaped_stash" "$tmp_dir/commandline"
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

run_widget sk_git_reflogs "$git_repo" 'HEAD@{0}'
assert_picker_window
rg -Fq $'HEAD@{0}\t' "$tmp_dir/sk-input"
rg -Fq 'DFT_COLOR=always git show --ext-diff --color=always {1}' "$tmp_dir/sk-args"
escaped_reflog=$(fish --no-config -c \
    'string escape -- "$argv[1]"' 'HEAD@{0}')
rg -Fxq -- $'-it\t--\t'"$escaped_reflog" "$tmp_dir/commandline"
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

run_widget sk_git_stashes "$git_repo" 'stash@{0}' true
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "cancelled stash picker inserted text"
fi

run_widget sk_git_reflogs "$git_repo" 'HEAD@{0}' true
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "cancelled reflog picker inserted text"
fi

run_widget sk_git_hashes "$git_repo" "$head_hash" true
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "cancelled picker inserted text"
fi
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

run_widget sk_git_files "$git_repo" tracked.txt
assert_picker_window

run_widget sk_git_remotes "$git_repo" origin
assert_picker_window

run_widget sk_git_worktrees "$git_repo"
assert_picker_window

outside_repo="$tmp_dir/outside"
mkdir -p "$outside_repo"
run_widget sk_git_branches "$outside_repo"
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "non-repository picker inserted text"
fi
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

empty_repo="$tmp_dir/empty-repository"
mkdir -p "$empty_repo"
git -C "$empty_repo" init -q
run_widget sk_git_hashes "$empty_repo"
if rg -q '^-it' "$tmp_dir/commandline"; then
    fail "empty repository picker inserted text"
fi
rg -Fxq -- $'-f\trepaint' "$tmp_dir/commandline"

old_placeholder="$repo_root/chezmoi/dot_config/fish/conf.d/90_fzf-git.fish.tmpl"
[[ ! -e "$old_placeholder" ]] ||
    fail "obsolete 90_fzf-git.fish.tmpl still exists"

bindings=$(
    PATH="$stub_bin:$PATH" fish --no-config -c '
        source "$argv[1]"
        bind --user
        bind -M insert --user
    ' "$fish_config"
)
printf '%s\n' "$bindings" | rg -Fq 'bind ctrl-g,h sk_git_hashes'
printf '%s\n' "$bindings" | rg -Fq 'bind ctrl-g,b sk_git_branches'
printf '%s\n' "$bindings" | rg -Fq 'bind ctrl-g,s sk_git_stashes'
printf '%s\n' "$bindings" | rg -Fq 'bind ctrl-g,l sk_git_reflogs'
printf '%s\n' "$bindings" | rg -Fq 'bind ctrl-g,? sk_git_help'
printf '%s\n' "$bindings" | rg -Fq 'bind ctrl-g,t sk_git_tags'
printf '%s\n' "$bindings" | rg -Fq 'bind -M insert ctrl-g,h sk_git_hashes'
printf '%s\n' "$bindings" | rg -Fq 'bind -M insert ctrl-g,b sk_git_branches'
printf '%s\n' "$bindings" | rg -Fq 'bind -M insert ctrl-g,s sk_git_stashes'
printf '%s\n' "$bindings" | rg -Fq 'bind -M insert ctrl-g,l sk_git_reflogs'
printf '%s\n' "$bindings" | rg -Fq 'bind -M insert ctrl-g,? sk_git_help'
printf '%s\n' "$bindings" | rg -Fq 'bind -M insert ctrl-g,t sk_git_tags'

without_sk=$(
    fish --no-config -c '
        set -gx PATH "$argv[2]"
        function git
        end
        source "$argv[1]"
        bind --user
        bind -M insert --user
    ' "$fish_config" "$tmp_dir/empty-path"
)
if printf '%s\n' "$without_sk" | rg -q 'sk_git_(hashes|branches|stashes|reflogs|help|tags)'; then
    fail "bindings were defined without sk"
fi

without_git=$(
    fish --no-config -c '
        set -gx PATH "$argv[2]"
        function sk
        end
        source "$argv[1]"
        bind --user
        bind -M insert --user
    ' "$fish_config" "$tmp_dir/empty-path"
)
if printf '%s\n' "$without_git" | rg -q 'sk_git_(hashes|branches|stashes|reflogs|help|tags)'; then
    fail "bindings were defined without git"
fi

printf 'fish sk-git widget tests passed\n'
