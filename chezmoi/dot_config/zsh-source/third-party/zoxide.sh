#!/usr/bin/env bash

# if [[ "$(command -v zoxide)" ]] && [[ -n ${ZSH_NAME} ]]; then
#   # eval eval "$(zoxide init --cmd cd zsh)"
#   eval "$(zoxide init zsh)"
#   cd() {
#     # Always print contents of directory when entering
#     __zoxide_z "$@" || return 1
#     ll
#   }
#
# elif [[ "$(command -v zoxide)" ]] && [[ -n ${BASH} ]]; then
#   # eval "$(zoxide init --cmd cd bash)"
#   eval "$(zoxide init bash)"
#
#   cd() {
#     # Always print contents of directory when entering
#     __zoxide_z "$@" || return 1
#     ll
#   }
# fi
#

# Widget Zsh: pilih direktori dari zoxide dengan preview dan langsung cd
fzf_zoxide_widget() {
  local selection dir
  selection=$(zoxide query -ls | sort -nr | fzf \
    --height=40% \
    --reverse \
    --prompt="Zoxide > " \
    --preview 'exa -1 --color=always {2} 2>/dev/null || ls -la --color=always {2}' \
    --preview-window=right:40%:wrap)

  # Ambil kolom path saja (kolom kedua)
  dir=$(echo "$selection" | awk '{ $1=""; sub(/^ /,""); print }')

  if [[ -n $dir ]]; then
    builtin cd "$dir" || return
    zle accept-line
  fi
}

zle -N fzf_zoxide_widget
bindkey '^[^Z' fzf_zoxide_widget
