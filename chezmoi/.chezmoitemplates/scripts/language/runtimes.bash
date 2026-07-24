{{- $hasRuntimes := false -}}
{{- range $runtime := .runtimes -}}
{{- range $feature := $runtime.features -}}
{{- if index $.features $feature -}}
{{- $hasRuntimes = true -}}
{{- end -}}
{{- end -}}
{{- end -}}

download_installer() {
    local url=$1
    local name=$2
    make_temp_dir "$name"
    local installer="$TEMP_DIR/$name.sh"
    curl --fail --show-error --silent --location --retry 3 \
        "$url" --output "$installer"
    /bin/sh "$installer"
}

ensure_uv() {
    command -v uv >/dev/null 2>&1 && return 0
    # shellcheck disable=SC2194 # chezmoi renders the platform as a literal.
    case "{{ .chezmoi.os }}:{{ index .chezmoi.osRelease "id" | default "" }}" in
    darwin:*) brew install uv ;;
    linux:arch) paru -S --needed --noconfirm uv ;;
    linux:ubuntu | linux:debian)
        download_installer https://astral.sh/uv/install.sh uv-install
        ;;
    *) die "cannot install uv on this platform" ;;
    esac
    export PATH="$HOME/.local/bin:$PATH"
    require_command uv
}

{{ if $hasRuntimes -}}
ensure_mise() {
    command -v mise >/dev/null 2>&1 && return 0
    # shellcheck disable=SC2194 # chezmoi renders the platform as a literal.
    case "{{ .chezmoi.os }}:{{ index .chezmoi.osRelease "id" | default "" }}" in
    darwin:*) brew install mise ;;
    linux:arch) paru -S --needed --noconfirm mise ;;
    linux:ubuntu | linux:debian)
        download_installer https://mise.run mise-install
        ;;
    *) die "cannot install mise on this platform" ;;
    esac
    export PATH="$HOME/.local/bin:$PATH"
    require_command mise
}

install_language_runtimes() {
    local runtime runtime_name
    for runtime in "$@"; do
        mise use -g "$runtime"
        runtime_name=${runtime%@*}
        case "$runtime_name" in
        node)
            require_command node
            require_command npm
            ;;
        rust)
            require_command rustc
            require_command cargo
            ;;
        *) require_command "$runtime_name" ;;
        esac
    done
}
{{ end -}}
