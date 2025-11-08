# tmuxifier.fish - Fish shell completions for tmuxifier
# Place this file in: ~/.config/fish/completions/tmuxifier.fish

# -----------------------------------------------------------------------------
# Subcommand aliases (long + short forms)
# -----------------------------------------------------------------------------
set -l cmd_load_session 'load-session s'
set -l cmd_load_window 'load-window w'
set -l cmd_list 'list l'
set -l cmd_list_sessions 'list-sessions ls'
set -l cmd_list_windows 'list-windows lw'
set -l cmd_new_session 'new-session ns'
set -l cmd_new_window 'new-window nw'
set -l cmd_edit_session 'edit-session es'
set -l cmd_edit_window 'edit-window ew'
set -l cmd_commands commands
set -l cmd_version version
set -l cmd_help help

# -----------------------------------------------------------------------------
# Helper functions: executed lazily only when completion is triggered
# -----------------------------------------------------------------------------

function __tmuxifier_list_sessions --description 'List tmuxifier session layouts for completion'
    command tmuxifier list-sessions 2>/dev/null
end

function __tmuxifier_list_windows --description 'List tmuxifier window layouts for completion'
    command tmuxifier list-windows 2>/dev/null
end

# -----------------------------------------------------------------------------
# Top-level: enable completion for `tmuxifier`
# -----------------------------------------------------------------------------
# -x : exclusive, restricts completion to defined subcommands
complete -c tmuxifier -x

# -----------------------------------------------------------------------------
# Subcommand list (no external command execution at startup)
# -----------------------------------------------------------------------------
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_load_session -d 'Load the specified session layout.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_load_window -d 'Load the specified window layout into current session.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_list -d 'List all session and window layouts.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_list_sessions -d 'List session layouts.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_list_windows -d 'List window layouts.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_new_session -d 'Create a new session layout and open it with $EDITOR.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_new_window -d 'Create a new window layout and open it with $EDITOR.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_edit_session -d 'Edit a specified session layout with $EDITOR.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_edit_window -d 'Edit a specified window layout with $EDITOR.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_commands -d 'List all tmuxifier commands.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_version -d 'Print the Tmuxifier version.'
complete -c tmuxifier -n __fish_use_subcommand -a $cmd_help -d 'Show this message.'

# -----------------------------------------------------------------------------
# Argument completion for specific subcommands
# These functions execute tmuxifier only when TAB completion is triggered.
# -----------------------------------------------------------------------------

# load-session / s: session template name
complete -c tmuxifier -x \
    -n "__fish_seen_subcommand_from $cmd_load_session" \
    -a '(__tmuxifier_list_sessions)' \
    -d session-template

# edit-session / es: session template name
complete -c tmuxifier -x \
    -n "__fish_seen_subcommand_from $cmd_edit_session" \
    -a '(__tmuxifier_list_sessions)' \
    -d session-template

# load-window / w: window template name
complete -c tmuxifier -x \
    -n "__fish_seen_subcommand_from $cmd_load_window" \
    -a '(__tmuxifier_list_windows)' \
    -d window-template

# edit-window / ew: window template name
complete -c tmuxifier -x \
    -n "__fish_seen_subcommand_from $cmd_edit_window" \
    -a '(__tmuxifier_list_windows)' \
    -d window-template
