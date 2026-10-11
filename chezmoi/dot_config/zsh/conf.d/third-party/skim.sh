if (( $+commands[sk] && $+commands[fd] )); then
  skim-ctrl-t-widget() {
    local -a selected result files
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

    while true; do
      result=("${(@f)$(
        fd --hidden --exclude .git --type f --type d --type symlink |
          sk  --border=rounded --height=80% --regex --preview 'if [ -d {} ]; then CLICOLOR_FORCE=1 lla -a {}; else bat -n --color=always {}; fi' --preview-window="$preview_window" --header='CTRL-E edit marked files | CTRL-D cd directory | CTRL-/ toggle preview' --bind 'ctrl-e:accept(ctrl-e)' --bind 'ctrl-d:accept(ctrl-d)' --bind 'ctrl-q:abort' --bind 'ctrl-/:toggle-preview' -m --reverse --query "$query"
      )}")

      if (( ! ${#result[@]} )); then
        break
      fi

      if [[ "${result[1]}" == ctrl-e ]]; then
        files=()
        if (( ${#result[@]} > 1 )); then
          for item in "${(@)result[2,-1]}"; do
            [[ -f "$item" ]] && files+=("$item")
          done
        fi

        if (( ${#files[@]} )); then
          local editor="${EDITOR:-vim}"
          ${=editor} -- "${files[@]}"
        fi

        selected=()
        break
      fi

      if [[ "${result[1]}" == ctrl-d ]]; then
        if [[ -d "${result[2]}" ]]; then
          cd -- "${result[2]}" || continue
          query=""
        fi
        continue
      fi

      selected=("${result[@]}")
      break
    done

    if (( ${#selected[@]} )) && [[ -n "${selected[1]}" ]]; then
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
