set -gx ATUIN_NOBIND true
atuin init fish | source

# In vi mode, Up in insert mode needs an explicit binding too.
if string match -q '4.*' $version
    bind up _atuin_bind_up # https://docs.atuin.sh/configuration/key-binding/#fish
    if bind -M insert >/dev/null 2>&1
        bind -M insert up _atuin_bind_up
    end
else
    bind -k up _atuin_bind_up
    bind \eOA _atuin_bind_up
    bind \e\[A _atuin_bind_up
    if bind -M insert >/dev/null 2>&1
        bind -M insert -k up _atuin_bind_up
        bind -M insert \eOA _atuin_bind_up
        bind -M insert \e\[A _atuin_bind_up
    end
end
