if not status is-interactive
    exit
end

eval (/opt/homebrew/bin/brew shellenv)

# Create XDG directories
set -l xdg_cache_dir "$HOME/.cache" # Replace with actual template value
set -l xdg_data_dir "$HOME/.local/share" # Replace with actual template value
set -l xdg_state_dir "$HOME/.local/state" # Replace with actual template value
set -l xdg_config_dir "$HOME/.config" # Replace with actual template value

for dir in "$xdg_cache_dir/fish" "$xdg_data_dir/fish" "$xdg_state_dir/fish"
    if not test -d $dir
        mkdir -p $dir
    end
end

# macOS Homebrew completions
if test (uname) = Darwin; and command -q brew
    set fish_complete_path $fish_complete_path (brew --prefix)/share/fish/completions
    set fish_complete_path $fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

set -U fish_greeting # disable fish greeting

# Source configuration files
# set config_locations "$xdg_config_dir/fish/fish-source"
#
# for location in $config_locations
#     if test -d $location
#         for config_file in (find $location -maxdepth 2 -name "*.fish" -type f | sort)
#             if test -r $config_file
#                 source $config_file
#             end
#         end
#     end
# end
