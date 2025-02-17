function pet-select() {
  BUFFER=$(pet search --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select
if [ -t 0 ]; then
    stty -ixon
fi
bindkey -r '^s'
bindkey '^s' pet-select