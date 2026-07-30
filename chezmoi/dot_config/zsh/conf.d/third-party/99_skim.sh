if (( $+commands[sk] && $+commands[fd] )); then
  skim-ctrl-t-widget() {
    local -a selected
    local query="${LBUFFER##* }"
    local prefix="$LBUFFER"
    local preview_window="right:50%"
    local terminal_width="${COLUMNS:-}"

    if [[ -z "$terminal_width" ]]; then
      terminal_width="$(tput cols 2>/dev/null)"
    fi

    if [[ "$terminal_width" == <-> ]] && (( terminal_width < 120 )); then
      preview_window="down:40%:wrap"
    fi

    if [[ -n "$query" ]]; then
      prefix="${LBUFFER[1,$(( ${#LBUFFER} - ${#query} ))]}"
    fi

    selected=("${(@f)$(
      fd --hidden --exclude .git --type f --type d |
        sk  --border=rounded --regex --preview 'if [ -d {} ]; then CLICOLOR_FORCE=1 lla -a {}; else bat -n --color=always {}; fi' --preview-window="$preview_window" --bind 'ctrl-/:toggle-preview' -m --reverse --query "$query"
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
