
#--------------------
# Oh-My-Zsh Setup
#--------------------
# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/

# export ZSH="$HOME/.oh-my-zsh"

# === plugins ===
# plugins=(
#     direnv
#     git 
#     git-commit 
#     bun 
#     1password 
#     npm 
#     you-should-use 
#     zsh-autosuggestions 
#     zsh-syntax-highlighting 
#     aliases 
#     copypath 
#     brew 
#     docker 
#     docker-compose 
#     gitignore 
#     # zsh-abbr
#     # asdf
# )

# Load Oh-My-Zsh
# source $ZSH/oh-my-zsh.sh


#--------------------
# antidote setup
# https://antidote.sh/
#--------------------

# === plugins setup ===
# Ultra high performance install antidote
# Set the root name of the plugins files (.txt and .zsh) antidote will use.
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=(/path/to/antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

# Source or load antidote
source /Users/chianyung/.antidote/antidote.zsh
# Below if installing using homebrew
# source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh

