remove_formulae=(
{{- range .packages.homebrew.to_remove }}
    "{{ . }}"
{{- end }}
)

formulae=(
{{- if .features.graphical }}
{{- range .packages.homebrew.graphical.formulae }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.development }}
{{- range .packages.homebrew.development.formulae }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.homebrew.homelab.formulae }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.homebrew.personal.formulae }}
    "{{ . }}"
{{- end }}
{{- end }}
)

casks=(
{{- if .features.graphical }}
{{- range .packages.homebrew.graphical.casks }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if and .features.development .features.graphical }}
{{- range .packages.homebrew.development.casks }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if and .features.homelab .features.graphical }}
{{- range .packages.homebrew.homelab.casks }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if and .features.personal .features.graphical }}
{{- range .packages.homebrew.personal.casks }}
    "{{ . }}"
{{- end }}
{{- end }}
)

mas_apps=(
{{- if .features.graphical }}
{{- range .packages.mas.common.apps }}
    "{{ . }}"
{{- end }}
{{- if .features.development }}
{{- range .packages.mas.development.apps }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.mas.homelab.apps }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.mas.personal.apps }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- end }}
)

homebrew_app_name() {
    case "$1" in
{{- range $cask, $app := .diff_name_apps }}
    "{{ $cask }}") printf '%s' "{{ $app }}" ;;
{{- end }}
    *)
        printf '%s' "$1" |
            sed 's/-/ /g' |
            awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1'
        ;;
    esac
}

install_homebrew_packages() {
    require_command brew
    export HOMEBREW_NO_INSTALL_UPGRADE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"

    brew update

    if [[ ${#remove_formulae[@]} -gt 0 ]]; then
        for package in "${remove_formulae[@]}"; do
            if brew list --formula "$package" >/dev/null 2>&1; then
                brew uninstall --formula "$package"
            fi
        done
    fi

    if [[ ${#formulae[@]} -gt 0 ]]; then
        for formula in "${formulae[@]}"; do
            if brew list --formula "$formula" >/dev/null 2>&1; then
                continue
            fi
            brew install --formula "$formula"
        done
    fi

    if [[ -z "${CI:-}" ]]; then
        if [[ ${#casks[@]} -gt 0 ]]; then
            for cask in "${casks[@]}"; do
                brew list --cask "$cask" >/dev/null 2>&1 && continue
                app_name=$(homebrew_app_name "$cask")
                if [[ -d "/Applications/$app_name.app" ||
                    -d "/Applications/Setapp/$app_name.app" ]]; then
                    notice "Skipping $cask because $app_name.app already exists"
                    continue
                fi
                brew install --cask "$cask"
            done
        fi

        if [[ ${#mas_apps[@]} -gt 0 ]]; then
            require_command mas
            for app_id in "${mas_apps[@]}"; do
                mas list | awk '{print $1}' | grep -Fxq "$app_id" ||
                    mas install "$app_id"
            done
        fi
    fi
}
