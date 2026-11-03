#!/usr/bin/env bash

# Fail fast when a package list names something the package manager cannot
# install. A typo here otherwise surfaces only after a long `chezmoi apply`.
#
# Checks every Homebrew and APT entry regardless of feature flags:
#   - Homebrew core formulae and casks against the formulae.brew.sh API.
#   - Tap entries (owner/tap/name) against the tap's GitHub repository.
#   - APT packages against the local apt cache (skipped without apt-cache).

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi curl gh jq rg; do
	command -v "$command_name" >/dev/null || {
		printf 'missing required command: %s\n' "$command_name" >&2
		exit 1
	}
done

config_file="$tmp_dir/chezmoi.toml"
data_file="$tmp_dir/data.json"
chezmoi -S "$source_dir" -c "$tmp_dir/missing.toml" execute-template --init \
	--file "$source_dir/.chezmoi.toml.tmpl" >"$config_file"
chezmoi -S "$source_dir" -c "$config_file" data --format json >"$data_file"

failed=0

report_missing() {
	local label=$1
	local wanted=$2
	local available=$3
	local missing
	missing=$(comm -23 "$wanted" "$available")
	[[ -z "$missing" ]] && return 0
	printf '%s not found:\n' "$label" >&2
	printf '%s\n' "$missing" | sed 's/^/  - /' >&2
	failed=1
}

brew_entries() {
	local kind=$1
	jq -r --arg kind "$kind" \
		'.packages.homebrew | del(.to_remove) | .[] | .[$kind][]?' \
		"$data_file" | sort -u
}

brew_entries formulae | rg -v / >"$tmp_dir/formulae" || true
brew_entries casks | rg -v / >"$tmp_dir/casks" || true

curl -fsSL --retry 3 https://formulae.brew.sh/api/formula.json |
	jq -r '.[] | .name, .aliases[]?, .oldnames[]?, (.oldname // empty)' |
	sort -u >"$tmp_dir/available-formulae"
curl -fsSL --retry 3 https://formulae.brew.sh/api/cask.json |
	jq -r '.[] | .token, .old_tokens[]?' |
	sort -u >"$tmp_dir/available-casks"

report_missing 'Homebrew formulae' "$tmp_dir/formulae" "$tmp_dir/available-formulae"
report_missing 'Homebrew casks' "$tmp_dir/casks" "$tmp_dir/available-casks"

# Tap entries resolve to github.com/<owner>/homebrew-<tap>, containing
# <name>.rb anywhere in the tree (Formula/, Formula/x/, Casks/, root, ...).
{
	brew_entries formulae
	brew_entries casks
} | rg / | sort -u | while IFS=/ read -r owner tap name; do
	if ! gh api "repos/$owner/homebrew-$tap/git/trees/HEAD?recursive=1" \
		--jq '.tree[].path' 2>/dev/null |
		rg -q "(^|/)$name\\.rb\$"; then
		printf '%s/%s/%s\n' "$owner" "$tap" "$name"
	fi
done >"$tmp_dir/missing-taps"
if [[ -s "$tmp_dir/missing-taps" ]]; then
	printf 'Homebrew tap entries not found:\n' >&2
	sed 's/^/  - /' "$tmp_dir/missing-taps" >&2
	failed=1
fi

if command -v apt-cache >/dev/null; then
	jq -r '.packages.apt | del(.to_remove) | .[] | .packages[]?' "$data_file" |
		sort -u >"$tmp_dir/apt"
	while read -r package; do
		apt-cache show "$package" >/dev/null 2>&1 || printf '%s\n' "$package"
	done <"$tmp_dir/apt" >"$tmp_dir/missing-apt"
	if [[ -s "$tmp_dir/missing-apt" ]]; then
		printf 'APT packages not found:\n' >&2
		sed 's/^/  - /' "$tmp_dir/missing-apt" >&2
		failed=1
	fi
else
	printf 'apt-cache not found; skipping APT package check\n'
fi

[[ "$failed" -eq 0 ]] || exit 1
printf 'package names resolved\n'
