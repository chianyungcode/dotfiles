if [[ $(command -v gh) ]]; then
  if gh auth status &>/dev/null && gh extension list | grep -q "copilot"; then
    [[ -n ${ZSH_NAME} ]] && eval "$(gh copilot alias -- zsh)"
    [[ -n ${BASH} ]] && eval "$(gh copilot alias -- bash)"
  fi
fi
