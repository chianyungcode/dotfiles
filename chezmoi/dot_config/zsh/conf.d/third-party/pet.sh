#!/usr/bin/env bash

if (( $+commands[pet] && $+commands[sk] )); then
  function pet-select() {
    BUFFER=$(pet search --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N pet-select

  # Bind di emacs mode
  bindkey '^f' pet-select
  # Bind di vi insert mode
  bindkey -M viins '^f' pet-select
  # Bind di vi command mode
  bindkey -M vicmd '^f' pet-select
fi

if [ -t 0 ]; then
  stty -ixon
fi

if (( $+commands[pet] )); then
  alias pexec="pet exec -t"
  alias psc="pet search"
fi
