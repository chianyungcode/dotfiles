#!/usr/bin/env bash

set -euo pipefail

fail() {
    printf '%s\n' "$1" >&2
    exit 1
}

repo_root=$(cd "$(dirname "$0")/.." && pwd)
skim_source="$repo_root/chezmoi/dot_config/zsh/conf.d/third-party/99_skim.sh"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

command -v zsh >/dev/null || fail 'missing required command: zsh'

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/fd" <<'STUB'
#!/usr/bin/env bash
printf 'candidate\n'
STUB
chmod +x "$stub_bin/fd"

cat >"$stub_bin/sk" <<'STUB'
#!/usr/bin/env bash
exit 130
STUB
chmod +x "$stub_bin/sk"

actual=$(
    PATH="$stub_bin:$PATH" \
        zsh -f -c '
            zle() { :; }
            bindkey() { :; }
            source "$1"
            LBUFFER=""
            skim-ctrl-t-widget
            print -r -- "$LBUFFER"
        ' zsh "$skim_source"
)

[[ -z "$actual" ]] || fail "cancelled skim inserted: $(printf '%q' "$actual")"

printf 'zsh skim cancellation test passed\n'
