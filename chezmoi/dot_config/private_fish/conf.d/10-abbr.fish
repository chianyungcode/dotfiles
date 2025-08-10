#  █████╗ ██████╗ ██████╗ ██████╗
# ██╔══██╗██╔══██╗██╔══██╗██╔══██╗
# ███████║██████╔╝██████╔╝██████╔╝
# ██╔══██║██╔══██╗██╔══██╗██╔══██╗
# ██║  ██║██████╔╝██████╔╝██║  ██║
# ╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝
# abbreviations - user-defined words that are replaced with longer phrases when entered
# https://fishshell.com/docs/current/cmds/abbr.html
# cSpell:disable

# Abbreviations untuk bun
abbr b bun

# Dependencies
abbr ba 'bun add'
abbr bad 'bun add --dev'
abbr brm 'bun remove'
abbr bls 'bun pm ls'
abbr bin 'bun install'
abbr bu 'bun update'
abbr biny 'bun install --yarn'

# Global dependencies
abbr bga 'bun add --global'
abbr bgls 'bun pm ls --global'
abbr bgrm 'bun remove --global'
abbr bgu 'bun update --global'

# Run scripts
abbr br 'bun run'
abbr brun 'bun run'
abbr bd 'bun run dev'
abbr bb 'bun run build'
abbr bs 'bun run serve'
abbr bst 'bun run start'
abbr bt 'bun run test'
abbr btc 'bun run test --coverage'
abbr bln 'bun run lint'
abbr bdocs 'bun run docs'
abbr bfmt 'bun run format'

# Misc
abbr bi 'bun init'
abbr bc 'bun create'

abbr bx 'bun x'

# Bundle
abbr bbd 'bun build'

# Abbreviations untuk Docker
abbr dbl 'docker build'
abbr dcin 'docker container inspect'
abbr dcls 'docker container ls'
abbr dclsa 'docker container ls -a'
abbr dib 'docker image build'
abbr dii 'docker image inspect'
abbr dils 'docker image ls'
abbr dipu 'docker image push'
abbr dipru 'docker image prune -a'
abbr dirm 'docker image rm'
abbr dit 'docker image tag'
abbr dlo 'docker container logs'
abbr dnc 'docker network create'
abbr dncn 'docker network connect'
abbr dndcn 'docker network disconnect'
abbr dni 'docker network inspect'
abbr dnls 'docker network ls'
abbr dnrm 'docker network rm'
abbr dpo 'docker container port'
abbr dps 'docker ps'
abbr dpsa 'docker ps -a'
abbr dpu 'docker pull'
abbr dr 'docker container run'
abbr drit 'docker container run -it'
abbr drm 'docker container rm'
abbr 'drm!' 'docker container rm -f'
abbr dst 'docker container start'
abbr drs 'docker container restart'
abbr dsta 'docker stop $(docker ps -q)'
abbr dstp 'docker container stop'
abbr dtop 'docker top'
abbr dvi 'docker volume inspect'
abbr dvls 'docker volume ls'
abbr dvrm 'docker volume rm'
abbr dvprune 'docker volume prune'
abbr dxc 'docker container exec'
abbr dxcit 'docker container exec -it'

abbr ls 'eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
