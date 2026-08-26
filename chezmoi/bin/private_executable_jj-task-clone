#!/usr/bin/env bash

set -euo pipefail

# Dependencies
for cmd in jj gum; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Error: '${cmd}' is required but not installed." >&2
    exit 1
  fi
done

die() {
  gum style --foreground 1 "$*" >&2
  exit 1
}

# Input
remote="$(
  gum input \
    --header "Repository" \
    --placeholder "ghcny:chianyungcode/dotfiles.git"
)"

[[ -n "${remote}" ]] || die "Repository URL cannot be empty."

suffix="$(
  gum input \
    --header "Feature / Task" \
    --placeholder "feat-auth"
)"

[[ -n "${suffix}" ]] || die "Feature / task name cannot be empty."

# Resolve repository name
source_name="${remote%%\?*}"
source_name="${source_name%%#*}"
source_name="${source_name%/}"

repo_name="${source_name##*/}"
repo_name="${repo_name%.git}"

[[ "${repo_name}" =~ ^[[:alnum:]][[:alnum:]_.-]*$ ]] ||
  die "Cannot derive a safe repository name from '${remote}'."

[[ "${suffix}" =~ ^[[:alnum:]][[:alnum:]_.-]*$ ]] ||
  die "Feature/task name may only contain letters, numbers, '.', '_' and '-'."

target="${repo_name}.${suffix}"

if [[ -e "${target}" || -L "${target}" ]]; then
  die "Directory '${target}' already exists."
fi

# Confirmation
gum style \
  --border rounded \
  --padding "1 2" \
  "Repository : ${remote}" \
  "Directory  : ${target}" \
  "Bookmark   : ${suffix}"

gum confirm "Create this workspace?" || {
  gum style "Cancelled."
  exit 0
}

# Clone a separate colocated repository so .git is available
gum spin \
  --spinner dot \
  --title "Cloning ${repo_name}..." \
  -- \
  jj git clone --colocate "${remote}" "${target}"

cd -- "${target}"

jj bookmark create --revision @ "${suffix}"

gum style \
  --foreground 2 \
  --bold \
  "✓ Workspace created"

gum style \
  "Directory : ${target}" \
  "Bookmark  : ${suffix}"
