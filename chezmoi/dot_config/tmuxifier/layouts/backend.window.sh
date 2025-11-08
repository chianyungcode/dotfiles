# WINDOW 1
window_root "$HOME/Code/Personal/Projects/Backend/allweezy-backend/"
new_window "nvim"
run_cmd "nvim"

split_h 1
run_cmd "sleep 1"
run_cmd "cd $HOME/Documents/vault-obsidian/"
run_cmd "nvim"

select_pane 1

# WINDOW 2
new_window "codex"
run_cmd "codex"

# WINDOW 3
new_window "opencode"
run_cmd "opencode"

# WINDOW 4
new_window "terminal"
run_cmd "task dev"

# go back to window 1
select_window "1"
