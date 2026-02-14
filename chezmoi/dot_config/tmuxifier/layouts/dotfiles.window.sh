window_root "$HOME/.local/share/chezmoi"
new_window "chezmoi"
run_cmd "nvim"

new_window ".config"
run_cmd "cd $HOME/.config"
run_cmd "nvim"

select_window "1"
