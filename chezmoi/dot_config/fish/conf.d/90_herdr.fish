# The hook no-ops outside a herdr pane, so skip sourcing it there.
if set -q HERDR_PANE_ID
    for _f in $HOME/.config/herdr/plugins/github/herdr-automatic-rename-*/shell/hook.fish
        test -r "$_f"; and source "$_f"; and break
    end
    set -e _f
end
