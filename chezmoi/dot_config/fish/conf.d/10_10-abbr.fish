#  █████╗ ██████╗ ██████╗ ██████╗
# ██╔══██╗██╔══██╗██╔══██╗██╔══██╗
# ███████║██████╔╝██████╔╝██████╔╝
# ██╔══██║██╔══██╗██╔══██╗██╔══██╗
# ██║  ██║██████╔╝██████╔╝██║  ██║
# ╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝  ╚═╝
# abbreviations - user-defined words that are replaced with longer phrases when entered
# https://fishshell.com/docs/current/cmds/abbr.html
# cSpell:disable

# better defaults
abbr --add .. "cd .."
abbr --add ... "cd ../.."
abbr --add .... "cd ../../.."
abbr --add ..... "cd ../../../.."
abbr --add cat bat
abbr --add cl clear
abbr --add che chezmoi
abbr --add nv nvim
abbr --add lzg lazygit
abbr --add lzd lazydocker
abbr --add mux tmuxinator
abbr --add fier tmuxifier
abbr --add clrnvses 'rm -rf ~/.local/share/nvim/sessions/*'
abbr --add ax 'chmod a+x'
abbr --add untar 'tar -zxvf'
abbr --add mktar 'tar -cvzf'
abbr --add numfiles 'echo (ls -1 | wc -l)'
abbr --add bkzsh 'bindkey | fzf'
abbr --add bkfsh 'bind | fzf'
abbr --add bktmux 'tmux list-keys | fzf'
abbr --add dotf 'cd ~/.local/share/chezmoi'
abbr --add conf 'cd ~/.config/'
abbr --add exf 'exec fish'

# pueue
abbr --add pue pueue
abbr --add pueon 'pueued -d'
abbr --add puer 'pueue reset'

# brew
abbr --add bci "brew info --cask"
abbr --add bcin "brew install --cask"
abbr --add bcl "brew list --cask"
abbr --add bcn "brew cleanup"
abbr --add bco "brew outdated --cask"
abbr --add bcrin "brew reinstall --cask"
abbr --add bcubc "brew upgrade --cask && brew cleanup"
abbr --add bcubo "brew update && brew outdated --cask"
abbr --add bcup "brew upgrade --cask"
abbr --add bl "brew list"
abbr --add bo "brew outdated"
abbr --add brewdeps "brew deps --tree"
abbr --add brewp "brew pin"
abbr --add brewsp "brew list --pinned"
abbr --add brewtop "brew leaves -r"
abbr --add brewuses "brew uses --installed"
abbr --add brwe brew
abbr --add bsl "brew services list"
abbr --add bsoff "brew services stop"
abbr --add bsoffa "bsoff --all"
abbr --add bson "brew services start"
abbr --add bsona "bson --all"
abbr --add bsr "brew services run"
abbr --add bubc "brew upgrade && brew cleanup"
abbr --add bubo "brew update && brew outdated"
abbr --add bubu "bubo && bubc"
abbr --add bubug "bubo && bugbc"
abbr --add bugbc "brew upgrade --greedy && brew cleanup"
abbr --add bup "brew upgrade"
abbr --add buz "brew uninstall --zap"

# bun
abbr --add b bun
abbr --add ba "bun add"
abbr --add bad "bun add --dev"
abbr --add bb "bun run build"
abbr --add bbd "bun build"
abbr --add bc "bun create"
abbr --add bd "bun run dev"
abbr --add bdocs "bun run docs"
abbr --add bfmt "bun run format"
abbr --add bfu "brew upgrade --formula"
# abbr "bfzf"="bun run \"\$(jq -r '.scripts | keys[]' package.json | fzf --no-border)\""
abbr --add bga "bun add --global"
abbr --add bgls "bun pm ls --global"
abbr --add bgrm "bun remove --global"
abbr --add bgu "bun update --global"
abbr --add bi "bun init"
abbr --add bin "bun install"
abbr --add biny "bun install --yarn"
abbr --add bln "bun run lint"
abbr --add bls "bun pm ls"
abbr --add br "bun run"
abbr --add brm "bun remove"
abbr --add brun "bun run"
abbr --add bs "bun run serve"
abbr --add bst "bun run start"
abbr --add bt "bun run test"
abbr --add btc "bun run test --coverage"
abbr --add bu "bun update"
abbr --add bx "bun x"

# docker
abbr --add dbl "docker build"
abbr --add dcb "docker-compose build"
abbr --add dcdn "docker-compose down"
abbr --add dce "docker-compose exec"
abbr --add dcin "docker container inspect"
abbr --add dck "docker-compose kill"
abbr --add dcl "docker-compose logs"
abbr --add dclf "docker-compose logs -f"
abbr --add dclF "docker-compose logs -f --tail 0"
abbr --add dcls "docker container ls"
abbr --add dclsa "docker container ls -a"
abbr --add dco docker-compose
abbr --add dcps "docker-compose ps"
abbr --add dcpull "docker-compose pull"
abbr --add dcr "docker-compose run"
abbr --add dcrestart "docker-compose restart"
abbr --add dcrm "docker-compose rm"
abbr --add dcstart "docker-compose start"
abbr --add dcstop "docker-compose stop"
abbr --add dcup "docker-compose up"
abbr --add dcupb "docker-compose up --build"
abbr --add dcupd "docker-compose up -d"
abbr --add dcupdb "docker-compose up -d --build"
abbr --add dib "docker image build"
abbr --add dii "docker image inspect"
abbr --add dils "docker image ls"
abbr --add dipru "docker image prune -a"
abbr --add dipu "docker image push"
abbr --add dirm "docker image rm"
abbr --add dit "docker image tag"
abbr --add dlo "docker container logs"
abbr --add dnc "docker network create"
abbr --add dncn "docker network connect"
abbr --add dndcn "docker network disconnect"
abbr --add dni "docker network inspect"
abbr --add dnls "docker network ls"
abbr --add dnrm "docker network rm"
abbr --add dotf "cd ~/.local/share/chezmoi"
abbr --add dpo "docker container port"
abbr --add dps "docker ps"
abbr --add dpsa "docker ps -a"
abbr --add dpu "docker pull"
abbr --add dr "docker container run"
abbr --add drit "docker container run -it"
abbr --add drm "docker container rm"
# abbr --add drm\! "docker container rm -f"
abbr --add drs "docker container restart"
abbr --add dst "docker container start"
abbr --add dsta "docker stop \$(docker ps -q)"
abbr --add dstp "docker container stop"
abbr --add dsts "docker stats"
abbr --add dtop "docker top"
abbr --add dvi "docker volume inspect"
abbr --add dvls "docker volume ls"
abbr --add dvprune "docker volume prune"
abbr --add dxc "docker container exec"
abbr --add dxcit "docker container exec -it"

# eza
abbr --add l "eza -l --classify=auto --icons=auto --git"
abbr --add la "eza -lbhHigUmuSa --icons=auto --git"
abbr --add ll "eza -lah --classify=auto --icons=auto --git"
abbr --add llm "ll --sort=modified"
abbr --add llt "eza -lah --classify=always --tree --level=2 --icons=auto"
abbr --add ls "eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
abbr --add lt "eza --tree --level=2 --icons=auto"
abbr --add lx "eza -lbhHigUmuSa@ --icons=auto --git"
abbr --add cyh "eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"

# npm
abbr --add npmD "npm i -D "
# abbr "npmE"="PATH=\"\$(npm bin)\":\"\$PATH\""
abbr --add npmF "npm i -f"
abbr --add npmg "npm i -g "
abbr --add npmI "npm init"
abbr --add npmi "npm info"
abbr --add npmL "npm list"
abbr --add npmL0 "npm ls --depth=0"
abbr --add npmO "npm outdated"
abbr --add npmP "npm publish"
abbr --add npmR "npm run"
abbr --add npmrb "npm run build"
abbr --add npmrd "npm run dev"
abbr --add npmS "npm i -S "
abbr --add npmSe "npm search"
abbr --add npmst "npm start"
abbr --add npmt "npm test"
abbr --add npmU "npm update"
abbr --add npmV "npm -v"

# ssh
abbr --add mbp "ssh mbp"
abbr --add ghcny "ssh ghcny"
abbr --add ghphyne "ssh ghphyne"

# pet
abbr --add psc "pet search"
abbr --add pexec "pet exec -t"

# macos
abbr --add showdot "defaults write com.apple.finder AppleShowAllFiles TRUE"
abbr --add spot-file "lsof -c '/mds\$/'"
abbr --add spot-off "sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
abbr --add spot-on "sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist"
abbr --add tailacer "ssh tailacer"
abbr --add tailmbp "ssh tailmbp"
abbr --add tailprefs "tailscale debug prefs"
abbr --add ax "chmod a+x"
abbr --add bktmux "tmux list-keys | fzf"
abbr --add bkfish "bind | fzf"
abbr --add hidedot "defaults write com.apple.finder AppleShowAllFiles FALSE"
abbr --add cpwd "echo $(pwd) | pbcopy"
abbr --add bsra "bsr --all"
abbr --add caff "caffeinate -ism"
abbr --add cleanupLS "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user && killall Finder"

# pueue
abbr --add pue pueue
abbr pueon "pueued -d"

# git
abbr --add g git
abbr --add ga "git add"
abbr --add gaa "git add --all"
abbr --add gam "git am"
abbr --add gama "git am --abort"
abbr --add gamc "git am --continue"
abbr --add gams "git am --skip"
abbr --add gamscp "git am --show-current-patch"
abbr --add gap "git apply"
abbr --add gapa "git add --patch"
abbr --add gapt "git apply --3way"
abbr --add gau "git add --update"
abbr --add gav "git add --verbose"
abbr --add gb "git branch"
abbr --add gba "git branch --all"
abbr --add gbD "git branch --delete --force"
abbr --add gbd "git branch --delete"
# abbr "gbg"="LANG=C git branch -vv | grep \": gone\]\""
# abbr "gbgd"="LANG=C git branch --no-color -vv | grep \": gone\]\" | cut -c 3- | awk '{print \$1}' | xargs git branch -d"
# abbr "gbgD"="LANG=C git branch --no-color -vv | grep \": gone\]\" | cut -c 3- | awk '{print \$1}' | xargs git branch -D"
abbr --add gbl "git blame -w"
abbr --add gbm "git branch --move"
abbr --add gbnm "git branch --no-merged"
abbr --add gbr "git branch --remote"
abbr --add gbs "git bisect"
abbr --add gbsb "git bisect bad"
abbr --add gbsg "git bisect good"
abbr --add gbsn "git bisect new"
abbr --add gbso "git bisect old"
abbr --add gbsr "git bisect reset"
abbr --add gbss "git bisect start"
abbr --add gc "git commit --verbose"
abbr --add gc\! "git commit --verbose --amend"
abbr --add gca "git commit --verbose --all"
abbr --add gca\! "git commit --verbose --all --amend"
abbr --add gcam "git commit --all --message"
abbr --add gcan\! 'git commit --verbose --all --no-edit --amend'
abbr --add gcann\! 'git commit --verbose --all --date=now --no-edit --amend'
abbr --add gcans\! 'git commit --verbose --all --signoff --no-edit --amend'
abbr --add gcas "git commit --all --signoff"
abbr --add gcasm "git commit --all --signoff --message"
abbr --add gcB "git checkout -B"
abbr --add gcb "git checkout -b"
abbr --add gcd "git checkout \$(git_develop_branch)"
abbr --add gcf "git config --list"
abbr --add gcfu "git commit --fixup"
abbr --add gcl "git clone --recurse-submodules"
abbr --add gclean "git clean --interactive -d"
abbr --add gclf "git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules"
abbr --add gcm "git checkout \$(git_main_branch)"
abbr --add gcmsg "git commit --message"
abbr --add gcn "git commit --verbose --no-edit"
# abbr --add gcn\! "git commit --verbose --no-edit --amend"
abbr --add gco "git checkout"
abbr --add gcor "git checkout --recurse-submodules"
abbr --add gcount "git shortlog --summary --numbered"
abbr --add gcp "git cherry-pick"
abbr --add gcp1 "ssh gcp1"
abbr --add gcpa "git cherry-pick --abort"
abbr --add gcpc "git cherry-pick --continue"
abbr --add gcs "git commit --gpg-sign"
abbr --add gcsm "git commit --signoff --message"
abbr --add gcss "git commit --gpg-sign --signoff"
abbr --add gcssm "git commit --gpg-sign --signoff --message"
abbr --add gd "git diff"
abbr --add gdca "git diff --cached"
abbr --add gdct "git describe --tags \$(git rev-list --tags --max-count=1)"
abbr --add gdcw "git diff --cached --word-diff"
abbr --add gds "git diff --staged"
abbr --add gdt "git diff-tree --no-commit-id --name-only -r"
abbr --add gdup "git diff @{upstream}"
abbr --add gdw "git diff --word-diff"
abbr --add gf "git fetch"
abbr --add gfa "git fetch --all --tags --prune --jobs=10"
abbr --add gfg "git ls-files | grep"
abbr --add gfo "git fetch origin"
abbr --add gg "git gui citool"
abbr --add gga "git gui citool --amend"
# abbr "ggpull"="git pull origin \"\$(git_current_branch)\""
abbr --add ggpur ggu
# abbr "ggpush"="git push origin \"\$(git_current_branch)\""
abbr --add ggsup "git branch --set-upstream-to=origin/\$(git_current_branch)"
abbr --add gignore "git update-index --assume-unchanged"
# abbr "gignored"="git ls-files -v | grep \"^[[:lower:]]\""
abbr --add git-svn-dcommit-push "git svn dcommit && git push github \$(git_main_branch):svntrunk"
abbr --add gk "\gitk --all --branches &\!"
abbr --add gke "\gitk --all \$(git log --walk-reflogs --pretty=%h) &\!"
abbr --add gl "git pull"
abbr --add glab "op plugin run -- glab"
abbr --add glg "git log --stat"
abbr --add glgg "git log --graph"
abbr --add glgga "git log --graph --decorate --branches --remotes --tags"
abbr --add glggaa "git log --graph --decorate --all"
abbr --add glgm "git log --graph --max-count=10"
abbr --add glgp "git log --stat --patch"
abbr --add glo "git log --oneline --decorate"
abbr --add glod 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset"'
abbr --add glods 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset" --date=short'
abbr --add glog "git log --oneline --decorate --graph"
abbr --add glogaa "git log --oneline --decorate --graph --all"
abbr --add gloga "git log --oneline --decorate --graph --branches --remotes --tags"
abbr --add glol 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
abbr --add glolaa 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --all'
abbr --add glola 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --branches --remotes --tags'
abbr --add glols 'git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" --stat'
abbr --add glp _git_log_prettily
abbr --add gluc "git pull upstream \$(git_current_branch)"
abbr --add glum "git pull upstream \$(git_main_branch)"
abbr --add gm "git merge"
abbr --add gma "git merge --abort"
abbr --add gmc "git merge --continue"
abbr --add gmff "git merge --ff-only"
abbr --add gmom "git merge origin/\$(git_main_branch)"
abbr --add gms "git merge --squash"
abbr --add gmtl "git mergetool --no-prompt"
abbr --add gmtlvim "git mergetool --no-prompt --tool=vimdiff"
abbr --add gmum "git merge upstream/\$(git_main_branch)"
abbr --add gp "git push"
abbr --add gpd "git push --dry-run"
abbr --add gpf "git push --force-with-lease --force-if-includes"
# abbr --add gpf\! "git push --force"
abbr --add gpoat "git push origin --all && git push origin --tags"
abbr --add gpod "git push origin --delete"
abbr --add gpr "git pull --rebase"
abbr --add gpra "git pull --rebase --autostash"
abbr --add gprav "git pull --rebase --autostash -v"
abbr --add gpristine "git reset --hard && git clean --force -dfx"
abbr --add gprom "git pull --rebase origin \$(git_main_branch)"
abbr --add gpromi "git pull --rebase=interactive origin \$(git_main_branch)"
abbr --add gprum "git pull --rebase upstream \$(git_main_branch)"
abbr --add gprumi "git pull --rebase=interactive upstream \$(git_main_branch)"
abbr --add gprv "git pull --rebase -v"
abbr --add gpsup "git push --set-upstream origin \$(git_current_branch)"
abbr --add gpsupf "git push --set-upstream origin \$(git_current_branch) --force-with-lease --force-if-includes"
abbr --add gpu "git push upstream"
abbr --add gpv "git push --verbose"
abbr --add gr "git remote"
abbr --add gra "git remote add"
abbr --add grb "git rebase"
abbr --add grba "git rebase --abort"
abbr --add grbc "git rebase --continue"
abbr --add grbd "git rebase \$(git_develop_branch)"
abbr --add grbi "git rebase --interactive"
abbr --add grbm "git rebase \$(git_main_branch)"
abbr --add grbo "git rebase --onto"
abbr --add grbom "git rebase origin/\$(git_main_branch)"
abbr --add grbs "git rebase --skip"
abbr --add grbum "git rebase upstream/\$(git_main_branch)"
abbr --add grev "git revert"
abbr --add greva "git revert --abort"
abbr --add grevc "git revert --continue"
abbr --add grf "git reflog"
abbr --add grh "git reset"
abbr --add grhh "git reset --hard"
abbr --add grhk "git reset --keep"
abbr --add grhs "git reset --soft"
abbr --add grm "git rm"
abbr --add grmc "git rm --cached"
abbr --add grmv "git remote rename"
abbr --add groh "git reset origin/\$(git_current_branch) --hard"
abbr --add grrm "git remote remove"
abbr --add grs "git restore"
abbr --add grset "git remote set-url"
abbr --add grss "git restore --source"
abbr --add grst "git restore --staged"
# abbr "grt"="cd \"\$(git rev-parse --show-toplevel || echo .)\""
abbr --add gru "git reset --"
abbr --add grup "git remote update"
abbr --add grv "git remote --verbose"
abbr --add gsb "git status --short --branch"
abbr --add gsd "git svn dcommit"
abbr --add gsh "git show"
abbr --add gsi "git submodule init"
abbr --add gsps "git show --pretty=short --show-signature"
abbr --add gsr "git svn rebase"
abbr --add gss "git status --short"
abbr --add gst "git status"
abbr --add gsta "git stash push"
abbr --add gstaa "git stash apply"
abbr --add gstall "git stash --all"
abbr --add gstc "git stash clear"
abbr --add gstd "git stash drop"
abbr --add gstl "git stash list"
abbr --add gstp "git stash pop"
abbr --add gsts "git stash show --patch"
abbr --add gstu "gsta --include-untracked"
abbr --add gsu "git submodule update"
abbr --add gsw "git switch"
abbr --add gswc "git switch --create"
abbr --add gswd "git switch develop"
abbr --add gswm "git switch main"
abbr --add gta "git tag --annotate"
# abbr "gtl"="gtl(){ git tag --sort=-v:refname -n --list \"\${1}*\" }; noglob gtl"
abbr --add gts "git tag --sign"
abbr --add gtv "git tag | sort -V"
abbr --add gunignore "git update-index --no-assume-unchanged"
# abbr "gunwip"="git rev-list --max-count=1 --format=\"%s\" HEAD | grep -q \"\--wip--\" && git reset HEAD~1"
# abbr "gup"="
# print -Pu2 \"%F{yellow}[oh-my-zsh] '%F{red}gup%F{yellow}' is a deprecated alias, using '%F{green}gpr%F{yellow}' instead.%f\"
# gpr"
# abbr "gupa"="
# print -Pu2 \"%F{yellow}[oh-my-zsh] '%F{red}gupa%F{yellow}' is a deprecated alias, using '%F{green}gpra%F{yellow}' instead.%f\"
# gpra"
# abbr "gupav"="
# print -Pu2 \"%F{yellow}[oh-my-zsh] '%F{red}gupav%F{yellow}' is a deprecated alias, using '%F{green}gprav%F{yellow}' instead.%f\"
# gprav"
# abbr "gupom"="
# print -Pu2 \"%F{yellow}[oh-my-zsh] '%F{red}gupom%F{yellow}' is a deprecated alias, using '%F{green}gprom%F{yellow}' instead.%f\"
# gprom"
# abbr "gupomi"="
# print -Pu2 \"%F{yellow}[oh-my-zsh] '%F{red}gupomi%F{yellow}' is a deprecated alias, using '%F{green}gpromi%F{yellow}' instead.%f\"
# gpromi"
# abbr "gupv"="
# print -Pu2 \"%F{yellow}[oh-my-zsh] '%F{red}gupv%F{yellow}' is a deprecated alias, using '%F{green}gprv%F{yellow}' instead.%f\"
# gprv"
abbr --add gwch "git whatchanged -p --abbrev-commit --pretty=medium"
# abbr "gwip"="git add -A; git rm \$(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign --message \"--wip-- [skip ci]\""
abbr --add gwipe "git reset --hard && git clean --force -df"
abbr --add gwt "git worktree"
abbr --add gwta "git worktree add"
abbr --add gwtls "git worktree list"
abbr --add gwtmv "git worktree move"
abbr --add gwtrm "git worktree remove"

# Jujutsu
abbr -a j jj # I use `jj` to exit insert mode
abbr -a jh 'jj -h'

abbr -a jr --set-cursor 'jj rebase -s % -d @-'
abbr -a jst 'jj status'
abbr -a jsh --set-cursor 'jj show %'

abbr -a jbl 'jj bookmark list -a'
abbr -a jbm --set-cursor 'jj bookmark move % --to @-'
abbr -a jbmm 'jj bookmark move main --to @-'
abbr -a jbsc 'jj bookmark set -r @'

abbr -a jdf 'jj diff'
abbr -a je --set-cursor 'jj edit %'

abbr -a jgf 'jj git fetch'
abbr -a jgpa 'jj git push'
abbr -a jgps --set-cursor 'jj git push -b %'
abbr -a jgpsm --set-cursor 'jj git push -b main'

abbr -a jl 'jj log'
abbr -a jla "jj log 'all()'"
abbr -a jlt --set-cursor "jj log -T %"

abbr -a jsp 'jj split'
abbr -a jspi 'jj split -i'

abbr -a jsq 'jj squash'
abbr -a jsqi 'jj squash -i'
abbr -a jsqc --set-cursor 'jj squash -t %'

abbr -a jab --set-cursor 'jj abandon %'

abbr -a jd --set-cursor 'jj desc -m "%"'
abbr -a jdc 'jj desc -m "$(koji --stdout)"'

abbr -a jc 'jj commit'
abbr -a jcc 'jj commit -m "$(koji --stdout)"'

abbr -a jn --set-cursor 'jj new %'
abbr -a jnc 'jj new -m "$(koji --stdout)"'

abbr -a judo 'jj undo'
abbr -a jopl 'jj op log'
abbr -a jevl 'jj evolog'

# tmux
abbr --add tx tmux
abbr --add tl "tmux list-sessions"
abbr --add ts --set-cursor 'tmux new -s "%"'
abbr --add tksv "tmux kill-server"

# tmuxifier
abbr --add txi tmuxifier
abbr --add txis --set-cursor 'tmuxifier s "%"'

# zellij
abbr --add zl zellij
abbr --add zla "zellij attach"
abbr --add zld --set-cursor 'zellij delete-session "%"'
abbr --add zlda "zellij delete-all-sessions"
abbr --add zlk --set-cursor 'zellij kill-session "%"'
abbr --add zlka "zellij kill-all-sessions"
abbr --add zlls "zellij list-sessions"

# 1password
abbr --add vercel "op plugin run -- vercel"
abbr --add gh "op plugin run -- gh"

abbr --add chp --set-cursor 'chezmoi apply -P ~/.config/%'

abbr --add untar "tar -zxvf"
# abbr "urldecode"="python -c \"import sys, urllib as ul; print ul.unquote_plus(sys.argv[1])\""
abbr --add which-command whence

# Personal abbreviations
abbr --add ch chezmoi
abbr --add tmuxconf "\$EDITOR ~/.local/share/chezmoi/chezmoi/dot_config/tmux/tmux.conf.tmpl"
abbr restart-kanata sudo launchctl kickstart -k system/com.example.kanata
abbr --add nv nvim
abbr --add nvdot "nvim ~/.local/share/chezmoi"
abbr --add numfiles "echo \$(ls -1 | wc -l)"
abbr --add exf "exec fish"
abbr --add cat bat
abbr --add cl clear
abbr --add clrnvses "rm -rf ~/.local/share/nvim/sessions/*"
abbr --add config "cd ~/.config/"
abbr --add fier tmuxifier
abbr --add fixmounts "sudo automount -vcu"
abbr --add fsh-alias fast-theme
abbr --add ghh "git help"
abbr --add lzd lazydocker
abbr --add lzg lazygit
abbr --add mktar "tar -cvzf"
abbr --add mux tmuxinator
abbr --add ping gping
abbr --add prgl pretty_git_log
abbr --add run-help man
abbr dopr "doppler run -- "
