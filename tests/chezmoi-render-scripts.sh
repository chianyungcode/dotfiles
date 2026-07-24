#!/usr/bin/env bash

set -euo pipefail

fail() {
	printf '%s\n' "$1" >&2
	exit 1
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in bash chezmoi jq rg shellcheck shfmt; do
	command -v "$command_name" >/dev/null ||
		{
			printf 'missing command: %s\n' "$command_name" >&2
			exit 1
		}
done

base_data_file="$tmp_dir/base.json"
chezmoi -S "$source_dir" data >"$base_data_file"

[[ -f "$source_dir/.chezmoidata/packages-system.toml" ]] ||
	fail "packages-system.toml is missing"
[[ -f "$source_dir/.chezmoidata/packages-language.toml" ]] ||
	fail "packages-language.toml is missing"
[[ ! -e "$source_dir/.chezmoidata/packages.toml" ]] ||
	fail "legacy packages.toml still exists"

jq -e '
    .packages
    | has("homebrew")
      and has("mas")
      and has("apt")
      and has("pacman")
      and has("python")
      and has("cargo")
      and has("node")
' "$base_data_file" >/dev/null

jq -e '
    [.runtimes[] | {name, version, features}]
    == [
      {name:"node", version:"latest", features:["development","personal"]},
      {name:"go", version:"latest", features:["development"]},
      {name:"rust", version:"latest", features:["development","personal"]},
      {name:"bun", version:"latest", features:["development"]},
      {name:"deno", version:"latest", features:["development"]},
      {name:"taplo", version:"latest", features:["development"]}
    ]
' "$base_data_file" >/dev/null

printf 'chezmoi script render tests passed\n'
