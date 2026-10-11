typeset -g __sk_git_script="${${(%):-%N}:A}"

__sk_git_check() {
  (( $+commands[git] && $+commands[sk] )) || return 1
  [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == true ]]
}

__sk_git_preview_window() { print -r -- 'down:70%:wrap'; }

__sk_git_picker_window() {
  print -r -- '--height=95%'
  print -r -- '--min-height=12'
  print -r -- '--border=rounded'
  if [[ -n ${TMUX:-} || -n ${ZELLIJ:-} ]]; then
    print -r -- '--popup=center,40%'
  fi
}

__sk_git_join() {
  local item
  while IFS= read -r item; do
    print -rn -- "${(q)item} "
  done
}

__sk_git_insert() {
  local item
  for item in "$@"; do
    [[ -n "$item" ]] || continue
    LBUFFER+="${(q)item} "
  done
  zle reset-prompt 2>/dev/null || true
}

__sk_git_open() {
  local kind=$1 value=$2 current_branch remote remote_candidate remote_url remote_parts ssh_host web_host web_path
  [[ -n "$kind" && -n "$value" ]] || return 1

  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return 1
  if [[ "$current_branch" == HEAD ]]; then
    current_branch=$(git describe --exact-match --tags 2>/dev/null || git rev-parse --short HEAD) || return 1
  fi

  case "$kind" in
    commit)
      web_path="/commit/${value}"
      ;;
    branch)
      current_branch=$value
      remote=$(git config --get "branch.${current_branch}.remote" 2>/dev/null) || remote=
      if [[ -z "$remote" && "$current_branch" == */* ]]; then
        remote_candidate=${current_branch%%/*}
        if git remote get-url "$remote_candidate" >/dev/null 2>&1; then
          remote=$remote_candidate
          current_branch=${current_branch#*/}
        fi
      fi
      [[ -n "$remote" ]] || remote=origin
      web_path="/tree/${current_branch}"
      ;;
    remote)
      remote=$value
      web_path="/tree/${current_branch}"
      ;;
    file)
      web_path="/blob/${current_branch}/$(git rev-parse --show-prefix 2>/dev/null)${value}"
      ;;
    tag)
      web_path="/releases/tag/${value}"
      ;;
    ref)
      case "$value" in
        refs/heads/*)
          current_branch=${value#refs/heads/}
          remote=$(git config --get "branch.${current_branch}.remote" 2>/dev/null) || remote=origin
          web_path="/tree/${current_branch}"
          ;;
        refs/remotes/*/*)
          remote=${value#refs/remotes/}
          remote=${remote%%/*}
          current_branch=${value#refs/remotes/${remote}/}
          web_path="/tree/${current_branch}"
          ;;
        refs/tags/*)
          web_path="/releases/tag/${value#refs/tags/}"
          ;;
        *) return 1 ;;
      esac
      ;;
    *) return 1 ;;
  esac

  [[ -n "$remote" ]] || remote=$(git config --get "branch.${current_branch}.remote" 2>/dev/null) || remote=origin
  remote_url=$(git remote get-url "$remote" 2>/dev/null) || return 1
  remote_url=${remote_url%.git}
  if [[ "$remote_url" =~ '^[^/:]+:[^/].*' ]]; then
    remote_parts=("${(@s/:/)remote_url}")
    ssh_host=${remote_parts[1]##*@}
    web_host=$ssh_host
    if (( $+commands[ssh] )); then
      web_host=$(ssh -G "$ssh_host" 2>/dev/null | awk '/^hostname / { print $2; exit }')
      [[ -n "$web_host" ]] || web_host=$ssh_host
    fi
    remote_url="https://${web_host}/${remote_parts[2]}"
  elif [[ "$remote_url" != http://* && "$remote_url" != https://* ]]; then
    return 1
  fi

  case "$(uname -s)" in
    Darwin)
      (( $+commands[open] )) || return 1
      command open "${remote_url}${web_path}"
      ;;
    *)
      (( $+commands[xdg-open] )) || return 1
      command xdg-open "${remote_url}${web_path}"
      ;;
  esac
}

__sk_git_hashes() {
  __sk_git_check || return

  git log --date=short --color=always \
    --format='%h%x09%C(green)%ad %C(auto)%h%d %s %C(blue)(%an)%C(reset)' 2>/dev/null |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse --no-sort \
      --header='CTRL-O open in browser | CTRL-D show diff | CTRL-S toggle sort | ALT-A all hashes | CTRL-/ toggle preview' \
      --prompt='hashes> ' \
      --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$__sk_git_script\" commit {1})" \
      --bind='ctrl-d:execute(git diff --color=always {1} > /dev/tty)' \
      --bind='ctrl-s:toggle-sort' \
      --bind="alt-a:change-border-label(All hashes)+reload(git log --all --date=short --color=always --format='%h%x09%C(green)%ad %C(auto)%h%d %s %C(blue)(%an)%C(reset)')" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1 |
    __sk_git_join
}

sk-git-hashes-widget() {
  local selected
  selected=$({ __sk_git_hashes || exit $?; print -rn -- . }) || return
  selected=${selected%.}
  LBUFFER+=$selected
  zle reset-prompt 2>/dev/null || true
}

__sk_git_files() {
  __sk_git_check || return

  {
    git status --short --no-branch 2>/dev/null | sed 's/^...//; s/.* -> //'
    git ls-files 2>/dev/null
  } | sort -u |
    awk '{ print $0 "\t" $0 }' |
    env -u NO_COLOR sk --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-O open in browser | ALT-E edit file | CTRL-/ toggle preview' \
      --prompt='files> ' \
      --preview='git diff --no-ext-diff --color=always -- {1} | sed 1,4d; cat -- {1}' \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$__sk_git_script\" file {1})" \
      --bind='alt-e:execute(${EDITOR:-vim} -- {1} > /dev/tty)' \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_branches() {
  __sk_git_check || return

  git for-each-ref --color=always --sort=-committerdate \
    --format='%(refname:short)%09%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))%09%(color:blue)%(subject)%(color:reset)' \
    refs/heads 2>/dev/null |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-O open in browser | ALT-A all branches | CTRL-/ toggle preview' \
      --prompt='branches> ' \
      --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' {1} --" \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$__sk_git_script\" branch {1})" \
      --bind="alt-a:change-border-label(All branches)+reload(git for-each-ref --color=always --sort=-committerdate --format='%(refname:short)%09%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))%09%(color:blue)%(subject)%(color:reset)' refs/heads refs/remotes)" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_tags() {
  __sk_git_check || return

  git for-each-ref --color=always --sort=-creatordate \
    --format='%(refname:short)%09%(color:yellow)%(refname:short) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)' \
    refs/tags 2>/dev/null |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-O open in browser | CTRL-/ toggle preview' \
      --prompt='tags> ' \
      --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$__sk_git_script\" tag {1})" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_remotes() {
  __sk_git_check || return

  git remote -v 2>/dev/null | sort | awk '{ print $1 "\t" $1 "\t" $2 }' | uniq |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-O open in browser | CTRL-/ toggle preview' \
      --prompt='remotes> ' \
      --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' --remotes={1} --" \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$__sk_git_script\" remote {1})" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_stashes() {
  __sk_git_check || return

  git stash list --format='%gd%x09%C(yellow)%gs%C(reset)' 2>/dev/null |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-X drop stash | CTRL-/ toggle preview' \
      --prompt='stashes> ' \
      --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-x:reload(git stash drop -q {1}; git stash list --format='%gd%x09%C(yellow)%gs%C(reset)')" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_reflogs() {
  __sk_git_check || return

  git reflog --format='%gD%x09%C(yellow)%h%C(auto) %gs%C(reset)' 2>/dev/null |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-/ toggle preview' \
      --prompt='reflogs> ' \
      --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_each_ref() {
  __sk_git_check || return

  git for-each-ref --color=always --sort=-creatordate --sort=-HEAD \
    --format='%(refname)%09%(color:yellow)%(refname) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)' 2>/dev/null |
    grep -v '^refs/remotes/' |
    env -u NO_COLOR sk --ansi --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-O open in browser | ALT-E view in editor | ALT-A all refs | CTRL-/ toggle preview' \
      --prompt='refs> ' \
      --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' {1} --" \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-o:execute-silent(zsh -f -c 'source \"\$1\"; __sk_git_open \"\$2\" \"\$3\"' -- \"$__sk_git_script\" ref {1})" \
      --bind='alt-e:execute(${EDITOR:-vim} <(git show {1}) > /dev/tty)' \
      --bind="alt-a:change-border-label(All refs)+reload(git for-each-ref --color=always --sort=-creatordate --sort=-HEAD --format='%(refname)%09%(color:yellow)%(refname) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)')" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

__sk_git_worktree_rows() {
  git worktree list --porcelain 2>/dev/null |
    awk '
      /^worktree / { path = substr($0, 10) }
      /^HEAD / { head = $2 }
      /^branch / { branch = $2 }
      /^$/ { if (path != "") print path "\t" path "\t" head "\t" branch; path = head = branch = "" }
      END { if (path != "") print path "\t" path "\t" head "\t" branch }
    '
}

__sk_git_worktrees() {
  __sk_git_check || return

  __sk_git_worktree_rows |
    env -u NO_COLOR sk --delimiter=$'\t' --hide-nth=1 --multi --reverse \
      --header='CTRL-X remove worktree | CTRL-/ toggle preview' \
      --prompt='worktrees> ' \
      --preview='git -c color.status=always -C {1} status --short --branch; echo; git log --oneline --graph --date=short --color=always --pretty=format:"%C(auto)%cd %h%d %s" {3} --' \
      --preview-window="$(__sk_git_preview_window)" \
      "${(@f)$(__sk_git_picker_window)}" \
      --bind="ctrl-x:reload(zsh -f -c 'source \"\$1\"; git worktree remove \"\$2\" > /dev/null; __sk_git_worktree_rows' -- \"$__sk_git_script\" {1})" \
      --bind='ctrl-/:toggle-preview' |
    cut -f1
}

sk-git-files-widget() { local result; result="$(__sk_git_files | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-branches-widget() { local result; result="$(__sk_git_branches | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-tags-widget() { local result; result="$(__sk_git_tags | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-remotes-widget() { local result; result="$(__sk_git_remotes | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-stashes-widget() { local result; result="$(__sk_git_stashes | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-reflogs-widget() { local result; result="$(__sk_git_reflogs | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-each-ref-widget() { local result; result="$(__sk_git_each_ref | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }
sk-git-worktrees-widget() { local result; result="$(__sk_git_worktrees | __sk_git_join)"; [[ -n "$result" ]] && LBUFFER+="$result"; zle reset-prompt 2>/dev/null || true; }

if [[ -o interactive ]] && (( $+commands[git] && $+commands[sk] )); then
  zle -N sk-git-hashes-widget
  zle -N sk-git-files-widget
  zle -N sk-git-branches-widget
  zle -N sk-git-tags-widget
  zle -N sk-git-remotes-widget
  zle -N sk-git-stashes-widget
  zle -N sk-git-reflogs-widget
  zle -N sk-git-each-ref-widget
  zle -N sk-git-worktrees-widget

  for keymap in emacs viins vicmd; do
    bindkey -M "$keymap" '^g^h' sk-git-hashes-widget
    bindkey -M "$keymap" '^gh' sk-git-hashes-widget
    bindkey -M "$keymap" '^g^f' sk-git-files-widget
    bindkey -M "$keymap" '^gf' sk-git-files-widget
    bindkey -M "$keymap" '^g^b' sk-git-branches-widget
    bindkey -M "$keymap" '^gb' sk-git-branches-widget
    bindkey -M "$keymap" '^g^t' sk-git-tags-widget
    bindkey -M "$keymap" '^gt' sk-git-tags-widget
    bindkey -M "$keymap" '^g^r' sk-git-remotes-widget
    bindkey -M "$keymap" '^gr' sk-git-remotes-widget
    bindkey -M "$keymap" '^g^s' sk-git-stashes-widget
    bindkey -M "$keymap" '^gs' sk-git-stashes-widget
    bindkey -M "$keymap" '^g^l' sk-git-reflogs-widget
    bindkey -M "$keymap" '^gl' sk-git-reflogs-widget
    bindkey -M "$keymap" '^g^e' sk-git-each-ref-widget
    bindkey -M "$keymap" '^ge' sk-git-each-ref-widget
    bindkey -M "$keymap" '^g^w' sk-git-worktrees-widget
    bindkey -M "$keymap" '^gw' sk-git-worktrees-widget
  done
fi
