alias c="code"
alias cl="clear"
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias mux="tmuxinator"
alias fier="tmuxifier"

# pueue
alias p="pueue"

# bun
alias bfzf="bun run \"\$(jq -r '.scripts | keys[]' package.json | fzf --no-border)\""

# pet
alias pexec="pet exec -t"

# chezmoi
alias chz="chezmoi"

# Directories
alias dotfiles="cd $DOTFILES"
alias config="cd $HOME/.config/"
