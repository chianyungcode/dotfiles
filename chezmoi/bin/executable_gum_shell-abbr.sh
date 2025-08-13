#!/bin/bash
set -e

abbreviations=$(gum input --placeholder "what is the abbreviations?")
command=$(gum input --placeholder "what is the command to abbr?")

dest_zsh="$HOME/.local/share/chezmoi/chezmoi/dot_config/zsh-abbr/user-abbreviations"
dest_fish="$HOME/.local/share/chezmoi/chezmoi/dot_config/fish/conf.d/10_10-abbr.fish"

echo "alias \"${abbreviations}\"=\"${command}\"" >>${dest_zsh}
echo "abbr ${abbreviations} '${command}'" >>${dest_fish}

printf "Generated abbreviations:\n"
printf "  Zsh  -> %s\n" "$dest_zsh"
printf "  Fish -> %s\n" "$dest_fish"
