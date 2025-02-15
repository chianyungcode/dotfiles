# ENVIRONMENT VARIABLE
if test -f ~/.config/fish/env.fish
    source ~/.config/fish/env.fish
end
if test -f ~/.config/fish/aliases.fish
    source ~/.config/fish/aliases.fish
end
if test -f ~/.config/fish/abbr-custom.fish
    source ~/.config/fish/abbr-custom.fish
end

# INITIATE
starship init fish | source
zoxide init fish | source
atuin init fish | source


# FUNCTION
# The shell not will automtically rename tmux pane
function fish_title
    if set -q TMUX
        echo -n (tmux display-message -p '#T') # Ambil title yang sudah ada
    else
        echo "Fish Shell"
    end
end

# -- sesh cli --
function sesh-sessions
    set -l session (sesh list -t | sed 's/^/󱂬 /' | fzf \
        --height 40% \
        --border-label ' sesh ' \
        --border \
        --prompt '⚡  ' \
        --preview 'tmux capture-pane -pe -t {2..}'
    )

    if test -z "$session"
        return
    end

    sesh connect (string replace "󱂬 " "" -- "$session")
end

bind \
    -M insert \eu sesh-sessions
bind \
    -M default \eu sesh-sessions
bind \
    -M visual \eu sesh-sessions


# -- pet cli --
function pet-select
    set -l buffer (pet search --query "$fish_buffer")
    if test -n "$buffer"
        commandline -r -- "$buffer"
    end
end
# Nonaktifkan flow control (mirip dengan `stty -ixon` di bash/zsh)
bind \\cx noop
# Hapus binding Ctrl+S bawaan jika ada
bind -e \cs
# Bind Ctrl+S ke fungsi pet-select
bind \cs pet-select
#############

set fish_greeting


# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/chianyung/.lmstudio/bin
