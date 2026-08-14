if type -q sk; and type -q fd
    function skim_ctrl_t
        set -l query (commandline --current-token)
        set -l preview_window "right:50%"
        set -l terminal_width (tput cols 2>/dev/null)

        if test -n "$terminal_width"; and test "$terminal_width" -lt 120
            set preview_window "down:40%:wrap"
        end

        set -l selected (
            fd --hidden --exclude .git --type f --type d --type symlink |
            sk --border=rounded --height=80% --regex --preview='if [ -d {} ]; then CLICOLOR_FORCE=1 lla -a {}; else bat -n --color=always {}; fi' --preview-window="$preview_window" --bind='ctrl-/:toggle-preview' -m --reverse --query "$query"
        )

        if test (count $selected) -gt 0
            commandline -t ""

            for item in $selected
                commandline -it -- (string escape -- "$item")
                commandline -it -- " "
            end
        end

        commandline -f repaint
    end

    bind \ct skim_ctrl_t
    bind -M insert \ct skim_ctrl_t
end
