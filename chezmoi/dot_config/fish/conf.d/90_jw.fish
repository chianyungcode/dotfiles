# completions/jw.fish already provides completions (lazily), so drop the
# `jw shell completions fish | source` line from the init script.
function __jw_init_script
    jw shell init fish | string match -v -- 'command jw shell completions fish | source'
end
__cached_source jw __jw_init_script
functions -e __jw_init_script
