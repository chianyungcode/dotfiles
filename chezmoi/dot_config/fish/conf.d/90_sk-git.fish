set -g __sk_git_script (status --current-filename)

function __sk_git_is_repository
    type -q git; or return 1
    type -q sk; or return 1
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
end

function __sk_git_preview_window
    echo "down:70%:wrap"
end

function __sk_git_picker_window
    printf '%s\n' \
        '--height=95%' \
        '--min-height=12' \
        '--border=rounded'
end

function __sk_git_browser_bind
    set -l kind $argv[1]
    set -l escaped_script (string escape -- "$__sk_git_script")
    set -l action "ctrl-o:execute-silent(fish -c 'source \"\$argv[1]\"; __sk_git_open \"\$argv[2]\" \"\$argv[3]\"' -- $escaped_script $kind {1})"
    printf '%s\n' "$action"
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
            env -u NO_COLOR sk --ansi --delimiter='\t' --hide-nth=1 --multi --reverse --no-sort \
                --header='CTRL-O open in browser | CTRL-D show diff | CTRL-S toggle sort | ALT-A all hashes | CTRL-/ toggle preview' \
                --prompt='hashes> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind=(__sk_git_browser_bind commit) \
                --bind='ctrl-d:execute(git diff --color=always {1} > /dev/tty)' \
                --bind='ctrl-s:toggle-sort' \
                --bind="alt-a:change-border-label(All hashes)+reload(git log --all --date=short --color=always --format='%h%x09%C(green)%ad %C(auto)%h%d %s %C(blue)(%an)%C(reset)')" \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function __sk_git_open
    set -l kind $argv[1]
    set -l value $argv[2]
    test -n "$kind"; and test -n "$value"; or return 1

    set -l current_branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    test -n "$current_branch"; or return 1
    if test "$current_branch" = HEAD
        set current_branch (git describe --exact-match --tags 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        test -n "$current_branch"; or return 1
    end

    set -l remote
    set -l web_path
    switch "$kind"
        case commit
            set web_path "/commit/$value"
        case branch
            set current_branch "$value"
            set remote (git config --get "branch.$current_branch.remote" 2>/dev/null)
            if test -z "$remote"
                set -l remote_candidate (string split -m 1 '/' -- "$current_branch")[1]
                if git remote get-url "$remote_candidate" >/dev/null 2>&1
                    set remote $remote_candidate
                    set current_branch (string split -m 1 '/' -- "$current_branch")[2]
                end
            end
            test -n "$remote"; or set remote origin
            set web_path "/tree/$current_branch"
        case remote
            set remote "$value"
            set web_path "/tree/$current_branch"
        case file
            set -l prefix (git rev-parse --show-prefix 2>/dev/null)
            test $status -eq 0; or return 1
            set web_path "/blob/$current_branch/$prefix$value"
        case tag
            set web_path "/releases/tag/$value"
        case ref
            switch "$value"
                case 'refs/heads/*'
                    set current_branch (string replace -r '^refs/heads/' '' -- "$value")
                    set remote (git config --get "branch.$current_branch.remote" 2>/dev/null)
                    test -n "$remote"; or set remote origin
                    set web_path "/tree/$current_branch"
                case 'refs/remotes/*'
                    set -l remote_branch (string replace -r '^refs/remotes/' '' -- "$value")
                    set -l remote_parts (string split -m 1 '/' -- "$remote_branch")
                    set remote $remote_parts[1]
                    set current_branch $remote_parts[2]
                    set web_path "/tree/$current_branch"
                case 'refs/tags/*'
                    set -l tag_name (string replace -r '^refs/tags/' '' -- "$value")
                    set web_path "/releases/tag/$tag_name"
                case '*'
                    return 1
            end
        case '*'
            return 1
    end

    if test -z "$remote"
        set remote (git config --get "branch.$current_branch.remote" 2>/dev/null)
        test -n "$remote"; or set remote origin
    end

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

    set -l url "$remote_url$web_path"
    switch (uname -s)
        case Darwin
            type -q open; or return 1
            command open "$url"
        case '*'
            type -q xdg-open; or return 1
            command xdg-open "$url"
    end
end

function __sk_git_open_branch
    __sk_git_open branch $argv[1]
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
            env -u NO_COLOR sk --ansi --delimiter='\t' --hide-nth=1 --multi --reverse \
                (__sk_git_picker_window) \
                --header='CTRL-O open in browser | ALT-A all branches | CTRL-/ toggle preview' \
                --prompt='branches> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' {1} --" \
                --preview-window=(__sk_git_preview_window) \
                --bind=(__sk_git_browser_bind branch) \
                --bind="alt-a:change-border-label(All branches)+reload(git for-each-ref --color=always --sort=-committerdate --format='%(refname:short)%09%(HEAD) %(color:yellow)%(refname:short) %(color:green)(%(committerdate:relative))%09%(color:blue)%(subject)%(color:reset)' refs/heads refs/remotes)" \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function sk_git_each_ref
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        git for-each-ref --color=always --sort=-creatordate --sort=-HEAD \
            --format='%(refname)%09%(color:yellow)%(refname) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)' 2>/dev/null |
            string match --invert --regex '^refs/remotes/' |
            env -u NO_COLOR sk --ansi --delimiter='\t' --hide-nth=1 --multi --reverse \
                --header='CTRL-O open in browser | ALT-E view in editor | ALT-A all refs | CTRL-/ toggle preview' \
                --prompt='refs> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' {1} --" \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind=(__sk_git_browser_bind ref) \
                --bind='alt-e:execute(${EDITOR:-vim} <(git show {1}) > /dev/tty)' \
                --bind="alt-a:change-border-label(All refs)+reload(git for-each-ref --color=always --sort=-creatordate --sort=-HEAD --format='%(refname)%09%(color:yellow)%(refname) %(color:green)(%(creatordate:relative))%09%(color:blue)%(subject)%(color:reset)')" \
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
                --header='CTRL-O open in browser | ALT-E edit file | CTRL-/ toggle preview' \
                --prompt='files> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' -- {}" \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind=(__sk_git_browser_bind file) \
                --bind='alt-e:execute(${EDITOR:-vim} -- {1} > /dev/tty)' \
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
                --header='CTRL-O open in browser | CTRL-/ toggle preview' \
                --prompt='remotes> ' \
                --preview="git log --oneline --graph --date=short --color=always --pretty=format:'%C(auto)%cd %h%d %s' --remotes={1} --" \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind=(__sk_git_browser_bind remote) \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
        set -a values "$fields[1]"
    end

    __sk_git_insert $values
end

function __sk_git_worktree_rows
    git worktree list --porcelain 2>/dev/null |
        awk '
            /^worktree / { path = substr($0, 10) }
            /^HEAD / { head = $2 }
            /^branch / { branch = $2 }
            /^$/ {
                if (path != "") print path "\t" path "\t" head "\t" branch
                path = head = branch = ""
            }
            END {
                if (path != "") print path "\t" path "\t" head "\t" branch
            }
        '
end

function sk_git_worktrees
    if not __sk_git_is_repository
        commandline -f repaint
        return
    end

    set -l selected (
        __sk_git_worktree_rows |
            env -u NO_COLOR sk --delimiter='\t' --hide-nth=1 --multi --reverse \
                --header='CTRL-X remove worktree | CTRL-/ toggle preview' \
                --prompt='worktrees> ' \
                --preview='git -c color.status=always -C {1} status --short --branch; echo; git log --oneline --graph --date=short --color=always --pretty=format:"%C(auto)%cd %h%d %s" {3} --' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind="ctrl-x:reload(fish -c 'git worktree remove \"\$argv[1]\" > /dev/null; source \"\$argv[2]\"; __sk_git_worktree_rows' -- {1} (string escape -- \"$__sk_git_script\"))" \
                --bind='ctrl-/:toggle-preview'
    )

    set -l values
    for item in $selected
        set -l fields (string split -m 1 \t -- "$item")
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
        'ctrl-g l  show reflogs' \
        'ctrl-g e  show all refs' |
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
            env -u NO_COLOR sk --ansi --delimiter='\t' --hide-nth=1 --multi --reverse \
                --header='CTRL-X drop stash | CTRL-/ toggle preview' \
                --prompt='stashes> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind="ctrl-x:reload(git stash drop -q {1}; git stash list --format='%gd%x09%C(yellow)%gs%C(reset)')" \
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
            env -u NO_COLOR sk --ansi --delimiter='\t' --hide-nth=1 --multi --reverse \
                --header='CTRL-/ toggle preview' \
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
            env -u NO_COLOR sk --ansi --delimiter='\t' --hide-nth=1 --multi --reverse \
                --header='CTRL-O open in browser | CTRL-/ toggle preview' \
                --prompt='tags> ' \
                --preview='DFT_COLOR=always git show --ext-diff --color=always {1}' \
                --preview-window=(__sk_git_preview_window) \
                (__sk_git_picker_window) \
                --bind=(__sk_git_browser_bind tag) \
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
    bind \cge sk_git_each_ref
    bind \cg\? sk_git_help
    bind \cgt sk_git_tags
    bind -M insert \cgh sk_git_hashes
    bind -M insert \cgb sk_git_branches
    bind -M insert \cgf sk_git_files
    bind -M insert \cgr sk_git_remotes
    bind -M insert \cgw sk_git_worktrees
    bind -M insert \cgs sk_git_stashes
    bind -M insert \cgl sk_git_reflogs
    bind -M insert \cge sk_git_each_ref
    bind -M insert \cg\? sk_git_help
    bind -M insert \cgt sk_git_tags
end
