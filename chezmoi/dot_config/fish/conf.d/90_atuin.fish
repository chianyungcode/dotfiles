set -gx ATUIN_NOBIND true
# Create the session id here instead of letting the init script spawn
# `atuin uuid` (same 32-hex format, version-7 nibble set).
if not set -q ATUIN_SESSION; or test "$ATUIN_SHLVL" != "$SHLVL"
    set -gx ATUIN_SESSION (printf '%04x%04x%04x7%03x%04x%04x%04x%04x' (random 0 65535) (random 0 65535) (random 0 65535) (random 0 4095) (random 32768 49151) (random 0 65535) (random 0 65535) (random 0 65535))
    set -gx ATUIN_SHLVL $SHLVL
end
__cached_source atuin

# In vi mode, Up in insert mode needs an explicit binding too.
if string match -q '4.*' $version
    bind ctrl-r _atuin_search
    bind up _atuin_bind_up # https://docs.atuin.sh/configuration/key-binding/#fish
    if bind -M insert >/dev/null 2>&1
        bind -M insert ctrl-r _atuin_search
        bind -M insert up _atuin_bind_up
    end
else
    bind \cr _atuin_search
    bind -k up _atuin_bind_up
    bind \eOA _atuin_bind_up
    bind \e\[A _atuin_bind_up
    if bind -M insert >/dev/null 2>&1
        bind -M insert \cr _atuin_search
        bind -M insert -k up _atuin_bind_up
        bind -M insert \eOA _atuin_bind_up
        bind -M insert \e\[A _atuin_bind_up
    end
end
