#!/usr/bin/env zsh

# source <(COMPLETE=zsh jj)

# Jujutsu aliases run in a child process, so they cannot change the parent
# shell's directory themselves. Apply the paths printed by wq/wcd/wacd here.
jj() {
  case "${1-}" in
    wq|wcd|wacd)
      local destination
      destination="$(command jj "$@")" || return

      if [[ ! -d "$destination" ]]; then
        echo "jj: workspace directory does not exist: $destination" >&2
        return 1
      fi

      builtin cd -- "$destination"
      ;;
    *)
      command jj "$@"
      ;;
  esac
}
