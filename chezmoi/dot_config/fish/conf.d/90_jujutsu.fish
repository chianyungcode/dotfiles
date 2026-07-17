# COMPLETE=fish jj | source

# Jujutsu aliases run in a child process, so they cannot change the parent
# shell's directory themselves. Apply the paths printed by wq/wcd/wacd here.
function jj --description 'Jujutsu wrapper with workspace navigation'
    set -l subcommand ''
    if test (count $argv) -gt 0
        set subcommand $argv[1]
    end

    switch "$subcommand"
        case wq wcd wacd
            set -l destination (command jj $argv)
            or return

            if not test -d "$destination"
                echo "jj: workspace directory does not exist: $destination" >&2
                return 1
            end

            builtin cd -- "$destination"
        case '*'
            command jj $argv
    end
end
