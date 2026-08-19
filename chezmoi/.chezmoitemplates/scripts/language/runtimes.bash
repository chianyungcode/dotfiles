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
ensure_proto() {
    command -v proto >/dev/null 2>&1 && return 0
    make_temp_dir "proto-install"
    local installer="$TEMP_DIR/proto-install.sh"
    curl --fail --show-error --silent --location --retry 3 \
        https://moonrepo.dev/install/proto.sh --output "$installer"
    /bin/bash "$installer" --yes --no-profile
    export PATH="$PROTO_HOME/bin:$PROTO_HOME/shims:$HOME/.local/bin:$PATH"
    require_command proto
}

install_taplo() {
    local version=$1
    # Proto has no Taplo plugin, so keep this one runtime on Cargo.
    command -v taplo >/dev/null 2>&1 && return 0
    require_command cargo
    if [[ "$version" == latest ]]; then
        cargo install taplo-cli --locked
    else
        cargo install taplo-cli --version "$version" --locked
    fi
}

install_language_runtimes() {
    local runtime runtime_name runtime_version
    for runtime in "$@"; do
        runtime_name=${runtime%@*}
        runtime_version=${runtime#*@}
        if [[ "$runtime_name" == taplo ]]; then
            install_taplo "$runtime_version"
        else
            case "$runtime_name" in
            node)
                # Proto does not install Node's bundled npm by default.
                proto install "$runtime_name" "$runtime_version" --pin global \
                    -- --bundled-npm
                command -v npm >/dev/null 2>&1 ||
                    proto install npm latest --pin global
                ;;
            *)
                proto install "$runtime_name" "$runtime_version" --pin global
                ;;
            esac
        fi
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
