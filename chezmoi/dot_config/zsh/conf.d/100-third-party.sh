conf_dir="${ZDOTDIR:-$HOME/.config/zsh}/conf.d/third-party"

# Pastikan direktori ada
[ -d "$conf_dir" ] || return 0

# Aktifkan nullglob agar pattern tanpa match menjadi kosong
setopt null_glob

for file in "$conf_dir"/*.zsh "$conf_dir"/*.sh; do
  [ -r "$file" ] && source "$file"
done

unsetopt null_glob
