function sesh-sessions
    # Pilih session
    set session (sesh list -t | sed 's/^/󱂬 /' | fzf \
        --height 40% \
        --border-label ' sesh ' \
        --border \
        --prompt '⚡  ' \
        --preview 'tmux capture-pane -pe -t {2..}')

    # Jika tidak ada session, keluar
    test -z "$session"; and return

    # Connect ke session yang dipilih
    sesh connect (string replace -r '^󱂬 ' '' "$session")
end

# Untuk default mode (emacs mode)
bind \eu sesh-sessions

# Untuk vi mode jika diaktifkan
bind -M insert \eu sesh-sessions
bind -M default \eu sesh-sessions
