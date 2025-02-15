# Abbreviations untuk bun
abbr --add b bun

# Dependencies
abbr --add ba 'bun add'
abbr --add bad 'bun add --dev'
abbr --add brm 'bun remove'
abbr --add bls 'bun pm ls'
abbr --add bin 'bun install'
abbr --add bu 'bun update'
abbr --add biny 'bun install --yarn'

# Global dependencies
abbr --add bga 'bun add --global'
abbr --add bgls 'bun pm ls --global'
abbr --add bgrm 'bun remove --global'
abbr --add bgu 'bun update --global'

# Run scripts
abbr --add br 'bun run'
abbr --add brun 'bun run'
abbr --add bd 'bun run dev'
abbr --add bb 'bun run build'
abbr --add bs 'bun run serve'
abbr --add bst 'bun run start'
abbr --add bt 'bun run test'
abbr --add btc 'bun run test --coverage'
abbr --add bln 'bun run lint'
abbr --add bdocs 'bun run docs'
abbr --add bfmt 'bun run format'

# Misc
abbr --add bi 'bun init'
abbr --add bc 'bun create'

abbr --add bx 'bun x'

# Bundle
abbr --add bbd 'bun build'

# Abbreviations untuk Docker
abbr --add dbl 'docker build'
abbr --add dcin 'docker container inspect'
abbr --add dcls 'docker container ls'
abbr --add dclsa 'docker container ls -a'
abbr --add dib 'docker image build'
abbr --add dii 'docker image inspect'
abbr --add dils 'docker image ls'
abbr --add dipu 'docker image push'
abbr --add dipru 'docker image prune -a'
abbr --add dirm 'docker image rm'
abbr --add dit 'docker image tag'
abbr --add dlo 'docker container logs'
abbr --add dnc 'docker network create'
abbr --add dncn 'docker network connect'
abbr --add dndcn 'docker network disconnect'
abbr --add dni 'docker network inspect'
abbr --add dnls 'docker network ls'
abbr --add dnrm 'docker network rm'
abbr --add dpo 'docker container port'
abbr --add dps 'docker ps'
abbr --add dpsa 'docker ps -a'
abbr --add dpu 'docker pull'
abbr --add dr 'docker container run'
abbr --add drit 'docker container run -it'
abbr --add drm 'docker container rm'
abbr --add 'drm!' 'docker container rm -f'
abbr --add dst 'docker container start'
abbr --add drs 'docker container restart'
abbr --add dsta 'docker stop $(docker ps -q)'
abbr --add dstp 'docker container stop'
abbr --add dtop 'docker top'
abbr --add dvi 'docker volume inspect'
abbr --add dvls 'docker volume ls'
abbr --add dvrm 'docker volume rm'
abbr --add dvprune 'docker volume prune'
abbr --add dxc 'docker container exec'
abbr --add dxcit 'docker container exec -it'

abbr --add ls 'eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
