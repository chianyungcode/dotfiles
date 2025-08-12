#!/bin/bash
set -e

# Array path yang akan ditampilkan
directories=(
  "$HOME/.local/share/chezmoi"
  "$HOME/Downloads"
  "$HOME/Code/Personal/Projects/Backend/allweezy-backend/"
  "$HOME/Code/Personal/Projects/Backend/allweezy"
)

# Loop array jadi input untuk gum filter
PROJECT_DIR=$(for dir in "${directories[@]}"; do
  echo "$dir"
done | gum filter --placeholder "What is the path to directory")
clear

PUEUE_GROUP="tmux"
clear

SESSION_NAME=$(gum input --placeholder "What is the tmux session name?")
clear

# Exit jika salah satu variable kosong
if [[ -z "$PROJECT_DIR" || -z "$PUEUE_GROUP" || -z "$SESSION_NAME" ]]; then
  echo "❌ Error: All inputs (PROJECT_DIR, PUEUE_GROUP, SESSION_NAME) must be provided."
  exit 1
fi

pueue add -g "$PUEUE_GROUP" "tmux new-session -d -s \"$SESSION_NAME\" -n IDE -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5

# WINDOW 1
pueue add -g "$PUEUE_GROUP" "tmux send-keys -t \"$SESSION_NAME\":1.1 nvim C-m"
pueue add -g "$PUEUE_GROUP" sleep 3

# WINDOW 2
pueue add -g "$PUEUE_GROUP" "tmux new-window -t \"$SESSION_NAME\":2 -n \"󰊢 \" -c \"$PROJECT_DIR\""
pueue add -g "$PUEUE_GROUP" sleep 5

pueue add -g "$PUEUE_GROUP" "tmux send-keys -t \"$SESSION_NAME\":2.1 lazygit C-m"
pueue add -g "$PUEUE_GROUP" sleep 5

pueue add -g "$PUEUE_GROUP" "tmux selectw -t \"$SESSION_NAME\":1"
pueue add -g "$PUEUE_GROUP" sleep 2

pueue add -g "$PUEUE_GROUP" "osascript -e 'display notification \"Success running all command with pueue cli\" with title \"backend-layout.sh\"'"
