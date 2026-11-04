# Source a tool's generated init script from a cache instead of spawning the
# tool on every startup. The cache file is keyed on the binary's resolved path
# and mtime, so it is rebuilt automatically after e.g. `brew upgrade`.
#   usage: __cached_source <binary> [command ...]   (command defaults to <binary> init zsh)
zmodload -F zsh/stat b:zstat

__cached_source() {
  local bin=${commands[$1]}
  [[ -n $bin ]] || return 1
  local -a cmd=("${@:2}")
  (( $#cmd )) || cmd=($1 init zsh)
  local real=${bin:A} mtime
  zstat -A mtime +mtime -- $real || return 1
  local dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init/$1
  local cache=$dir/${real//\//%}@$mtime.zsh
  if [[ ! -r $cache ]]; then
    command rm -rf -- $dir
    command mkdir -p -- $dir
    "${cmd[@]}" >| $cache.tmp && command mv -f -- $cache.tmp $cache || return
    zcompile -- $cache
  fi
  source $cache
}
