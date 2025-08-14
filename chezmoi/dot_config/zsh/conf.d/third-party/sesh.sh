function sesh-sessions() {
	{
		exec </dev/tty
		exec <&1
		local session
		session=$(
			sesh list -t | sed 's/^/󱂬 /' | fzf \
				--height 40% \
				--border-label ' sesh ' \
				--border \
				--prompt '⚡  ' \
				--preview 'tmux capture-pane -pe -t {2..}'
		)
		zle reset-prompt >/dev/null 2>&1 || true
		[[ -z "$session" ]] && return
		sesh connect $(echo "$session" | sed 's/^󱂬 //')
	}
}

zle -N sesh-sessions
bindkey -M emacs '\eu' sesh-sessions
bindkey -M vicmd '\eu' sesh-sessions
bindkey -M viins '\eu' sesh-sessions
