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
