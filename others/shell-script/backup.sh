#!/bin/bash

set -e # Berhenti jika ada error

echo "Memulai backup untuk Brewfile dan list apps"

# Backup all apps to txt files
find /Applications -type d -name "*.app" -maxdepth 2 >$HOME/.local/share/chezmoi/project-specific/manual-backup/list-apps.txt
brew bundle dump --force --file=$HOME/.local/share/chezmoi/project-specific/manual-backup/cli/brew/Brewfile
