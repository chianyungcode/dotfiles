#!/usr/bin/env bash

function pet-select() {
  BUFFER=$(pet search --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select

if [ -t 0 ]; then
  stty -ixon
fi

# Bind di emacs mode
bindkey '^f' pet-select
# Bind di vi insert mode
bindkey -M viins '^f' pet-select
# Bind di vi command mode
bindkey -M vicmd '^f' pet-select

alias pexec="pet exec -t"
alias psc="pet search"
