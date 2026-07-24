remove_packages=(
{{- range .packages.pacman.to_remove }}
    "{{ . }}"
{{- end }}
)

packages=(
{{- range .packages.pacman.common.packages }}
    "{{ . }}"
{{- end }}
{{- if .features.development }}
{{- range .packages.pacman.development.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.pacman.homelab.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.pacman.personal.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
)

install_paru_packages() {
    require_command paru

    if [[ ${#remove_packages[@]} -gt 0 ]]; then
        for package in "${remove_packages[@]}"; do
            pacman -Q "$package" >/dev/null 2>&1 &&
                paru -R --noconfirm "$package"
        done
    fi

    if [[ ${#packages[@]} -gt 0 ]]; then
        for package in "${packages[@]}"; do
            pacman -Q "$package" >/dev/null 2>&1 && continue
            paru -Si "$package" >/dev/null 2>&1 ||
                die "Pacman/AUR package is unavailable: $package"
            paru -S --noconfirm --needed --skipreview --batchinstall "$package"
        done
    fi
}
