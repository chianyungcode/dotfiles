#!/bin/bash

pueue add -g "$PUEUE_GROUP" "tmux new-session -d -s \"$SESSION_NAME\" -n IDE -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5

# WINDOW 1
# Splitting tmux window / create pane
pueue add -g "$PUEUE_GROUP" "tmux splitw -t \"$SESSION_NAME\":1 -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5
pueue add -g "$PUEUE_GROUP" "tmux splitw -t \"$SESSION_NAME\":1 -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5

# Renaming pane in window 1
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.1 -T neovim"
pueue add -g "$PUEUE_GROUP" sleep 5
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.2 -T runner"
pueue add -g "$PUEUE_GROUP" sleep 5
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.3 -T installer"
pueue add -g "$PUEUE_GROUP" sleep 5

# Send keys to window 1 pane 1
pueue add -g "$PUEUE_GROUP" "tmux send-keys -t \"$SESSION_NAME\":1.1 nvim C-m"

# WINDOW 2
# Create new window 2
pueue add -g "$PUEUE_GROUP" "tmux new-window -t \"$SESSION_NAME\":2 -n \"󰊢  \" -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5

# Splitting tmux window / create pane
pueue add -g "$PUEUE_GROUP" "tmux splitw -t \"$SESSION_NAME\":2 -h -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5

# Renaming pane in window 2
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":2.1 -T git"
pueue add -g "$PUEUE_GROUP" sleep 5
pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":2.2 -T docker"
pueue add -g "$PUEUE_GROUP" sleep 5

# Send keys to window 2, pane 1 and 2
pueue add -g "$PUEUE_GROUP" "tmux send-keys -t \"$SESSION_NAME\":2.1 lazygit C-m"
pueue add -g "$PUEUE_GROUP" sleep 5
pueue add -g "$PUEUE_GROUP" "tmux send-keys -t \"$SESSION_NAME\":2.2 lazydocker C-m"
pueue add -g "$PUEUE_GROUP" sleep 5

# Change layout and pane size on window 1, put in last because we need run tmux as fast as possible due to bug can't make layout properly and resize properly if we doesn't entry to tmux or run tmux on our terminal
pueue add -g "$PUEUE_GROUP" "tmux selectl -t \"$SESSION_NAME\":1 main-vertical"
pueue add -g "$PUEUE_GROUP" sleep 2
pueue add -g "$PUEUE_GROUP" "tmux resizep -t \"$SESSION_NAME\":1.1 -R 140"
pueue add -g "$PUEUE_GROUP" sleep 2

pueue add -g "$PUEUE_GROUP" "tmux selectw -t \"$SESSION_NAME\":1"
pueue add -g "$PUEUE_GROUP" sleep 2

pueue add -g "$PUEUE_GROUP" "tmux selectp -t \"$SESSION_NAME\":1.1"
pueue add -g "$PUEUE_GROUP" "osascript -e 'display notification \"Success running all command with pueue cli\" with title \"backend-layout.sh\"'"
