window_root "$HOME/.local/share/chezmoi"
new_window "chezmoi"
run_cmd "nvim"

split_h 20
run_cmd "cd $HOME/Documents/vault-obsidian/"
run_cmd "nvim"
select_pane 1

new_window ".config"
run_cmd "cd $HOME/.config"
run_cmd "nvim"

split_h 20
run_cmd "cd $HOME/Documents/obsidian-vaults/"
run_cmd "sleep 1"
run_cmd "nvim"

select_window "1"
