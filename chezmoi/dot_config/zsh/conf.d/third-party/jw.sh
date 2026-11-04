# completions/_jw already provides completions (lazily via fpath), so drop the
# `eval "$(command jw shell completions zsh)"` line from the init script.
__jw_init_script() {
  command jw shell init zsh | command grep -vF 'jw shell completions zsh'
}
__cached_source jw __jw_init_script
unfunction __jw_init_script
