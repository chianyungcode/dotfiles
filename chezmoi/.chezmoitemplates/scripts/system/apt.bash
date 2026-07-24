remove_packages=(
{{- range .packages.apt.to_remove }}
    "{{ . }}"
{{- end }}
)

packages=(
{{- range .packages.apt.common.packages }}
    "{{ . }}"
{{- end }}
{{- if .features.development }}
{{- range .packages.apt.development.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.apt.homelab.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.apt.personal.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
)

apt_package_installed() {
    dpkg-query -W -f='${db:Status-Abbrev}' "$1" 2>/dev/null |
        grep -q '^ii '
}

apt_package_available() {
    apt-cache show "$1" >/dev/null 2>&1
}

ensure_eza_repository() {
    command -v eza >/dev/null 2>&1 && return 0
    sudo install -d -m 0755 /etc/apt/keyrings
    make_temp_dir "eza-repository"
    curl --fail --show-error --silent --location --retry 3 \
        https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        --output "$TEMP_DIR/eza.asc"
    gpg --dearmor <"$TEMP_DIR/eza.asc" |
        sudo tee /etc/apt/keyrings/gierens.gpg >/dev/null
    printf '%s\n' \
        'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' |
        sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
}

install_apt_packages() {
    require_command apt-get
    require_command dpkg-query
    sudo apt-get update
    if ! command -v gpg >/dev/null 2>&1; then
        sudo apt-get install -y --no-upgrade gpg
    fi
    ensure_eza_repository
    sudo apt-get update

    if [[ ${#remove_packages[@]} -gt 0 ]]; then
        for package in "${remove_packages[@]}"; do
            apt_package_installed "$package" &&
                sudo apt-get remove -y "$package"
        done
    fi

    if [[ ${#packages[@]} -gt 0 ]]; then
        for package in "${packages[@]}"; do
            apt_package_installed "$package" && continue
            apt_package_available "$package" ||
                die "APT package is unavailable: $package"
            sudo apt-get install -y --no-upgrade "$package"
        done
    fi
}
