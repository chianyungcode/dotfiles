if type -q sk; and type -q fd
    function skim_ctrl_t
        set -l query (commandline --current-token)

        set -l selected (
            fd --hidden --exclude .git --type f --type d |
            sk --preview="bat {} --color=always" -m --reverse --query "$query"
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
