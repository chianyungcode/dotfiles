if type -q sk; and type -q fd
    function skim_ctrl_t
        set -l query (commandline --current-token)
        set -l preview_window "right:50%"
        set -l terminal_width (tput cols 2>/dev/null)

        if test -n "$terminal_width"; and test "$terminal_width" -lt 120
            set preview_window "down:40%:wrap"
        end

        set -l selected
        while true
            set selected (
                fd --hidden --exclude .git --type f --type d --type symlink |
                sk --border=rounded --height=80% --regex --preview='if [ -d {} ]; then CLICOLOR_FORCE=1 lla -a {}; else bat -n --color=always {}; fi' --preview-window="$preview_window" --header='CTRL-E edit marked files | CTRL-D cd directory | CTRL-/ toggle preview' --bind='ctrl-e:accept(ctrl-e)' --bind='ctrl-d:accept(ctrl-d)' --bind='ctrl-q:abort' --bind='ctrl-/:toggle-preview' -m --reverse --query "$query"
            )

            if test (count $selected) -eq 0
                break
            end

            if test "$selected[1]" = ctrl-e
                set -l files
                for item in $selected[2..-1]
                    if test -f "$item"
                        set -a files "$item"
                    end
                end

                if test (count $files) -gt 0
                    set -l editor "$EDITOR"
                    if test -z "$editor"
                        set editor vim
                    end
                    set -lx EDITOR "$editor"
                    sh -c '${EDITOR:-vim} -- "$@"' sh $files
                end

                set selected
                break
            end

            if test "$selected[1]" = ctrl-d
                if test (count $selected) -gt 1; and test -d "$selected[2]"
                    cd -- "$selected[2]"; or continue
                    set query ""
                end
                continue
            end

            break
        end

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
