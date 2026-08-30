for _f in ${HOME}/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.zsh(N); do
  source $_f; break
done

# Stop and delete a Herdr session in one command.
function hsd() {
  if [[ $# -ne 1 ]]; then
    print -u2 "Usage: hsd <session>"
    return 2
  fi

  local session="$1"
  herdr session stop "$session" && herdr session delete "$session"
}
