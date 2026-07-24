#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi git jj rg; do
    command -v "$command_name" >/dev/null || {
        printf 'missing required command: %s\n' "$command_name" >&2
        exit 1
    }
done

config_file="$tmp_dir/chezmoi.toml"
chezmoi -S "$source_dir" -c "$tmp_dir/missing.toml" execute-template --init \
    --file "$source_dir/.chezmoi.toml.tmpl" >"$config_file"

git_config="$tmp_dir/gitconfig"
chezmoi -S "$source_dir" -c "$config_file" execute-template \
    --file "$source_dir/dot_config/git/config.tmpl" >"$git_config"

[[ $(git config --file "$git_config" --get user.name) == \
    chianyungcode-server ]]
[[ $(git config --file "$git_config" --get user.email) == \
    chianyungcode-server@local.invalid ]]
if git config --file "$git_config" \
    --get credential.https://github.com.username >/dev/null; then
    printf 'server Git config unexpectedly has a GitHub username\n' >&2
    exit 1
fi
if git config --file "$git_config" --get user.signingkey >/dev/null; then
    printf 'server Git config unexpectedly has a signing key\n' >&2
    exit 1
fi
if [[ $(git config --file "$git_config" --bool --get commit.gpgsign \
    2>/dev/null || true) == true ]]; then
    printf 'server Git config unexpectedly enables commit signing\n' >&2
    exit 1
fi

git_repo="$tmp_dir/git-repo"
mkdir -p "$git_repo" "$tmp_dir/home"
GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
    git -C "$git_repo" init -q
printf 'emergency\n' >"$git_repo/emergency.txt"
GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
    git -C "$git_repo" add emergency.txt
GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
    git -C "$git_repo" commit -q -m emergency
git_identity=$( 
    GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
        git -C "$git_repo" log -1 --format='%an|%ae|%s'
)
[[ "$git_identity" == \
    'chianyungcode-server|chianyungcode-server@local.invalid|emergency' ]]

jj_config="$tmp_dir/jj-config.toml"
chezmoi -S "$source_dir" -c "$config_file" execute-template \
    --file "$source_dir/dot_config/jj/config.toml.tmpl" >"$jj_config"

[[ $(JJ_CONFIG="$jj_config" jj config list signing.backend \
    -T 'value ++ "\n"') == '"none"' ]]
[[ $(JJ_CONFIG="$jj_config" jj config list signing.behavior \
    -T 'value ++ "\n"') == '"drop"' ]]
if [[ -n $(JJ_CONFIG="$jj_config" jj config list signing.key 2>/dev/null) ]]; then
    printf 'server Jujutsu config unexpectedly has a signing key\n' >&2
    exit 1
fi

jj_repo="$tmp_dir/jj-repo"
JJ_CONFIG="$jj_config" jj git init "$jj_repo" >/dev/null
printf 'emergency\n' >"$jj_repo/emergency.txt"
JJ_CONFIG="$jj_config" jj -R "$jj_repo" describe -m emergency >/dev/null
jj_identity=$( 
    JJ_CONFIG="$jj_config" jj -R "$jj_repo" log -r @ --no-graph \
        -T 'author.name() ++ "|" ++ author.email() ++ "|" ++ description.first_line() ++ "\n"'
)
[[ "$jj_identity" == \
    'chianyungcode-server|chianyungcode-server@local.invalid|emergency' ]]

if rg -q 'onepasswordRead|github_username.*chianyungcode' \
    "$git_config" "$jj_config"; then
    printf 'server VCS config unexpectedly contains secret-backed identity data\n' >&2
    exit 1
fi

printf 'chezmoi local VCS commits passed\n'
