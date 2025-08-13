#!/bin/bash

base_cmd=$(gum input --placeholder "what is the cli command to generate completion?")
filename=$(gum input --placeholder "what is the cli name?")

dest_zsh="$HOME/.local/share/chezmoi/chezmoi/dot_config/zsh-source/completions/_$filename"
dest_fish="$HOME/.local/share/chezmoi/chezmoi/dot_config/fish/completions/$filename.fish"

eval "$base_cmd zsh" >"$dest_zsh"
eval "$base_cmd fish" >"$dest_fish"

printf "Generated:\n"
printf "  Zsh  -> %s\n" "$dest_zsh"
printf "  Fish -> %s\n" "$dest_fish"
