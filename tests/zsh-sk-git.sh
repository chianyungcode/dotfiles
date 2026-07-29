#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
zsh_config="$repo_root/chezmoi/dot_config/zsh/conf.d/third-party/90_sk-git.sh"
legacy_fzf_git="$repo_root/chezmoi/dot_config/fzf-git/fzf-git.sh"
legacy_fzf_git_dir="$repo_root/chezmoi/dot_config/fzf-git"
legacy_fzf_git_readme="$legacy_fzf_git_dir/README.md"
zother_tools="$repo_root/chezmoi/dot_config/zsh/conf.d/third-party/zother-tools.sh.tmpl"
zsh_loader="$repo_root/chezmoi/dot_config/zsh/dot_zshrc.tmpl"
third_party_dir="$repo_root/chezmoi/dot_config/zsh/conf.d/third-party"
unrelated_fzf="$third_party_dir/fzf.sh.tmpl"
unrelated_fzf_zoxide="$third_party_dir/zoxide.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in zsh git rg; do
    command -v "$command_name" >/dev/null ||
        fail "missing required command: $command_name"
done
zsh_bin=$(command -v zsh)
git_bin=$(command -v git)
awk_bin=$(command -v awk)
uname_bin=$(command -v uname)

[[ -f "$zsh_config" ]] || fail "90_sk-git.sh is missing"
[[ ! -e "$legacy_fzf_git" ]] || fail 'obsolete fzf-git payload still exists'
[[ ! -e "$legacy_fzf_git_readme" ]] || fail 'obsolete fzf-git README still exists'
[[ ! -d "$legacy_fzf_git_dir" ]] || fail 'obsolete fzf-git directory still exists'
if rg -n -e '^# FZF Git integration$' -e 'fzf-git/fzf-git\.sh' "$zother_tools"; then
    fail 'obsolete FZF Git source block still exists'
fi
sk_git_module_count=$(rg --files "$third_party_dir" | awk '$0 ~ /\/90_sk-git\.sh$/ { count++ } END { print count + 0 }')
[[ "$sk_git_module_count" == 1 ]] || fail "expected exactly one 90_sk-git.sh module, found $sk_git_module_count"
[[ $(rg -Fxc '    source "$file"' "$zsh_loader") == 1 ]] ||
    fail 'Zsh conf.d loader does not load modules exactly once'
[[ -f "$unrelated_fzf" ]] || fail 'unrelated Zsh FZF integration was removed'
[[ -f "$unrelated_fzf_zoxide" ]] || fail 'unrelated Zsh zoxide FZF widget was removed'
rg -Fq 'FZF_CTRL_R_COMMAND' "$unrelated_fzf" ||
    fail 'unrelated Zsh FZF integration was changed'
rg -Fq 'fzf_zoxide_widget' "$unrelated_fzf_zoxide" ||
    fail 'unrelated zoxide FZF widget was changed'
zsh -n "$zsh_config"

plain_picker_window=$(
    env -u TMUX -u ZELLIJ "$zsh_bin" -f -c '
        source "$1"
        __sk_git_picker_window
    ' zsh-sk-git-test "$zsh_config"
)
[[ "$plain_picker_window" != *'--popup=center,40%'* ]] ||
    fail 'plain sk picker unexpectedly enabled popup mode'

tmux_picker_window=$(
    TMUX=1 "$zsh_bin" -f -c '
        source "$1"
        __sk_git_picker_window
    ' zsh-sk-git-test "$zsh_config"
)
[[ "$tmux_picker_window" == *'--popup=center,40%'* ]] ||
    fail 'tmux sk picker did not enable popup mode'

zellij_picker_window=$(
    ZELLIJ=1 "$zsh_bin" -f -c '
        source "$1"
        __sk_git_picker_window
    ' zsh-sk-git-test "$zsh_config"
)
[[ "$zellij_picker_window" == *'--popup=center,40%'* ]] ||
    fail 'zellij sk picker did not enable popup mode'

stub_bin="$tmp_dir/bin"
missing_opener_bin="$tmp_dir/missing-opener-bin"
mkdir -p "$stub_bin" "$missing_opener_bin"
export GIT_CONFIG_GLOBAL="$tmp_dir/global-gitconfig"
export GIT_CONFIG_NOSYSTEM=1

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
    BEGIN { count = split(selected, wanted, ",") }
    {
        for (position = 1; position <= count; position++) {
            if ($1 == wanted[position]) print
        }
    }
' "$SK_GIT_TEST_INPUT"
STUB
chmod +x "$stub_bin/sk"

cat >"$stub_bin/open" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
[[ -n ${SK_GIT_TEST_OPEN:-} ]] || exit 1
printf '%s\n' "$@" >"$SK_GIT_TEST_OPEN"
STUB
chmod +x "$stub_bin/open"
ln -s "$stub_bin/open" "$stub_bin/xdg-open"

cat >"$stub_bin/ssh" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
if [[ -n ${SK_GIT_TEST_SSH_ARGS:-} ]]; then
    printf '%s\n' "$@" >"$SK_GIT_TEST_SSH_ARGS"
fi
if [[ ${1:-} == -G ]]; then
    printf 'hostname github.com\n'
fi
STUB
chmod +x "$stub_bin/ssh"
ln -s "$git_bin" "$missing_opener_bin/git"
ln -s "$awk_bin" "$missing_opener_bin/awk"
ln -s "$uname_bin" "$missing_opener_bin/uname"
ln -s "$stub_bin/ssh" "$missing_opener_bin/ssh"

git_repo="$tmp_dir/repository"
mkdir -p "$git_repo"
git -C "$git_repo" init -q -b main
git -C "$git_repo" config user.name "sk-git test"
git -C "$git_repo" config user.email "sk-git@example.invalid"
printf 'first\n' >"$git_repo/tracked.txt"
printf 'special\n' >"$git_repo/file with spaces.txt"
mkdir -p "$git_repo/nested"
printf 'nested\n' >"$git_repo/nested/tracked.txt"
git -C "$git_repo" add .
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
git -C "$git_repo" config branch.missing-remote.remote unavailable
git -C "$git_repo" update-ref refs/remotes/origin/main HEAD
git -C "$git_repo" worktree add -q "$tmp_dir/worktree" -b worktree-branch HEAD
git_repo_real=$(git -C "$git_repo" rev-parse --show-toplevel)
bare_repo="$tmp_dir/bare-repository"
git init -q --bare "$bare_repo"

head_hash=$(git -C "$git_repo" rev-parse --short HEAD)
feature_branch='feature/$cash'

run_picker() {
    local picker=$1 directory=$2 selection=${3:-} cancel=${4:-false}
    : >"$tmp_dir/sk-args"
    : >"$tmp_dir/sk-input"
    : >"$tmp_dir/sk-env"
    : >"$tmp_dir/commandline"
    : >"$tmp_dir/picker-output"
    PATH="$stub_bin:$PATH" \
        SK_GIT_TEST_ARGS="$tmp_dir/sk-args" \
        SK_GIT_TEST_INPUT="$tmp_dir/sk-input" \
        SK_GIT_TEST_ENV="$tmp_dir/sk-env" \
        SK_GIT_TEST_COMMANDLINE="$tmp_dir/commandline" \
        SK_GIT_TEST_SELECT="$selection" \
        SK_GIT_TEST_CANCEL="$cancel" \
        zsh -f -c '
            source "$1"
            cd "$2"
            "$3"
        ' zsh-sk-git-test "$zsh_config" "$directory" "$picker" >"$tmp_dir/picker-output"
}

run_widget() {
    local widget=$1 directory=$2 selection=${3:-} cancel=${4:-false}
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
        zsh -f -i -c '
            zle() { printf "%s\t%s\n" "$@" >>"$SK_GIT_TEST_COMMANDLINE"; }
            LBUFFER=
            source "$1"
            cd "$2"
            "$3"
            printf "%s" "$LBUFFER" >"$SK_GIT_TEST_LBUFFER"
        ' zsh-sk-git-test "$zsh_config" "$directory" "$widget"
}

assert_widget_buffer() {
    local widget=$1 directory=$2 selection=$3 expected=$4 message=$5
    run_widget "$widget" "$directory" "$selection"
    [[ $(<"$tmp_dir/lbuffer") == "$expected" ]] || fail "$message"
}

run_open() {
    local directory=$1 kind=$2 value=$3
    : >"$tmp_dir/open"
    : >"$tmp_dir/ssh-args"
    if ! PATH="$stub_bin:$PATH" \
        SK_GIT_TEST_OPEN="$tmp_dir/open" \
        SK_GIT_TEST_SSH_ARGS="$tmp_dir/ssh-args" \
        zsh -f -c '
            source "$1"
            cd "$2"
            __sk_git_open "$3" "$4"
        ' zsh-sk-git-test "$zsh_config" "$directory" "$kind" "$value"; then
        fail "open helper failed for $kind $value"
    fi
}

assert_picker_action() {
    local action=$1 message=$2
    rg -Fq -- "$action" "$tmp_dir/sk-args" || fail "$message"
}

assert_picker_action_exact() {
    local action=$1 message=$2
    rg -Fxq -- "$action" "$tmp_dir/sk-args" || fail "$message"
}

assert_open_action() {
    local kind=$1 picker=$2
    local action
    action="--bind=ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$zsh_config\" $kind {1})"
    rg -Fxq -- "$action" "$tmp_dir/sk-args" ||
        fail "$picker picker does not pass the module path positionally to its browser action"
}

assert_picker_window() {
    for picker_option in '--height=95%' '--min-height=12' '--border=rounded'; do
        rg -Fxq -- "$picker_option" "$tmp_dir/sk-args" ||
            fail "picker window is missing $picker_option"
    done
    rg -Fxq -- '--multi' "$tmp_dir/sk-args" || fail 'picker is not multi-select'
    rg -Fxq -- '--reverse' "$tmp_dir/sk-args" || fail 'picker is not reverse layout'
    rg -Fxq -- '--preview-window=down:70%:wrap' "$tmp_dir/sk-args" ||
        fail 'picker is missing the shared preview window'
    rg -Fxq -- '--bind=ctrl-/:toggle-preview' "$tmp_dir/sk-args" ||
        fail 'picker is missing preview toggle binding'
    [[ $(<"$tmp_dir/sk-env") == NO_COLOR_UNSET ]] ||
        fail 'picker inherited NO_COLOR'
}

run_picker __sk_git_hashes "$git_repo" "$head_hash"
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == "$head_hash " ]] ||
    fail 'hash picker did not return only the selected hash'
rg -Fq -- 'second commit' "$tmp_dir/sk-input" ||
    fail 'hash picker input is missing the commit subject'
for picker_option in '--ansi' $'--delimiter=\t' '--hide-nth=1' '--multi' '--reverse' '--no-sort'; do
    rg -Fxq -- "$picker_option" "$tmp_dir/sk-args" ||
        fail "hash picker is missing $picker_option"
done
rg -Fq -- 'DFT_COLOR=always git show --ext-diff --color=always {1}' "$tmp_dir/sk-args" ||
    fail 'hash picker is missing the git show preview'
rg -Fq -- 'ctrl-o:execute-silent' "$tmp_dir/sk-args" ||
    fail 'hash picker is missing ctrl-o action'
assert_open_action commit hash
rg -Fq -- 'ctrl-d:execute' "$tmp_dir/sk-args" ||
    fail 'hash picker is missing ctrl-d action'
assert_picker_action 'git diff --color=always {1} > /dev/tty' \
    'hash picker diff action does not write to /dev/tty'
rg -Fq -- 'ctrl-s:toggle-sort' "$tmp_dir/sk-args" ||
    fail 'hash picker is missing ctrl-s sort toggle'
rg -Fq -- 'alt-a:change-border-label(All hashes)+reload(' "$tmp_dir/sk-args" ||
    fail 'hash picker is missing the alt-a all-hashes reload action'
rg -Fq -- 'alt-a:change-border-label(All hashes)+reload(git log --all --date=short' "$tmp_dir/sk-args" ||
    fail 'hash picker all-hashes reload does not include --all'

run_open "$git_repo" commit "$head_hash"
[[ $(<"$tmp_dir/open") == "https://github.com/sk-git/test-repository/commit/$head_hash" ]] ||
    fail 'commit opener did not generate the expected remote commit URL'

export SK_GIT_TEST_LBUFFER="$tmp_dir/lbuffer"
assert_widget_buffer sk-git-hashes-widget "$git_repo" "$head_hash" "$head_hash " \
    'hash widget did not append the selected hash with a trailing space'

printf '%s\n' 'feature/$cash' |
    zsh -f -c 'source "$1"; __sk_git_join' zsh-sk-git-test "$zsh_config" >"$tmp_dir/join-output"
printf '%s' 'feature/\$cash ' >"$tmp_dir/join-expected"
cmp -s "$tmp_dir/join-expected" "$tmp_dir/join-output" ||
    fail 'hash join did not shell-quote a special-character value'

run_widget sk-git-hashes-widget "$git_repo" "$head_hash" true
[[ -z $(<"$tmp_dir/lbuffer") ]] ||
    fail 'hash widget changed LBUFFER after cancellation'

run_picker __sk_git_files "$git_repo" tracked.txt
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == tracked.txt ]] ||
    fail 'files picker did not return only the selected path'
rg -Fq -- 'tracked.txt' "$tmp_dir/sk-input" ||
    fail 'files picker input is missing tracked files'
rg -Fq -- 'file with spaces.txt' "$tmp_dir/sk-input" ||
    fail 'files picker input is missing ls-files output'
assert_picker_action 'ctrl-o:execute-silent' 'files picker is missing ctrl-o action'
assert_open_action file files
assert_picker_action 'alt-e:execute' 'files picker is missing alt-e editor action'
assert_picker_action 'alt-e:execute(${EDITOR:-vim} -- {1} > /dev/tty)' \
    'files picker editor action does not write to /dev/tty'
assert_picker_action 'git diff --no-ext-diff --color=always -- {1}' \
    'files picker is missing its diff preview'
assert_picker_action 'cat -- {1}' 'files picker is missing its file-content preview'
assert_picker_action 'source "$1"; __sk_git_open "$2" "$3"' \
    'files picker action does not source the positional module path'
assert_widget_buffer sk-git-files-widget "$git_repo" 'file with spaces.txt' \
    'file\ with\ spaces.txt ' \
    'files widget did not shell-quote the selected path'

run_picker __sk_git_branches "$git_repo" main
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == main ]] ||
    fail 'branches picker did not return only the selected branch'
rg -Fq -- $'main\t' "$tmp_dir/sk-input" ||
    fail 'branches picker input is missing main'
rg -Fxq -- '--hide-nth=1' "$tmp_dir/sk-args" ||
    fail 'branches picker is missing its hidden identifier field'
assert_picker_action 'git log --oneline --graph' 'branches picker is missing log preview'
assert_picker_action 'ctrl-o:execute-silent' 'branches picker is missing ctrl-o action'
assert_open_action branch branches
assert_picker_action 'alt-a:change-border-label(All branches)+reload(' \
    'branches picker is missing all-branches reload action'
assert_picker_action_exact \
    "--bind=alt-a:change-border-label(All branches)+reload(git for-each-ref --color=always --sort=-committerdate --format='%(refname:short)%09%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))%09%(color:blue)%(subject)%(color:reset)' refs/heads refs/remotes)" \
    'branches picker reload does not preserve the branch row format'
assert_widget_buffer sk-git-branches-widget "$git_repo" "$feature_branch" \
    'feature/\$cash ' \
    'branches widget did not shell-quote the selected branch'

run_picker __sk_git_tags "$git_repo" v1.0
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == v1.0 ]] ||
    fail 'tags picker did not return only the selected tag'
rg -Fq -- $'v1.0\t' "$tmp_dir/sk-input" ||
    fail 'tags picker input is missing v1.0'
assert_picker_action 'DFT_COLOR=always git show --ext-diff --color=always {1}' \
    'tags picker is missing git show preview'
assert_picker_action 'ctrl-o:execute-silent' 'tags picker is missing ctrl-o action'
assert_open_action tag tags
assert_widget_buffer sk-git-tags-widget "$git_repo" v1.0 'v1.0 ' \
    'tags widget did not insert the selected tag'

run_picker __sk_git_remotes "$git_repo" origin
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == origin ]] ||
    fail 'remotes picker did not return only the selected remote'
rg -Fq -- 'git@github.com:sk-git/test-repository.git' "$tmp_dir/sk-input" ||
    fail 'remotes picker input is missing origin URL'
awk -F '\t' '
    $1 == "origin" &&
    $2 == "origin" &&
    $3 == "git@github.com:sk-git/test-repository.git" { found = 1 }
    END { exit !found }
' "$tmp_dir/sk-input" ||
    fail 'remotes picker does not keep the remote name visible beside its URL'
assert_picker_action 'ctrl-o:execute-silent' 'remotes picker is missing ctrl-o action'
assert_open_action remote remotes
assert_picker_action '--remotes={1}' 'remotes picker is missing remote log preview'
assert_widget_buffer sk-git-remotes-widget "$git_repo" origin 'origin ' \
    'remotes widget did not insert the selected remote'

run_picker __sk_git_stashes "$git_repo" 'stash@{0}'
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == 'stash@{0}' ]] ||
    fail 'stashes picker did not return only the selected stash'
rg -Fq -- $'stash@{0}\t' "$tmp_dir/sk-input" ||
    fail 'stashes picker input is missing stash@{0}'
assert_picker_action 'DFT_COLOR=always git show --ext-diff --color=always {1}' \
    'stashes picker is missing git show preview'
assert_picker_action 'ctrl-x:reload(git stash drop -q {1}; git stash list' \
    'stashes picker is missing drop-and-reload action'
assert_picker_action_exact \
    "--bind=ctrl-x:reload(git stash drop -q {1}; git stash list --format='%gd%x09%C(yellow)%gs%C(reset)')" \
    'stashes picker reload does not preserve the stash row format'
assert_widget_buffer sk-git-stashes-widget "$git_repo" 'stash@{0}' \
    'stash@\{0\} ' \
    'stashes widget did not shell-quote the selected stash'

run_picker __sk_git_reflogs "$git_repo" 'HEAD@{0}'
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == 'HEAD@{0}' ]] ||
    fail 'reflogs picker did not return only the selected reflog'
rg -Fq -- $'HEAD@{0}\t' "$tmp_dir/sk-input" ||
    fail 'reflogs picker input is missing HEAD@{0}'
assert_picker_action 'DFT_COLOR=always git show --ext-diff --color=always {1}' \
    'reflogs picker is missing git show preview'
assert_widget_buffer sk-git-reflogs-widget "$git_repo" 'HEAD@{0}' \
    'HEAD@\{0\} ' \
    'reflog widget did not insert the selected reflog identifier'

run_picker __sk_git_each_ref "$git_repo" refs/heads/main
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == refs/heads/main ]] ||
    fail 'each-ref picker did not return only the selected ref'
rg -Fq -- $'refs/heads/main\t' "$tmp_dir/sk-input" ||
    fail 'each-ref picker input is missing refs table'
if rg -Fq -- $'refs/remotes/origin/main\t' "$tmp_dir/sk-input"; then
    fail 'each-ref picker included remote refs before the all-refs reload'
fi
awk -F '\t' '$1 == "refs/heads/main" && $2 ~ /refs\/heads\/main/ { found = 1 } END { exit !found }' \
    "$tmp_dir/sk-input" ||
    fail 'each-ref picker hid the ref name without a visible copy'
assert_picker_action 'git log --oneline --graph' 'each-ref picker is missing log preview'
assert_picker_action 'ctrl-o:execute-silent' 'each-ref picker is missing ctrl-o action'
assert_open_action ref each-ref
assert_picker_action 'alt-e:execute' 'each-ref picker is missing alt-e editor action'
assert_picker_action 'alt-e:execute(${EDITOR:-vim} <(git show {1}) > /dev/tty)' \
    'each-ref picker editor action does not write to /dev/tty'
assert_picker_action 'alt-a:change-border-label(All refs)+reload(' \
    'each-ref picker is missing all-refs reload action'
assert_picker_action_exact \
    "--bind=alt-a:change-border-label(All refs)+reload(git for-each-ref --color=always --sort=-creatordate --sort=-HEAD --format='%(refname)%09%(color:yellow)%(refname) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)')" \
    'each-ref picker reload does not preserve the ref row format'
assert_widget_buffer sk-git-each-ref-widget "$git_repo" refs/heads/main \
    'refs/heads/main ' \
    'each-ref widget did not insert the selected ref'

run_picker __sk_git_worktrees "$git_repo" "$git_repo_real"
assert_picker_window
[[ $(<"$tmp_dir/picker-output") == "$git_repo_real" ]] ||
    fail 'worktrees picker did not return only the selected worktree path'
rg -Fq -- "$git_repo_real" "$tmp_dir/sk-input" ||
    fail 'worktrees picker input is missing the primary worktree path'
rg -Fq -- "$git_repo_real"$'\t'"$git_repo_real"$'\t' "$tmp_dir/sk-input" ||
    fail 'worktrees picker hid the worktree path without a visible copy'
assert_picker_action 'ctrl-x:reload(zsh -f -c' \
    'worktrees picker is missing remove-and-reload action'
assert_picker_action 'source "$1"; git worktree remove "$2" > /dev/null; __sk_git_worktree_rows' \
    'worktrees picker reload does not preserve its row format'
assert_picker_action_exact \
    "--bind=ctrl-x:reload(zsh -f -c 'source \"\$1\"; git worktree remove \"\$2\" > /dev/null; __sk_git_worktree_rows' -- \"$zsh_config\" {1})" \
    'worktrees picker does not pass the module path positionally to its remove-and-reload action'
assert_widget_buffer sk-git-worktrees-widget "$git_repo" "$git_repo_real" \
    "$git_repo_real " \
    'worktrees widget did not insert the selected worktree path'

run_open "$git_repo" branch main
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/tree/main' ]] ||
    fail 'branch opener did not generate the expected GitHub SSH URL'
run_open "$git_repo" branch origin/main
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/tree/main' ]] ||
    fail 'remote branch opener did not remove the remote prefix'
run_open "$git_repo" commit "$head_hash"
[[ $(<"$tmp_dir/open") == "https://github.com/sk-git/test-repository/commit/$head_hash" ]] ||
    fail 'commit opener did not generate the expected GitHub SSH URL'
run_open "$git_repo" branch 'feature/$cash'
[[ $(<"$tmp_dir/open") == 'https://gitlab.com/sk-git/test-repository/tree/feature/$cash' ]] ||
    fail 'branch opener did not use the configured HTTPS remote'
[[ ! -s "$tmp_dir/ssh-args" ]] ||
    fail 'branch opener invoked ssh for an HTTPS remote'
git -C "$git_repo" branch alias-branch main
run_open "$git_repo" branch alias-branch
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/alias-repository/tree/alias-branch' ]] ||
    fail 'branch opener did not resolve the configured SSH host alias'
[[ $(<"$tmp_dir/ssh-args") == $'-G\nghcny' ]] ||
    fail 'branch opener did not resolve the configured SSH host with ssh -G'
run_open "$git_repo" remote https
[[ $(<"$tmp_dir/open") == 'https://gitlab.com/sk-git/test-repository/tree/main' ]] ||
    fail 'remote opener did not generate the expected remote tree URL'
run_open "$git_repo" file tracked.txt
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/blob/main/tracked.txt' ]] ||
    fail 'file opener did not generate the expected remote blob URL'
run_open "$git_repo/nested" file tracked.txt
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/blob/main/nested/tracked.txt' ]] ||
    fail 'file opener did not include the repository-relative path prefix'
run_open "$git_repo" tag v1.0
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/releases/tag/v1.0' ]] ||
    fail 'tag opener did not generate the expected remote release URL'
run_open "$git_repo" ref refs/heads/main
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/tree/main' ]] ||
    fail 'local-ref opener did not generate the expected remote tree URL'
run_open "$git_repo" ref refs/remotes/origin/main
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/tree/main' ]] ||
    fail 'remote-ref opener did not generate the expected remote tree URL'
run_open "$git_repo" ref refs/tags/v1.0
[[ $(<"$tmp_dir/open") == 'https://github.com/sk-git/test-repository/releases/tag/v1.0' ]] ||
    fail 'tag-ref opener did not generate the expected remote release URL'

missing_opener_output=$(PATH="$missing_opener_bin" \
    SK_GIT_TEST_SSH_ARGS="$tmp_dir/ssh-args" \
    "$zsh_bin" -f -c '
    source "$1"
    cd "$2"
    LBUFFER=unchanged
    __sk_git_open branch main && exit 1
    print -r -- "$LBUFFER"
' zsh-sk-git-test "$zsh_config" "$git_repo")
[[ "$missing_opener_output" == unchanged ]] ||
    fail 'missing opener changed LBUFFER or returned success'
: >"$tmp_dir/open"
missing_remote_output=$(PATH="$stub_bin:$PATH" \
    SK_GIT_TEST_OPEN="$tmp_dir/open" \
    SK_GIT_TEST_SSH_ARGS="$tmp_dir/ssh-args" \
    zsh -f -c '
    source "$1"
    cd "$2"
    LBUFFER=unchanged
    __sk_git_open branch missing-remote && exit 1
    print -r -- "$LBUFFER"
' zsh-sk-git-test "$zsh_config" "$git_repo")
[[ "$missing_remote_output" == unchanged ]] ||
    fail 'missing remote changed LBUFFER or returned success'
[[ ! -s "$tmp_dir/open" ]] ||
    fail 'missing remote invoked the opener'

bindings=$(PATH="$stub_bin:$PATH" zsh -f -i -c '
    zle() { :; }
    bindkey() { print -r -- "$2"$'\''\t'\''"$3"$'\''\t'\''"$4"; }
    source "$1"
' zsh-sk-git-test "$zsh_config")
[[ $(printf '%s\n' "$bindings" | awk 'END { print NR }') == 54 ]] ||
    fail 'unexpected number of sk-git bindings'
for widget_spec in \
    hashes:h \
    files:f \
    branches:b \
    tags:t \
    remotes:r \
    stashes:s \
    reflogs:l \
    each-ref:e \
    worktrees:w; do
    widget=${widget_spec%%:*}
    key=${widget_spec#*:}
    widget_name="sk-git-$widget-widget"
    for keymap in emacs viins vicmd; do
        for key_sequence in "^g^$key" "^g$key"; do
            binding="$keymap"$'\t'"$key_sequence"$'\t'"$widget_name"
            [[ $(printf '%s\n' "$bindings" | rg -Fxc -- "$binding") == 1 ]] ||
                fail "$widget_name is missing $key_sequence in $keymap"
        done
    done
done
deferred_bindings=$(PATH="$stub_bin:$PATH" zsh -f -i -c '
    zle() { :; }
    bindkey() { :; }
    zsh-defer() { print -r -- "$1"; }
    source "$1"
' zsh-sk-git-test "$zsh_config")
[[ "$deferred_bindings" == '__sk_git_bind_keys' ]] ||
    fail 'sk-git bindings were not deferred until after deferred plugins'
noninteractive_bindings=$(PATH="$stub_bin:$PATH" zsh -f -c '
    bindkey() { print -r -- called; }
    source "$1"
' zsh-sk-git-test "$zsh_config")
[[ -z "$noninteractive_bindings" ]] ||
    fail 'widgets were bound outside an interactive shell'
missing_sk_bindings=$(PATH="$missing_opener_bin" "$zsh_bin" -f -i -c '
    zle() { print -r -- called; }
    bindkey() { print -r -- called; }
    source "$1"
' zsh-sk-git-test "$zsh_config")
[[ -z "$missing_sk_bindings" ]] ||
    fail 'widgets were registered without sk'
missing_git_bindings=$(PATH="$stub_bin" "$zsh_bin" -f -i -c '
    zle() { print -r -- called; }
    bindkey() { print -r -- called; }
    source "$1"
' zsh-sk-git-test "$zsh_config")
[[ -z "$missing_git_bindings" ]] ||
    fail 'widgets were registered without git'

run_widget sk-git-files-widget "$bare_repo"
[[ ! -s "$tmp_dir/sk-args" ]] ||
    fail 'bare repository widget invoked sk'
[[ -z $(<"$tmp_dir/lbuffer") ]] ||
    fail 'bare repository widget changed LBUFFER'

printf 'zsh sk-git regression harness passed\n'
