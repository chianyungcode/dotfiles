# Source a tool's generated init script from a cache instead of spawning the
# tool on every startup. The cache file is keyed on the binary's resolved path
# and mtime, so it is rebuilt automatically after e.g. `brew upgrade`.
#   usage: __cached_source <binary> [command ...]   (command defaults to <binary> init fish)
function __cached_source
    set -l bin (command -s $argv[1]); or return
    set -l cmd $argv[2..]
    set -q cmd[1]; or set cmd $argv[1] init fish
    set -l real (builtin path resolve -- $bin)
    set -l cache_home ~/.cache
    set -q XDG_CACHE_HOME; and set cache_home $XDG_CACHE_HOME
    set -l dir $cache_home/fish/init/$argv[1]
    set -l cache $dir/(string replace -a / % -- $real)@(builtin path mtime -- $real).fish
    if not test -r $cache
        command rm -rf $dir
        command mkdir -p $dir
        $cmd >$cache.tmp; and command mv -f $cache.tmp $cache; or return
    end
    source $cache
end
