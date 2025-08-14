#compdef pueue

autoload -U is-at-least

_pueue() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" : \
'--color=[Colorize the output; auto enables color output when connected to a tty]:COLOR:(auto never always)' \
'-c+[If provided, Pueue only uses this config file]:CONFIG:_files' \
'--config=[If provided, Pueue only uses this config file]:CONFIG:_files' \
'-p+[The name of the profile that should be loaded from your config file]:PROFILE:_default' \
'--profile=[The name of the profile that should be loaded from your config file]:PROFILE:_default' \
'*-v[Verbose mode (-v, -vv, -vvv)]' \
'*--verbose[Verbose mode (-v, -vv, -vvv)]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_pueue_commands" \
"*::: :->pueue" \
&& ret=0
    case $state in
    (pueue)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'-w+[Specify current working directory]:working-directory:_files -/' \
'--working-directory=[Specify current working directory]:working-directory:_files -/' \
'(-i --immediate)-d+[Prevents the task from being enqueued until '\''delay'\'' elapses. See "enqueue" for accepted formats]:delay:_default' \
'(-i --immediate)--delay=[Prevents the task from being enqueued until '\''delay'\'' elapses. See "enqueue" for accepted formats]:delay:_default' \
'-g+[Assign the task to a group]:GROUP:_default' \
'--group=[Assign the task to a group]:GROUP:_default' \
'*-a+[Start the task once all specified tasks have successfully finished]:after:_default' \
'*--after=[Start the task once all specified tasks have successfully finished]:after:_default' \
'-o+[Start this task with a higher priority]:PRIORITY:_default' \
'--priority=[Start this task with a higher priority]:PRIORITY:_default' \
'-l+[Add some information for yourself]:LABEL:_default' \
'--label=[Add some information for yourself]:LABEL:_default' \
'-e[Escape any special shell characters (" ", "&", "!", etc.). Beware\: This implicitly disables nearly all shell specific syntax ("&&", "&>").]' \
'--escape[Escape any special shell characters (" ", "&", "!", etc.). Beware\: This implicitly disables nearly all shell specific syntax ("&&", "&>").]' \
'(-s --stashed)-i[Immediately start the task]' \
'(-s --stashed)--immediate[Immediately start the task]' \
'(-p --print-task-id)--follow[Immediately follow a task, if it'\''s started with --immediate]' \
'(-i --immediate)-s[Create the task in Stashed state]' \
'(-i --immediate)--stashed[Create the task in Stashed state]' \
'-p[Only return the task id instead of a text]' \
'--print-task-id[Only return the task id instead of a text]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::command -- The command to be added:_cmdambivalent' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'*::task_ids -- The task ids to be removed:_default' \
&& ret=0
;;
(switch)
_arguments "${_arguments_options[@]}" : \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':task_id_1 -- The first task id:_default' \
':task_id_2 -- The second task id:_default' \
&& ret=0
;;
(stash)
_arguments "${_arguments_options[@]}" : \
'(-a --all)-g+[Stash all queued tasks in a group]:GROUP:_default' \
'(-a --all)--group=[Stash all queued tasks in a group]:GROUP:_default' \
'-d+[Delay enqueuing these tasks until '\''delay'\'' elapses. See DELAY FORMAT below]:delay:_default' \
'--delay=[Delay enqueuing these tasks until '\''delay'\'' elapses. See DELAY FORMAT below]:delay:_default' \
'-a[Stash all queued tasks across all groups]' \
'--all[Stash all queued tasks across all groups]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- Stash these specific tasks:_default' \
&& ret=0
;;
(enqueue)
_arguments "${_arguments_options[@]}" : \
'(-a --all)-g+[Enqueue all stashed tasks in a group]:GROUP:_default' \
'(-a --all)--group=[Enqueue all stashed tasks in a group]:GROUP:_default' \
'-d+[Delay enqueuing these tasks until '\''delay'\'' elapses. See DELAY FORMAT below]:delay:_default' \
'--delay=[Delay enqueuing these tasks until '\''delay'\'' elapses. See DELAY FORMAT below]:delay:_default' \
'-a[Enqueue all stashed tasks across all groups]' \
'--all[Enqueue all stashed tasks across all groups]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- Enqueue these specific tasks:_default' \
&& ret=0
;;
(start)
_arguments "${_arguments_options[@]}" : \
'(-a --all)-g+[Resume a specific group and all paused tasks in it]:GROUP:_default' \
'(-a --all)--group=[Resume a specific group and all paused tasks in it]:GROUP:_default' \
'-a[Resume all groups!]' \
'--all[Resume all groups!]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- Start these specific tasks. Paused tasks will resumed. Queued/Stashed tasks will be force-started:_default' \
&& ret=0
;;
(restart)
_arguments "${_arguments_options[@]}" : \
'(-a --all-failed)-g+[Like \`--all-failed\`, but only restart tasks failed tasks of a specific group]:FAILED_IN_GROUP:_default' \
'(-a --all-failed)--failed-in-group=[Like \`--all-failed\`, but only restart tasks failed tasks of a specific group]:FAILED_IN_GROUP:_default' \
'-a[Restart all failed tasks across all groups]' \
'--all-failed[Restart all failed tasks across all groups]' \
'(-s --stashed)-k[Immediately start the tasks, no matter how many open slots there are. This will ignore any dependencies tasks may have]' \
'(-s --stashed)--immediate[Immediately start the tasks, no matter how many open slots there are. This will ignore any dependencies tasks may have]' \
'-s[Set the restarted task to a "Stashed" state. Useful to avoid immediate execution]' \
'--stashed[Set the restarted task to a "Stashed" state. Useful to avoid immediate execution]' \
'-i[Restart the task by reusing the already existing tasks. This will overwrite any previous logs of the restarted tasks]' \
'--in-place[Restart the task by reusing the already existing tasks. This will overwrite any previous logs of the restarted tasks]' \
'--not-in-place[Restart the task by creating a new identical tasks. Only necessary if you have the \`restart_in_place\` configuration set to true]' \
'-e[Edit the task before restarting]' \
'--edit[Edit the task before restarting]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- Restart these specific tasks:_default' \
&& ret=0
;;
(pause)
_arguments "${_arguments_options[@]}" : \
'(-a --all)-g+[Pause a specific group]:GROUP:_default' \
'(-a --all)--group=[Pause a specific group]:GROUP:_default' \
'-a[Pause all groups!]' \
'--all[Pause all groups!]' \
'-w[Pause the specified groups, but let already running tasks finish by themselves]' \
'--wait[Pause the specified groups, but let already running tasks finish by themselves]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- Pause these specific tasks:_default' \
&& ret=0
;;
(kill)
_arguments "${_arguments_options[@]}" : \
'(-a --all)-g+[Kill all running tasks in a group. This also pauses the group]:GROUP:_default' \
'(-a --all)--group=[Kill all running tasks in a group. This also pauses the group]:GROUP:_default' \
'-s+[Send a UNIX signal instead of simply killing the process]:SIGNAL:_default' \
'--signal=[Send a UNIX signal instead of simply killing the process]:SIGNAL:_default' \
'-a[Kill all running tasks across ALL groups. This also pauses all groups]' \
'--all[Kill all running tasks across ALL groups. This also pauses all groups]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- Kill these specific tasks:_default' \
&& ret=0
;;
(send)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':task_id -- The id of the task:_default' \
':input -- The input that should be sent to the process:_default' \
&& ret=0
;;
(edit)
_arguments "${_arguments_options[@]}" : \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- The ids of all tasks that should be edited:_default' \
&& ret=0
;;
(env)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_pueue__env_commands" \
"*::: :->env" \
&& ret=0

    case $state in
    (env)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-env-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':task_id -- The id of the task for which the variable should be set:_default' \
':key -- The name of the environment variable to set:_default' \
':value -- The value of the environment variable to set:_default' \
&& ret=0
;;
(unset)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':task_id -- The id of the task for which the variable should be set:_default' \
':key -- The name of the environment variable to set:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_pueue__env__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-env-help-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(unset)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(group)
_arguments "${_arguments_options[@]}" : \
'-j[Print the list of groups as json]' \
'--json[Print the list of groups as json]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_pueue__group_commands" \
"*::: :->group" \
&& ret=0

    case $state in
    (group)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-group-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'-p+[Set the amount of parallel tasks this group can have]:PARALLEL:_default' \
'--parallel=[Set the amount of parallel tasks this group can have]:PARALLEL:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':name:_default' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':name:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_pueue__group__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-group-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(status)
_arguments "${_arguments_options[@]}" : \
'-g+[Only show tasks of a specific group]:GROUP:_default' \
'--group=[Only show tasks of a specific group]:GROUP:_default' \
'-j[Print the current state as json to stdout. This does not include the output of tasks. Use \`log -j\` if you want everything]' \
'--json[Print the current state as json to stdout. This does not include the output of tasks. Use \`log -j\` if you want everything]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::query -- Users can specify a custom query to filter for specific values, order by a column or limit the amount of tasks listed. Use `--help` for the full syntax definition:_default' \
&& ret=0
;;
(log)
_arguments "${_arguments_options[@]}" : \
'-g+[View the outputs of this specific group'\''s tasks]:GROUP:_default' \
'--group=[View the outputs of this specific group'\''s tasks]:GROUP:_default' \
'(-f --full)-l+[Only print the last X lines of each task'\''s output]:LINES:_default' \
'(-f --full)--lines=[Only print the last X lines of each task'\''s output]:LINES:_default' \
'-a[Show the logs of all groups'\'' tasks]' \
'--all[Show the logs of all groups'\'' tasks]' \
'-j[Print the resulting tasks and output as json]' \
'--json[Print the resulting tasks and output as json]' \
'-f[Show the whole output]' \
'--full[Show the whole output]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- View the task output of these specific tasks:_default' \
&& ret=0
;;
(follow)
_arguments "${_arguments_options[@]}" : \
'-l+[Only print the last X lines of the output before following]:LINES:_default' \
'--lines=[Only print the last X lines of the output before following]:LINES:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'::task_id -- The id of the task you want to watch:_default' \
&& ret=0
;;
(wait)
_arguments "${_arguments_options[@]}" : \
'(-a --all)-g+[Wait for all tasks in a specific group]:GROUP:_default' \
'(-a --all)--group=[Wait for all tasks in a specific group]:GROUP:_default' \
'-s+[Wait for tasks to reach a specific task status]:STATUS:_default' \
'--status=[Wait for tasks to reach a specific task status]:STATUS:_default' \
'-a[Wait for all tasks across all groups and the default group]' \
'--all[Wait for all tasks across all groups and the default group]' \
'-q[Don'\''t show any log output while waiting]' \
'--quiet[Don'\''t show any log output while waiting]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::task_ids -- This allows you to wait for specific tasks to finish:_default' \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
'-g+[Only clean tasks of a specific group]:GROUP:_default' \
'--group=[Only clean tasks of a specific group]:GROUP:_default' \
'-s[Only clean tasks that finished successfully]' \
'--successful-only[Only clean tasks that finished successfully]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" : \
'*-g+[If groups are specified, only those specific groups will be reset]:GROUPS:_default' \
'*--groups=[If groups are specified, only those specific groups will be reset]:GROUPS:_default' \
'-f[Don'\''t ask for any confirmation]' \
'--force[Don'\''t ask for any confirmation]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(shutdown)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(parallel)
_arguments "${_arguments_options[@]}" : \
'-g+[Set the amount for a specific group]:group:_default' \
'--group=[Set the amount for a specific group]:group:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'::parallel_tasks -- The amount of allowed parallel tasks:_default' \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" : \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':shell -- The target shell:(bash elvish fish power-shell zsh nushell)' \
'::output_directory -- The output directory to which the file should be written:_files -/' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_pueue__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(switch)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(stash)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(enqueue)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(start)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(restart)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pause)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(kill)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(send)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(edit)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(env)
_arguments "${_arguments_options[@]}" : \
":: :_pueue__help__env_commands" \
"*::: :->env" \
&& ret=0

    case $state in
    (env)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-help-env-command-$line[1]:"
        case $line[1] in
            (set)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(unset)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(group)
_arguments "${_arguments_options[@]}" : \
":: :_pueue__help__group_commands" \
"*::: :->group" \
&& ret=0

    case $state in
    (group)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:pueue-help-group-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(status)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(log)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(follow)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(wait)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(reset)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(shutdown)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(parallel)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_pueue_commands] )) ||
_pueue_commands() {
    local commands; commands=(
'add:Enqueue a task for execution' \
'remove:Remove tasks from the list. Running or paused tasks need to be killed first' \
'switch:Switches the queue position of two commands' \
'stash:Stash a task. Stashed tasks won'\''t be automatically started' \
'enqueue:Enqueue stashed tasks. They'\''ll be handled normally afterwards' \
'start:Resume operation of specific tasks or groups of tasks' \
'restart:Restart failed or successful task(s)' \
'pause:Either pause running tasks or specific groups of tasks' \
'kill:Kill specific running tasks or whole task groups' \
'send:Send something to a task. Useful for sending confirmations such as '\''y\\n'\''' \
'edit:Adjust editable properties of a task' \
'env:Use this to add or remove environment variables from tasks' \
'group:Use this to add or remove groups' \
'status:Display the current status of all tasks' \
'log:Display the log output of finished tasks' \
'follow:Follow the output of a currently running task. This command works like "tail -f"' \
'wait:Wait until tasks are finished' \
'clean:Remove all finished tasks from the list' \
'reset:Kill all tasks, clean up afterwards and reset EVERYTHING!' \
'shutdown:Remotely shut down the daemon. Should only be used if the daemon isn'\''t started by a service manager' \
'parallel:Set the amount of allowed parallel tasks' \
'completions:Generates shell completion files' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'pueue commands' commands "$@"
}
(( $+functions[_pueue__add_commands] )) ||
_pueue__add_commands() {
    local commands; commands=()
    _describe -t commands 'pueue add commands' commands "$@"
}
(( $+functions[_pueue__clean_commands] )) ||
_pueue__clean_commands() {
    local commands; commands=()
    _describe -t commands 'pueue clean commands' commands "$@"
}
(( $+functions[_pueue__completions_commands] )) ||
_pueue__completions_commands() {
    local commands; commands=()
    _describe -t commands 'pueue completions commands' commands "$@"
}
(( $+functions[_pueue__edit_commands] )) ||
_pueue__edit_commands() {
    local commands; commands=()
    _describe -t commands 'pueue edit commands' commands "$@"
}
(( $+functions[_pueue__enqueue_commands] )) ||
_pueue__enqueue_commands() {
    local commands; commands=()
    _describe -t commands 'pueue enqueue commands' commands "$@"
}
(( $+functions[_pueue__env_commands] )) ||
_pueue__env_commands() {
    local commands; commands=(
'set:Set a variable for a specific task'\''s environment' \
'unset:Remove a specific variable from a task'\''s environment' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'pueue env commands' commands "$@"
}
(( $+functions[_pueue__env__help_commands] )) ||
_pueue__env__help_commands() {
    local commands; commands=(
'set:Set a variable for a specific task'\''s environment' \
'unset:Remove a specific variable from a task'\''s environment' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'pueue env help commands' commands "$@"
}
(( $+functions[_pueue__env__help__help_commands] )) ||
_pueue__env__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'pueue env help help commands' commands "$@"
}
(( $+functions[_pueue__env__help__set_commands] )) ||
_pueue__env__help__set_commands() {
    local commands; commands=()
    _describe -t commands 'pueue env help set commands' commands "$@"
}
(( $+functions[_pueue__env__help__unset_commands] )) ||
_pueue__env__help__unset_commands() {
    local commands; commands=()
    _describe -t commands 'pueue env help unset commands' commands "$@"
}
(( $+functions[_pueue__env__set_commands] )) ||
_pueue__env__set_commands() {
    local commands; commands=()
    _describe -t commands 'pueue env set commands' commands "$@"
}
(( $+functions[_pueue__env__unset_commands] )) ||
_pueue__env__unset_commands() {
    local commands; commands=()
    _describe -t commands 'pueue env unset commands' commands "$@"
}
(( $+functions[_pueue__follow_commands] )) ||
_pueue__follow_commands() {
    local commands; commands=()
    _describe -t commands 'pueue follow commands' commands "$@"
}
(( $+functions[_pueue__group_commands] )) ||
_pueue__group_commands() {
    local commands; commands=(
'add:Add a group by name' \
'remove:Remove a group by name. This will move all tasks in this group to the default group!' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'pueue group commands' commands "$@"
}
(( $+functions[_pueue__group__add_commands] )) ||
_pueue__group__add_commands() {
    local commands; commands=()
    _describe -t commands 'pueue group add commands' commands "$@"
}
(( $+functions[_pueue__group__help_commands] )) ||
_pueue__group__help_commands() {
    local commands; commands=(
'add:Add a group by name' \
'remove:Remove a group by name. This will move all tasks in this group to the default group!' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'pueue group help commands' commands "$@"
}
(( $+functions[_pueue__group__help__add_commands] )) ||
_pueue__group__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'pueue group help add commands' commands "$@"
}
(( $+functions[_pueue__group__help__help_commands] )) ||
_pueue__group__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'pueue group help help commands' commands "$@"
}
(( $+functions[_pueue__group__help__remove_commands] )) ||
_pueue__group__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'pueue group help remove commands' commands "$@"
}
(( $+functions[_pueue__group__remove_commands] )) ||
_pueue__group__remove_commands() {
    local commands; commands=()
    _describe -t commands 'pueue group remove commands' commands "$@"
}
(( $+functions[_pueue__help_commands] )) ||
_pueue__help_commands() {
    local commands; commands=(
'add:Enqueue a task for execution' \
'remove:Remove tasks from the list. Running or paused tasks need to be killed first' \
'switch:Switches the queue position of two commands' \
'stash:Stash a task. Stashed tasks won'\''t be automatically started' \
'enqueue:Enqueue stashed tasks. They'\''ll be handled normally afterwards' \
'start:Resume operation of specific tasks or groups of tasks' \
'restart:Restart failed or successful task(s)' \
'pause:Either pause running tasks or specific groups of tasks' \
'kill:Kill specific running tasks or whole task groups' \
'send:Send something to a task. Useful for sending confirmations such as '\''y\\n'\''' \
'edit:Adjust editable properties of a task' \
'env:Use this to add or remove environment variables from tasks' \
'group:Use this to add or remove groups' \
'status:Display the current status of all tasks' \
'log:Display the log output of finished tasks' \
'follow:Follow the output of a currently running task. This command works like "tail -f"' \
'wait:Wait until tasks are finished' \
'clean:Remove all finished tasks from the list' \
'reset:Kill all tasks, clean up afterwards and reset EVERYTHING!' \
'shutdown:Remotely shut down the daemon. Should only be used if the daemon isn'\''t started by a service manager' \
'parallel:Set the amount of allowed parallel tasks' \
'completions:Generates shell completion files' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'pueue help commands' commands "$@"
}
(( $+functions[_pueue__help__add_commands] )) ||
_pueue__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help add commands' commands "$@"
}
(( $+functions[_pueue__help__clean_commands] )) ||
_pueue__help__clean_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help clean commands' commands "$@"
}
(( $+functions[_pueue__help__completions_commands] )) ||
_pueue__help__completions_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help completions commands' commands "$@"
}
(( $+functions[_pueue__help__edit_commands] )) ||
_pueue__help__edit_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help edit commands' commands "$@"
}
(( $+functions[_pueue__help__enqueue_commands] )) ||
_pueue__help__enqueue_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help enqueue commands' commands "$@"
}
(( $+functions[_pueue__help__env_commands] )) ||
_pueue__help__env_commands() {
    local commands; commands=(
'set:Set a variable for a specific task'\''s environment' \
'unset:Remove a specific variable from a task'\''s environment' \
    )
    _describe -t commands 'pueue help env commands' commands "$@"
}
(( $+functions[_pueue__help__env__set_commands] )) ||
_pueue__help__env__set_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help env set commands' commands "$@"
}
(( $+functions[_pueue__help__env__unset_commands] )) ||
_pueue__help__env__unset_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help env unset commands' commands "$@"
}
(( $+functions[_pueue__help__follow_commands] )) ||
_pueue__help__follow_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help follow commands' commands "$@"
}
(( $+functions[_pueue__help__group_commands] )) ||
_pueue__help__group_commands() {
    local commands; commands=(
'add:Add a group by name' \
'remove:Remove a group by name. This will move all tasks in this group to the default group!' \
    )
    _describe -t commands 'pueue help group commands' commands "$@"
}
(( $+functions[_pueue__help__group__add_commands] )) ||
_pueue__help__group__add_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help group add commands' commands "$@"
}
(( $+functions[_pueue__help__group__remove_commands] )) ||
_pueue__help__group__remove_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help group remove commands' commands "$@"
}
(( $+functions[_pueue__help__help_commands] )) ||
_pueue__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help help commands' commands "$@"
}
(( $+functions[_pueue__help__kill_commands] )) ||
_pueue__help__kill_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help kill commands' commands "$@"
}
(( $+functions[_pueue__help__log_commands] )) ||
_pueue__help__log_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help log commands' commands "$@"
}
(( $+functions[_pueue__help__parallel_commands] )) ||
_pueue__help__parallel_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help parallel commands' commands "$@"
}
(( $+functions[_pueue__help__pause_commands] )) ||
_pueue__help__pause_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help pause commands' commands "$@"
}
(( $+functions[_pueue__help__remove_commands] )) ||
_pueue__help__remove_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help remove commands' commands "$@"
}
(( $+functions[_pueue__help__reset_commands] )) ||
_pueue__help__reset_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help reset commands' commands "$@"
}
(( $+functions[_pueue__help__restart_commands] )) ||
_pueue__help__restart_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help restart commands' commands "$@"
}
(( $+functions[_pueue__help__send_commands] )) ||
_pueue__help__send_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help send commands' commands "$@"
}
(( $+functions[_pueue__help__shutdown_commands] )) ||
_pueue__help__shutdown_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help shutdown commands' commands "$@"
}
(( $+functions[_pueue__help__start_commands] )) ||
_pueue__help__start_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help start commands' commands "$@"
}
(( $+functions[_pueue__help__stash_commands] )) ||
_pueue__help__stash_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help stash commands' commands "$@"
}
(( $+functions[_pueue__help__status_commands] )) ||
_pueue__help__status_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help status commands' commands "$@"
}
(( $+functions[_pueue__help__switch_commands] )) ||
_pueue__help__switch_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help switch commands' commands "$@"
}
(( $+functions[_pueue__help__wait_commands] )) ||
_pueue__help__wait_commands() {
    local commands; commands=()
    _describe -t commands 'pueue help wait commands' commands "$@"
}
(( $+functions[_pueue__kill_commands] )) ||
_pueue__kill_commands() {
    local commands; commands=()
    _describe -t commands 'pueue kill commands' commands "$@"
}
(( $+functions[_pueue__log_commands] )) ||
_pueue__log_commands() {
    local commands; commands=()
    _describe -t commands 'pueue log commands' commands "$@"
}
(( $+functions[_pueue__parallel_commands] )) ||
_pueue__parallel_commands() {
    local commands; commands=()
    _describe -t commands 'pueue parallel commands' commands "$@"
}
(( $+functions[_pueue__pause_commands] )) ||
_pueue__pause_commands() {
    local commands; commands=()
    _describe -t commands 'pueue pause commands' commands "$@"
}
(( $+functions[_pueue__remove_commands] )) ||
_pueue__remove_commands() {
    local commands; commands=()
    _describe -t commands 'pueue remove commands' commands "$@"
}
(( $+functions[_pueue__reset_commands] )) ||
_pueue__reset_commands() {
    local commands; commands=()
    _describe -t commands 'pueue reset commands' commands "$@"
}
(( $+functions[_pueue__restart_commands] )) ||
_pueue__restart_commands() {
    local commands; commands=()
    _describe -t commands 'pueue restart commands' commands "$@"
}
(( $+functions[_pueue__send_commands] )) ||
_pueue__send_commands() {
    local commands; commands=()
    _describe -t commands 'pueue send commands' commands "$@"
}
(( $+functions[_pueue__shutdown_commands] )) ||
_pueue__shutdown_commands() {
    local commands; commands=()
    _describe -t commands 'pueue shutdown commands' commands "$@"
}
(( $+functions[_pueue__start_commands] )) ||
_pueue__start_commands() {
    local commands; commands=()
    _describe -t commands 'pueue start commands' commands "$@"
}
(( $+functions[_pueue__stash_commands] )) ||
_pueue__stash_commands() {
    local commands; commands=()
    _describe -t commands 'pueue stash commands' commands "$@"
}
(( $+functions[_pueue__status_commands] )) ||
_pueue__status_commands() {
    local commands; commands=()
    _describe -t commands 'pueue status commands' commands "$@"
}
(( $+functions[_pueue__switch_commands] )) ||
_pueue__switch_commands() {
    local commands; commands=()
    _describe -t commands 'pueue switch commands' commands "$@"
}
(( $+functions[_pueue__wait_commands] )) ||
_pueue__wait_commands() {
    local commands; commands=()
    _describe -t commands 'pueue wait commands' commands "$@"
}

if [ "$funcstack[1]" = "_pueue" ]; then
    _pueue "$@"
else
    compdef _pueue pueue
fi
