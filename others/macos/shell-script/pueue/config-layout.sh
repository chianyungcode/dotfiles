#!/bin/bash

pueue add -g "$PUEUE_GROUP" "tmux new-session -d -s \"$SESSION_NAME\" -n editor -c $HOME/.dotfiles"
pueue add -g "$PUEUE_GROUP" sleep 5

pueue add -g "$PUEUE_GROUP" "tmux splitw -h -t \"$SESSION_NAME\":1 -c $HOME/.config"
pueue add -g "$PUEUE_GROUP" sleep 5

# Renaming pane in window 1
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.1 -T dotfiles"
pueue add -g "$PUEUE_GROUP" sleep 5
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.2 -T config"
pueue add -g "$PUEUE_GROUP" sleep 5

pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.1"
pueue add -g "$PUEUE_GROUP" "osascript -e 'display notification \"success running all commmand with pueue cli\" with title \"config-layout.sh\"'"
