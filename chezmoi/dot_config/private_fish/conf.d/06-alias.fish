#  █████╗ ██╗     ██╗ █████╗ ███████╗
# ██╔══██╗██║     ██║██╔══██╗██╔════╝
# ███████║██║     ██║███████║███████╗
# ██╔══██║██║     ██║██╔══██║╚════██║
# ██║  ██║███████╗██║██║  ██║███████║
# ╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚══════╝
# A simple wrapper for the function builtin, which creates a function wrapping a command
# https://fishshell.com/docs/current/cmds/alias.html

alias cl='clear'
alias mux='tmuxinator'
alias fier='tmuxifier'
alias nv='nvim'
alias lzg='lazygit'
alias lzd='lazydocker'
alias clrnvses='rm -rf ~/.local/share/nvim/sessions/*'
alias ax='chmod a+x' # system: make file executable
alias untar='tar -zxvf' # Extract tar.gz file
alias mktar='tar -cvzf' # Create a tar.gz file
alias numfiles='echo $(ls -1 | wc -l)' # Count of non-hidden files in current directories
alias bkzsh='bindkey | fzf'
alias bktmux='tmux list-keys | fzf'

# pueue
alias pue="pueue"

# bun
alias bfzf="bun run \"\$(jq -r '.scripts | keys[]' package.json | fzf --no-border)\""

# pet
alias pexec="pet exec -t"
alias psc="pet search"

# Directories
alias dotf="cd ~/.local/share/chezmoi"
alias config="cd ~/.config/"

alias exz="exec zsh"
