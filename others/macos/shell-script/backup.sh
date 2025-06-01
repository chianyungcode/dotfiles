#!/bin/bash

set -e # Berhenti jika ada error

echo "Memulai backup untuk Brewfile dan list apps"

apps_dir="$HOME/.local/share/chezmoi/project-specific/manual-backup"
apps_file="$apps_dir/list-apps.txt"

brewdump_dir="$apps_dir/cli/brew"
brewdump_file="$brewdump_dir/Brewfile"

# Pastikan direktori ada
mkdir -p "$apps_dir"
mkdir -p "$brewdump_dir"

# Backup list aplikasi .app di /Applications ke file list-apps.txt
find /Applications -type d -name "*.app" -maxdepth 2 >"$apps_file"

# Backup Brewfile dengan brew bundle dump
brew bundle dump --force --file="$brewdump_file"

echo "Backup selesai."
