if (( $+commands[sk] && $+commands[fd] )); then
  skim-ctrl-t-widget() {
    local -a selected
    local query="${LBUFFER##* }"
    local prefix="$LBUFFER"

    if [[ -n "$query" ]]; then
      prefix="${LBUFFER[1,$(( ${#LBUFFER} - ${#query} ))]}"
    fi

    selected=("${(@f)$(
      fd --hidden --exclude .git --type f --type d |
        sk --preview 'bat {} --color=always' -m --reverse --query "$query"
    )}")

    if (( ${#selected[@]} )); then
      LBUFFER="$prefix"
      for item in "${selected[@]}"; do
        LBUFFER+="${(q)item} "
      done
    fi

    zle reset-prompt
  }

  zle -N skim-ctrl-t-widget

  _bind-skim-ctrl-t() {
    bindkey '^T' skim-ctrl-t-widget
  }

  if (( $+functions[zsh-defer] )); then
    zsh-defer _bind-skim-ctrl-t
  else
    _bind-skim-ctrl-t
  fi
fi
