window_root "$HOME/Code/Personal/Projects/Frontend/allweezy/"
new_window "nvim"
run_cmd "nvim"

split_h 20
run_cmd "jjui"
select_pane 1

new_window "codex"
run_cmd "codex"

new_window "opencode"
run_cmd "opencode"

select_window "1"
