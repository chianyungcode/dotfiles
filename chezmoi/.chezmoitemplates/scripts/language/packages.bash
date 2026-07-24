install_uv_tools() {
    require_command uv
    local package
    if [[ -n ${uv_remove[*]:-} ]]; then
        for package in "${uv_remove[@]}"; do
            if uv tool list | awk '{print $1}' | grep -Fxq "$package"; then
                uv tool uninstall "$package"
            fi
        done
    fi
    if [[ -n ${uv_packages[*]:-} ]]; then
        for package in "${uv_packages[@]}"; do
            if ! uv tool list | awk '{print $1}' | grep -Fxq "$package"; then
                uv tool install "$package"
            fi
        done
    fi
}

install_npm_packages() {
    [[ -z ${npm_packages[*]:-} && -z ${npm_remove[*]:-} ]] && return 0
    require_command npm
    local package
    if [[ -n ${npm_remove[*]:-} ]]; then
        for package in "${npm_remove[@]}"; do
            if npm list -g --depth=0 "$package" >/dev/null 2>&1; then
                npm uninstall -g "$package"
            fi
        done
    fi
    if [[ -n ${npm_packages[*]:-} ]]; then
        for package in "${npm_packages[@]}"; do
            if ! npm list -g --depth=0 "$package" >/dev/null 2>&1; then
                npm install -g "$package"
            fi
        done
    fi
}

install_cargo_packages() {
    [[ -z ${cargo_packages[*]:-} && -z ${cargo_remove[*]:-} ]] &&
        return 0
    require_command cargo
    local installed package
    installed=$(cargo install --list 2>/dev/null |
        awk '$2 ~ /^v/ {print $1}')
    if [[ -n ${cargo_remove[*]:-} ]]; then
        for package in "${cargo_remove[@]}"; do
            if printf '%s\n' "$installed" | grep -Fxq "$package"; then
                cargo uninstall "$package"
            fi
        done
    fi
    if [[ -n ${cargo_packages[*]:-} ]]; then
        for package in "${cargo_packages[@]}"; do
            if ! printf '%s\n' "$installed" | grep -Fxq "$package"; then
                cargo install "$package"
            fi
        done
    fi
}
