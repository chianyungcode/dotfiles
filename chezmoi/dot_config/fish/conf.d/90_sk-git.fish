function __sk_git_is_repository
    type -q git; or return 1
    type -q sk; or return 1
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
end

function __sk_git_preview_window
    set -l terminal_width (tput cols 2>/dev/null)

    if test -n "$terminal_width"; and test "$terminal_width" -lt 120
        echo "down:40%:wrap"
    else
        echo "right:50%"
    end
end

function __sk_git_picker_window
    printf '%s\n' \
        '--height=60%' \
        '--min-height=12' \
        '--border=rounded'
end

function __sk_git_insert
    for value in $argv
        test -n "$value"; or continue
        commandline -it -- (string escape -- "$value")
        commandline -it -- " "
    end

    commandline -f repaint
end

function sk_git_hashes
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git log --date=short --color=always \
            --format='%h%x09%C(green)%ad %C(auto)%h%d %s %C(blue)(%an)%C(reset)' \
            2>/dev/null |
            env -u NO_COLOR sk --ansi --delimiter='\t' --with-nth=2.. --multi --reverse \
                --no-sort --prompt='hashes> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function __sk_git_open_branch
    set -l branch $argv[1]
    test -n "$branch"; or return 1

    set -l remote (git config --get "branch.$branch.remote" 2>/dev/null)
    test -n "$remote"; or set remote origin

    set -l remote_url (git remote get-url "$remote" 2>/dev/null)
    test -n "$remote_url"; or return 1

    set remote_url (string replace -r '\.git$' '' -- "$remote_url")
    if string match -qr '^[^/:]+:[^/].*' -- "$remote_url"
        set -l remote_parts (string split -m 1 ':' -- "$remote_url")
        set -l ssh_host (string replace -r '^.*@' '' -- "$remote_parts[1]")
        set -l web_host $ssh_host

        if type -q ssh
            set -l configured_host (
                command ssh -G "$ssh_host" 2>/dev/null |
                    string match -r '^hostname\s+.*$' |
                    string replace -r '^hostname\s+' ''
            )
            test -n "$configured_host"; and set web_host $configured_host[1]
        end

        set remote_url "https://$web_host/$remote_parts[2]"
    else if not string match -qr '^https?://' -- "$remote_url"
        return 1
    end

    set -l branch_url "$remote_url/tree/$branch"
    switch (uname -s)
        case Darwin
            type -q open; or return 1
            command open "$branch_url"
        case '*'
            type -q xdg-open; or return 1
            command xdg-open "$branch_url"
    end
end

function sk_git_branches
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git for-each-ref --color=always --sort=-committerdate \
            --format='%(refname:short)%09%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))%09%(color:blue)%(subject)%(color:reset)' \
            refs/heads 2>/dev/null |
            env -u NO_COLOR sk --ansi --delimiter='\t' --with-nth=2.. --multi --reverse \
                (__sk_git_picker_window) \
                --header='CTRL-O open branch in remote' \
                --prompt='branches> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' {1} --" \
                --preview-window=(__sk_git_preview_window) \
                --bind="ctrl-o:execute-silent(fish -c '__sk_git_open_branch \"\$argv[1]\"' -- {1})" \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function sk_git_files
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git ls-files 2>/dev/null |
            env -u NO_COLOR sk --multi --reverse \
                --prompt='files> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' -- {}" \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    __sk_git_insert $selected
end

function sk_git_remotes
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git remote -v 2>/dev/null | sort | awk '{print $1 "\t" $2}' | uniq |
            env -u NO_COLOR sk --ansi --multi --reverse \
                --prompt='remotes> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' --remotes={1} --" \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function sk_git_worktrees
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git worktree list 2>/dev/null |
            env -u NO_COLOR sk --multi --reverse \
                --prompt='worktrees> ' \
                --preview='git -c color.status=always -C {1} status --short --branch; echo; git log --oneline --graph --date=short --color=always --pretty=format:"%C(auto)%cd %h%d %s" {2} --' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 ' ' -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function sk_git_help
    printf '%s\n' \
        'ctrl-g ?  show this help' \
        'ctrl-g h  show commit hashes' \
        'ctrl-g b  show local branches' \
        'ctrl-g t  show Git tags' \
        'ctrl-g f  show tracked files' \
        'ctrl-g r  show remotes' \
        'ctrl-g w  show worktrees' \
        'ctrl-g s  show stashes' \
        'ctrl-g l  show reflogs' |
        env -u NO_COLOR sk --ansi --no-multi --no-sort --reverse \
            (__sk_git_picker_window) \
            --prompt='help> '

    commandline -f repaint
end

function sk_git_stashes
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git stash list --format='%gd%x09%C(yellow)%gs%C(reset)' 2>/dev/null |
            env -u NO_COLOR sk --ansi --delimiter='\t' --with-nth=2.. --multi --reverse \
                --prompt='stashes> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function sk_git_reflogs
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git reflog --format='%gD%x09%C(yellow)%h%C(auto) %gs%C(reset)' 2>/dev/null |
            env -u NO_COLOR sk --ansi --delimiter='\t' --with-nth=2.. --multi --reverse \
                --prompt='reflogs> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function sk_git_tags
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git for-each-ref --color=always --sort=-creatordate \
            --format='%(refname:short)%09%(color:yellow)%(refname:short) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)' \
            refs/tags 2>/dev/null |
            env -u NO_COLOR sk --ansi --delimiter='\t' --with-nth=2.. --multi --reverse \
                --prompt='tags> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

if type -q git; and type -q sk
    bind \cgh sk_git_hashes
    bind \cgb sk_git_branches
    bind \cgf sk_git_files
    bind \cgr sk_git_remotes
    bind \cgw sk_git_worktrees
    bind \cgs sk_git_stashes
    bind \cgl sk_git_reflogs
    bind \cg\? sk_git_help
    bind \cgt sk_git_tags
    bind -M insert \cgh sk_git_hashes
    bind -M insert \cgb sk_git_branches
    bind -M insert \cgf sk_git_files
    bind -M insert \cgr sk_git_remotes
    bind -M insert \cgw sk_git_worktrees
    bind -M insert \cgs sk_git_stashes
    bind -M insert \cgl sk_git_reflogs
    bind -M insert \cg\? sk_git_help
    bind -M insert \cgt sk_git_tags
end
