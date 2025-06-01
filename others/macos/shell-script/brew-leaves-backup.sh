#!/bin/bash

output_dir="/Users/chianyung/.local/share/chezmoi/others/macos/manual-backup/cli/brew"
output_file="$output_dir/brew-leaves-list.txt"

# Pastikan direktori tujuan ada
mkdir -p "$output_dir"

# Jalankan brew leaves, tulis ke file
brew leaves >"$output_file"
