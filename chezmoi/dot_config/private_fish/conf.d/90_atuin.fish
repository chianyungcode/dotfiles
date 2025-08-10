set -gx ATUIN_NOBIND true
atuin init fish | source

bind up _atuin_bind_up # https://docs.atuin.sh/configuration/key-binding/#fish
