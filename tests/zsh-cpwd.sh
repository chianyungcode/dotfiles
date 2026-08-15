#!/usr/bin/env bash

set -euo pipefail

fail() {
	printf '%s\n' "$1" >&2
	exit 1
}

repo_root=$(cd "$(dirname "$0")/.." && pwd)
source_dir="$repo_root/chezmoi"
aliases_source="$source_dir/dot_config/zsh/conf.d/060-common-aliases.sh.tmpl"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi fish rg zsh; do
	command -v "$command_name" >/dev/null ||
		fail "missing required command: $command_name"
done

rg -Fq 'function cpwd()' "$aliases_source" ||
	fail 'common Zsh aliases template must define cpwd as a function'
if rg -n -F 'alias cpwd' "$aliases_source"; then
	fail 'common Zsh aliases template still defines cpwd as an alias'
fi

rendered="$tmp_dir/common-aliases.zsh"
chezmoi -S "$source_dir" execute-template --file "$aliases_source" >"$rendered"
zsh -n "$rendered"

if ! rg -q '^function cpwd\(\) \{$' "$rendered"; then
	printf 'cpwd branch is inactive on this platform; source checks passed\n'
	exit 0
fi

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin" "$tmp_dir/start" "$tmp_dir/expected"
cat >"$stub_bin/pbcopy" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
cat >"$CPWD_TEST_OUTPUT"
STUB
chmod +x "$stub_bin/pbcopy"

expected_output="$tmp_dir/expected-output"
actual_output="$tmp_dir/actual-output"
printf '%s' "$tmp_dir/expected" >"$expected_output"
CPWD_TEST_OUTPUT="$actual_output" PATH="$stub_bin:$PATH" \
	zsh -f -c "source '$rendered'; cd '$tmp_dir/start'; cd '$tmp_dir/expected'; cpwd"
cmp -s "$expected_output" "$actual_output" ||
	fail 'cpwd did not copy the directory active at invocation time'

printf 'zsh cpwd tests passed\n'
