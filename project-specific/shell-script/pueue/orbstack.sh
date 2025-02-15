#!/bin/bash

pueue add -g "$PUEUE_GROUP" "tmux new-session -d -s \"$SESSION_NAME\" -n nixos-distro -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 8

pueue add -g "$PUEUE_GROUP" "tmux send-keys -t \"$SESSION_NAME\":1.1 \"orb --machine \\\"$ORBSTACK_MACHINE_NAME\\\"\" C-m"
