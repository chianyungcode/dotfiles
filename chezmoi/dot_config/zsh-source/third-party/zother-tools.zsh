# Starship prompt
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Tmuxifier
eval "$(tmuxifier init -)"

# Atuin
eval "$(atuin init zsh)"

# Bun Completions
[ -f "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# FZF Git integration
source $HOME/.config/fzf-git/fzf-git.sh

# 1Password
source $HOME/.config/op/plugins.sh
