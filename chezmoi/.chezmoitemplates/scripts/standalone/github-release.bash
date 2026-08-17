github_api() {
    local url=$1
    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        curl --fail --show-error --silent --location --retry 3 \
            -H "Authorization: Bearer $GITHUB_TOKEN" "$url"
    else
        curl --fail --show-error --silent --location --retry 3 "$url"
    fi
}

github_arch_regex() {
    # shellcheck disable=SC2194 # chezmoi renders the architecture as a literal.
    case "{{ .chezmoi.arch }}" in
    amd64) printf '%s' '(x86_64|amd64|x64)' ;;
    arm64) printf '%s' '(aarch64|arm64)' ;;
    *) die "unsupported release architecture: {{ .chezmoi.arch }}" ;;
    esac
}

select_release_asset() {
    local release_json=$1
    local exclude_regex=$2
    local arch_regex
    arch_regex=$(github_arch_regex)
    jq -r --arg arch "$arch_regex" --arg exclude "$exclude_regex" '
        .assets[]
        | select(.name | test("linux"; "i"))
        | select(.name | test($arch; "i"))
        | select(.name | test("\\.(tar\\.gz|tgz|zip)$"; "i"))
        | select(($exclude == "") or (.name | test($exclude; "i") | not))
        | .browser_download_url
    ' "$release_json" | head -n 1
}

select_checksum_asset() {
    local release_json=$1
    local archive_name=$2
    jq -r --arg archive "$archive_name" '
        .assets[]
        | select(
            (.name | test(
                "^(sha256sums|sha256sums\\.txt|checksums|checksums\\.txt)$";
                "i"
            ))
            or ((.name | ascii_downcase) == (($archive | ascii_downcase) + ".sha256"))
        )
        | .browser_download_url
    ' "$release_json" | head -n 1
}

verify_archive_checksum() {
    local work_dir=$1
    local archive_name=$2
    local checksum_file=$3
    local checksum_entry="$work_dir/checksum-entry"

    grep -E "[[:space:]*]${archive_name}$" "$checksum_file" \
        >"$checksum_entry" ||
        die "checksum file has no entry for $archive_name"

    if command -v sha256sum >/dev/null 2>&1; then
        (
            cd "$work_dir"
            sha256sum -c "${checksum_entry##*/}"
        )
    else
        require_command shasum
        (
            cd "$work_dir"
            shasum -a 256 -c "${checksum_entry##*/}"
        )
    fi
}

verify_sha256_digest() {
    local file=$1
    local expected_digest=$2
    local actual_digest

    [[ "$expected_digest" =~ ^[[:xdigit:]]{64}$ ]] ||
        die "invalid SHA-256 digest for ${file##*/}"

    if command -v sha256sum >/dev/null 2>&1; then
        actual_digest=$(sha256sum "$file" | awk '{print $1}')
    else
        require_command shasum
        actual_digest=$(shasum -a 256 "$file" | awk '{print $1}')
    fi

    [[ "$actual_digest" == "$expected_digest" ]] ||
        die "SHA-256 digest mismatch for ${file##*/}"
}

extract_release_archive() {
    local archive=$1
    local destination=$2
    case "$archive" in
    *.zip)
        require_command unzip
        unzip -q "$archive" -d "$destination"
        ;;
    *.tar.gz | *.tgz)
        require_command tar
        tar -xzf "$archive" -C "$destination"
        ;;
    *)
        die "unsupported release archive: ${archive##*/}"
        ;;
    esac
}

install_github_release() {
    local name=$1
    local repository=$2
    local executable=$3
    local exclude_regex=$4

    if command -v "$executable" >/dev/null 2>&1 &&
        "$executable" --version >/dev/null 2>&1; then
        return 0
    fi
    require_command curl
    require_command jq
    make_temp_dir "github-release"

    local work_dir="$TEMP_DIR/$name"
    local release_json="$work_dir/release.json"
    local extract_dir="$work_dir/extracted"
    mkdir -p "$work_dir" "$extract_dir"

    github_api \
        "https://api.github.com/repos/$repository/releases/latest" \
        >"$release_json"

    jq -e '.draft == false and .prerelease == false' "$release_json" \
        >/dev/null ||
        die "latest $repository release is draft or prerelease"

    local asset_url
    asset_url=$(select_release_asset "$release_json" "$exclude_regex")
    [[ -n "$asset_url" && "$asset_url" != null ]] ||
        die "release asset not found for $name"

    local archive="$work_dir/${asset_url##*/}"
    curl --fail --show-error --silent --location --retry 3 \
        "$asset_url" --output "$archive"

    local checksum_url
    checksum_url=$(select_checksum_asset "$release_json" "${archive##*/}")
    if [[ -n "$checksum_url" && "$checksum_url" != null ]]; then
        local checksum_file="$work_dir/${checksum_url##*/}"
        curl --fail --show-error --silent --location --retry 3 \
            "$checksum_url" --output "$checksum_file"
        verify_archive_checksum "$work_dir" "${archive##*/}" "$checksum_file"
    else
        die "$name release does not publish a recognized checksum asset"
    fi

    extract_release_archive "$archive" "$extract_dir"

    local matches match_count source_executable
    matches=$(find "$extract_dir" -type f -name "$executable")
    match_count=$(printf '%s\n' "$matches" |
        awk 'NF { count++ } END { print count + 0 }')
    [[ "$match_count" -eq 1 ]] ||
        die "expected one $executable in release, found $match_count"
    source_executable=$(printf '%s\n' "$matches" | head -n 1)

    local install_dir="$HOME/.local/bin"
    local temporary_target="$install_dir/.$executable.$$"
    local target="$install_dir/$executable"
    mkdir -p "$install_dir"
    cp "$source_executable" "$temporary_target"
    chmod 0755 "$temporary_target"
    if ! "$temporary_target" --version >/dev/null 2>&1; then
        rm -f -- "$temporary_target"
        die "$name executable failed staged verification"
    fi
    mv "$temporary_target" "$target"
}
{{- if and (eq .chezmoi.os "linux") .features.development (eq .chezmoi.arch "amd64") (or (eq .chezmoi.osRelease.id "ubuntu") (eq .chezmoi.osRelease.id "debian")) }}

install_git_credential_manager() {
    git credential-manager --version >/dev/null 2>&1 && return 0
    require_command dpkg
    make_temp_dir "git-credential-manager"
    local release_json="$TEMP_DIR/gcm-release.json"
    github_api \
        https://api.github.com/repos/git-ecosystem/git-credential-manager/releases/latest \
        >"$release_json"
    local deb_asset deb_url deb_digest
    deb_asset=$(jq -r '
        .assets[]
        | select(.name | test("linux.*(amd64|x64).*\\.deb$"; "i"))
        | [.browser_download_url, (.digest // "")]
        | @tsv
    ' "$release_json" | head -n 1)
    [[ -n "$deb_asset" && "$deb_asset" != null ]] ||
        die "GCM amd64 Debian asset not found"
    IFS=$'\t' read -r deb_url deb_digest <<<"$deb_asset"
    [[ -n "$deb_url" && "$deb_url" != null ]] ||
        die "GCM amd64 Debian asset URL is missing"
    [[ "$deb_digest" =~ ^sha256:[[:xdigit:]]{64}$ ]] ||
        die "GCM amd64 Debian asset has an invalid SHA-256 digest"

    local deb_file="$TEMP_DIR/${deb_url##*/}"
    curl --fail --show-error --silent --location --retry 3 \
        "$deb_url" --output "$deb_file"
    verify_sha256_digest "$deb_file" "${deb_digest#sha256:}"
    sudo dpkg -i "$deb_file"
    git credential-manager --version >/dev/null
}
{{- end }}
