# Chezmoi Scripts Refactor Implementation Plan

<!-- markdownlint-disable MD013 -->

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace 21 loosely coordinated Chezmoi scripts with eight tested,
phase-oriented Bash entrypoints that are fail-fast, retry-safe, and free of
unnecessary network checks during unchanged applies.

**Architecture:** `.chezmoidata` owns package/runtime declarations,
`.chezmoitemplates/scripts` owns focused Bash implementation fragments, and
`.chezmoiscripts` owns execution phase and ordering. Each phase renders only
the active platform branch; a minimal Bash 3.2-compatible core supplies strict
mode, logging, error reporting, and temporary-directory cleanup.

**Tech Stack:** Chezmoi v2 templates, Bash 3.2+, TOML, jq, ShellCheck, shfmt,
Taplo, Jujutsu.

## Global Constraints

- Keep Bash and native Chezmoi as the only orchestration mechanisms.
- Leave exactly eight executable phase entrypoints in `.chezmoiscripts`.
- Use Bash 3.2 as the compatibility floor; do not use associative arrays,
  `mapfile`, or Bash 4-only parameter expansions.
- Use `set -Eeuo pipefail`; the first failed configured operation stops the
  phase and `chezmoi apply`.
- Make every install operation idempotent and safe after partial completion.
- Do not query release APIs during an unchanged regular apply.
- Do not add implicit Homebrew, APT, npm, Cargo, or system-wide upgrades.
- Do not introduce real package installation, network access, or real
  1Password credentials in tests.
- Prefer package managers; do not execute a remote installer through
  `curl | sh`.
- Preserve current package membership except for explicit runtime declarations,
  moving Eza into APT handling, and adding Atuin to standalone binary data.
- Keep private SSH key content out of log output and write it with `umask 077`.
- Use Jujutsu commits (`jj commit`) rather than Git staging commands.

---

## Target File Structure

Files created:

```text
chezmoi/.chezmoidata/packages-system.toml
chezmoi/.chezmoidata/packages-language.toml
chezmoi/.chezmoitemplates/scripts/core.bash
chezmoi/.chezmoitemplates/scripts/system/homebrew.bash
chezmoi/.chezmoitemplates/scripts/system/apt.bash
chezmoi/.chezmoitemplates/scripts/system/paru.bash
chezmoi/.chezmoitemplates/scripts/language/runtimes.bash
chezmoi/.chezmoitemplates/scripts/language/packages.bash
chezmoi/.chezmoitemplates/scripts/standalone/github-release.bash
chezmoi/.chezmoiscripts/run_before_00-bootstrap.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_20-language-runtimes.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_30-language-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_40-standalone-tools.sh.tmpl
chezmoi/.chezmoiscripts/run_after_50-post-install.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_60-security-material.sh.tmpl
chezmoi/.chezmoiscripts/run_once_after_90-monthly-maintenance.sh.tmpl
tests/chezmoi-render-scripts.sh
tests/chezmoi-script-behavior.sh
```

Files removed after their replacements pass:

```text
chezmoi/.chezmoidata/packages.toml
chezmoi/.chezmoitemplates/shared_script_utils.bash
chezmoi/.chezmoiscripts/run_after_30-instal-atuin.sh.tmpl
chezmoi/.chezmoiscripts/run_after_30-install-eza.sh.tmpl
chezmoi/.chezmoiscripts/run_after_30-install-git-credential-manager.sh.tmpl
chezmoi/.chezmoiscripts/run_after_30-install-non-pkg-manager-binaries.sh.tmpl
chezmoi/.chezmoiscripts/run_after_40-install-nanorc.sh.tmpl
chezmoi/.chezmoiscripts/run_after_40-symlink-batcat.sh.tmpl
chezmoi/.chezmoiscripts/run_after_40-symlink-fd.sh.tmpl
chezmoi/.chezmoiscripts/run_before_00-install-pre-requisites.sh.tmpl
chezmoi/.chezmoiscripts/run_before_02-install-uv.sh.tmpl
chezmoi/.chezmoiscripts/run_once_after_60-install-language-version-manager.sh.tmpl
chezmoi/.chezmoiscripts/run_once_after_99-updates-monthly.sh.tmpl
chezmoi/.chezmoiscripts/run_once_before_20-install-antidote.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_10-remove-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_15-create-ssh-keys.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_20-cargo-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_20-node-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_after_20-python-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_before-10-paru-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_before_10-apt-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_before_10-homebrew-packages.sh.tmpl
chezmoi/.chezmoiscripts/run_onchange_before_10-mas-applications.sh.tmpl
```

Files modified:

```text
README.md
docs/01-remote-server-flow.md
docs/02-homebrew-packages-flow.md
docs/03-shell-scripting-chezmoi.md
docs/security-review.md
tests/chezmoi-render-config.sh
```

## Shared Test Conventions

Both new test scripts use a private temporary directory and override Chezmoi's
built-in platform data. Use this exact profile helper in
`tests/chezmoi-render-scripts.sh`:

```bash
make_profile() {
    local output_file=$1
    local os=$2
    local distribution=$3
    local architecture=$4
    local development=$5
    local personal=$6
    local homelab=$7
    local graphical=$8

    jq \
        --arg os "$os" \
        --arg distribution "$distribution" \
        --arg architecture "$architecture" \
        --argjson development "$development" \
        --argjson personal "$personal" \
        --argjson homelab "$homelab" \
        --argjson graphical "$graphical" \
        '.chezmoi.os = $os
         | .chezmoi.osRelease.id = $distribution
         | .chezmoi.arch = $architecture
         | .features = {
             development: $development,
             personal: $personal,
             homelab: $homelab,
             graphical: $graphical
           }
         | .secrets.provider = "none"
         | .encrypted_files.enabled = false' \
        "$base_data_file" >"$output_file"
}
```

Use these assertion helpers:

```bash
fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_contains() {
    local file=$1
    local pattern=$2
    rg -q "$pattern" "$file" ||
        fail "$file does not contain pattern: $pattern"
}

assert_not_contains() {
    local file=$1
    local pattern=$2
    if rg -q "$pattern" "$file"; then
        fail "$file unexpectedly contains pattern: $pattern"
    fi
}

render_script() {
    local profile=$1
    local source_script=$2
    local output_file=$3
    chezmoi -S "$source_dir" execute-template \
        --override-data-file "$profile" \
        --file "$source_script" >"$output_file"
}

render_script_ci() {
    local profile=$1
    local source_script=$2
    local output_file=$3
    CI=1 chezmoi -S "$source_dir" execute-template \
        --override-data-file "$profile" \
        --file "$source_script" >"$output_file"
}

check_rendered_script() {
    local script=$1
    [[ ! -s "$script" ]] && return 0
    head -n 1 "$script" | rg -q '^#!/usr/bin/env bash$' ||
        fail "$script has no Bash shebang"
    bash -n "$script"
    shfmt -d -i 4 "$script"
    shellcheck -S warning "$script"
}
```

---

### Task 1: Establish the Minimal Shell Core

**Files:**

- Create: `chezmoi/.chezmoitemplates/scripts/core.bash`
- Create: `tests/chezmoi-script-behavior.sh`

**Interfaces:**

- Consumes: `PHASE` set by each entrypoint before including the core template.
- Produces: `info(message)`, `notice(message)`, `die(message)`,
  `require_command(name)`, `make_temp_dir(prefix)`, and global `TEMP_DIR`.

- [ ] **Step 1: Verify the existing configuration baseline**

Run:

```bash
./tests/chezmoi-render-config.sh
```

Expected:

```text
chezmoi render matrix passed
```

The secretless/Age failure recorded during design exploration has already been
resolved in the current baseline. If this command fails, stop and diagnose the
new baseline before editing script code.

- [ ] **Step 2: Write the failing core behavior test**

Create `tests/chezmoi-script-behavior.sh` with a fixture generator that renders
the core template into a temporary executable:

```bash
#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi rg; do
    command -v "$command_name" >/dev/null ||
        { printf 'missing command: %s\n' "$command_name" >&2; exit 1; }
done

core_fixture="$tmp_dir/core-fixture.sh"
{
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'PHASE="core-test"'
    chezmoi -S "$source_dir" execute-template \
        --file "$source_dir/.chezmoitemplates/scripts/core.bash"
    printf '%s\n' 'make_temp_dir "core-test"'
    printf '%s\n' 'printf "%s" "$TEMP_DIR" >"$TEMP_RECORD"'
    printf '%s\n' '[[ "${FAIL_FIXTURE:-false}" == true ]] && false'
    printf '%s\n' 'info "fixture complete"'
} >"$core_fixture"
chmod +x "$core_fixture"

success_record="$tmp_dir/success-temp"
success_output=$(TEMP_RECORD="$success_record" "$core_fixture")
rg -q '\[core-test\] fixture complete' <<<"$success_output"
success_temp=$(<"$success_record")
[[ ! -d "$success_temp" ]]

failure_record="$tmp_dir/failure-temp"
set +e
failure_output=$(
    TEMP_RECORD="$failure_record" FAIL_FIXTURE=true "$core_fixture" 2>&1
)
failure_status=$?
set -e
[[ $failure_status -ne 0 ]]
rg -q '\[core-test\] ERROR line [0-9]+: false \(status [0-9]+\)' \
    <<<"$failure_output"
failure_temp=$(<"$failure_record")
[[ ! -d "$failure_temp" ]]

printf 'chezmoi script behavior tests passed\n'
```

- [ ] **Step 3: Run the test and verify it fails**

Run:

```bash
./tests/chezmoi-script-behavior.sh
```

Expected: FAIL because
`.chezmoitemplates/scripts/core.bash` does not exist.

- [ ] **Step 4: Implement the minimal Bash 3.2-compatible core**

Create `chezmoi/.chezmoitemplates/scripts/core.bash`:

```bash
set -Eeuo pipefail

: "${PHASE:?PHASE must be set before loading scripts/core.bash}"

TEMP_DIR=""

info() {
    printf '[%s] %s\n' "$PHASE" "$*"
}

notice() {
    printf '[%s] NOTICE: %s\n' "$PHASE" "$*"
}

die() {
    printf '[%s] ERROR: %s\n' "$PHASE" "$*" >&2
    exit 1
}

require_command() {
    command -v "$1" >/dev/null 2>&1 ||
        die "required command not found: $1"
}

make_temp_dir() {
    local prefix=${1:-chezmoi-script}
    [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] && return 0
    TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXX") ||
        die "could not create temporary directory"
    chmod 700 "$TEMP_DIR"
}

cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf -- "$TEMP_DIR"
    fi
}

report_error() {
    local status=$1
    local line=$2
    local command=$3
    trap - ERR
    printf '[%s] ERROR line %s: %s (status %s)\n' \
        "$PHASE" "$line" "$command" "$status" >&2
    return "$status"
}

trap cleanup EXIT
trap 'report_error "$?" "$LINENO" "$BASH_COMMAND"' ERR
```

- [ ] **Step 5: Format and run the focused test**

Run:

```bash
shfmt -w -i 4 chezmoi/.chezmoitemplates/scripts/core.bash \
    tests/chezmoi-script-behavior.sh
./tests/chezmoi-script-behavior.sh
shellcheck tests/chezmoi-script-behavior.sh
```

Expected:

```text
chezmoi script behavior tests passed
```

ShellCheck exits 0.

- [ ] **Step 6: Commit**

```bash
jj commit -m "refactor(chezmoi): add minimal script core"
```

---

### Task 2: Split Package Data and Declare Runtimes

**Files:**

- Create: `chezmoi/.chezmoidata/packages-system.toml`
- Create: `chezmoi/.chezmoidata/packages-language.toml`
- Delete: `chezmoi/.chezmoidata/packages.toml`
- Create: `tests/chezmoi-render-scripts.sh`

**Interfaces:**

- Consumes: Existing package tables in `packages.toml`.
- Produces: Unchanged `packages.homebrew`, `packages.mas`, `packages.apt`,
  `packages.pacman`, `packages.python`, `packages.cargo`, and `packages.node`
  data plus `runtimes[]` records with `name`, `version`, and `features`.

- [ ] **Step 1: Write the failing data ownership test**

Create the setup and helpers from **Shared Test Conventions** in
`tests/chezmoi-render-scripts.sh`, then add:

```bash
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in bash chezmoi jq rg shellcheck shfmt; do
    command -v "$command_name" >/dev/null ||
        { printf 'missing command: %s\n' "$command_name" >&2; exit 1; }
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
```

Before changing the data files, capture the package dictionary for the
equivalence check:

```bash
chezmoi -S chezmoi data |
    jq -S '.packages' >/tmp/chezmoi-script-refactor-packages-before.json
```

- [ ] **Step 2: Run the test and verify it fails**

Run:

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL with `packages-system.toml is missing`.

- [ ] **Step 3: Perform the mechanical data split**

Move original lines 1-665, including the root `[packages]` header, unchanged
into `packages-system.toml`.

Create `packages-language.toml` with a new root `[packages]` header followed by
original lines 667-769 unchanged. Append these runtime records after the
package tables:

```toml
[[runtimes]]
  name     = "node"
  version  = "latest"
  features = ["development", "personal"]

[[runtimes]]
  name     = "go"
  version  = "latest"
  features = ["development"]

[[runtimes]]
  name     = "rust"
  version  = "latest"
  features = ["development", "personal"]

[[runtimes]]
  name     = "bun"
  version  = "latest"
  features = ["development"]

[[runtimes]]
  name     = "deno"
  version  = "latest"
  features = ["development"]

[[runtimes]]
  name     = "taplo"
  version  = "latest"
  features = ["development"]
```

Delete `packages.toml`. Do not reformat or reorder package membership during
the split.

- [ ] **Step 4: Verify package membership did not change**

Render the parent revision and working-copy data:

```bash
chezmoi -S chezmoi data |
    jq -S '.packages' >/tmp/chezmoi-script-refactor-packages-after.json
diff -u \
    /tmp/chezmoi-script-refactor-packages-before.json \
    /tmp/chezmoi-script-refactor-packages-after.json
```

Expected: `diff` exits 0 with no output.

- [ ] **Step 5: Validate TOML and run tests**

```bash
taplo check chezmoi/.chezmoidata/packages-system.toml \
    chezmoi/.chezmoidata/packages-language.toml
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
```

Expected: both test scripts print their `passed` messages.

- [ ] **Step 6: Commit**

```bash
jj commit -m "refactor(chezmoi): split package data"
```

---

### Task 3: Replace Bootstrap with Phase 00

**Files:**

- Create: `chezmoi/.chezmoiscripts/run_before_00-bootstrap.sh.tmpl`
- Modify: `tests/chezmoi-render-scripts.sh`
- Modify: `tests/chezmoi-script-behavior.sh`

**Interfaces:**

- Consumes: `scripts/core.bash`, `.chezmoi.os`, `.chezmoi.osRelease.id`.
- Produces: Homebrew on macOS, APT bootstrap commands on Ubuntu/Debian, and
  Pacman plus Paru bootstrap commands on Arch.

- [ ] **Step 1: Add failing render assertions**

Create macOS, Ubuntu, and Arch profiles with `make_profile`, render phase 00,
and assert:

```bash
mac_data="$tmp_dir/mac.json"
ubuntu_data="$tmp_dir/ubuntu.json"
arch_data="$tmp_dir/arch.json"
make_profile "$mac_data" darwin darwin arm64 true true false true
make_profile "$ubuntu_data" linux ubuntu amd64 true false false false
make_profile "$arch_data" linux arch amd64 true true false true

bootstrap_source="$source_dir/.chezmoiscripts/run_before_00-bootstrap.sh.tmpl"
for profile in mac ubuntu arch; do
    render_script "$tmp_dir/$profile.json" "$bootstrap_source" \
        "$tmp_dir/$profile-bootstrap.sh"
    check_rendered_script "$tmp_dir/$profile-bootstrap.sh"
done

assert_contains "$tmp_dir/mac-bootstrap.sh" 'Installing Homebrew'
assert_not_contains "$tmp_dir/mac-bootstrap.sh" 'paru'
assert_contains "$tmp_dir/ubuntu-bootstrap.sh" 'apt-get install'
assert_not_contains "$tmp_dir/ubuntu-bootstrap.sh" 'pacman'
assert_contains "$tmp_dir/arch-bootstrap.sh" 'command -v paru'
assert_contains "$tmp_dir/arch-bootstrap.sh" 'makepkg -si'
assert_not_contains "$tmp_dir/arch-bootstrap.sh" 'apt-get'
```

- [ ] **Step 2: Run render tests and verify failure**

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL because `run_before_00-bootstrap.sh.tmpl` is missing.

- [ ] **Step 3: Implement phase 00**

Create the entrypoint with this structure:

```gotemplate
#!/usr/bin/env bash

PHASE="00-bootstrap"
{{ template "scripts/core.bash" . }}

{{ if eq .chezmoi.os "darwin" -}}
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew"
    make_temp_dir "homebrew-install"
    installer="$TEMP_DIR/install.sh"
    curl --fail --show-error --silent --location --retry 3 \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
        --output "$installer"
    /bin/bash "$installer"
fi

if [[ -x /opt/homebrew/bin/brew ]] &&
    ! command -v brew >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
{{ else if eq .chezmoi.os "linux" -}}
missing_commands=()
for command_name in curl unzip wget; do
    command -v "$command_name" >/dev/null 2>&1 ||
        missing_commands+=("$command_name")
done

{{ if or (eq .chezmoi.osRelease.id "ubuntu") (eq .chezmoi.osRelease.id "debian") -}}
if [[ ${#missing_commands[@]} -gt 0 ]]; then
    sudo apt-get update
    sudo apt-get install -y "${missing_commands[@]}"
fi
{{ else if eq .chezmoi.osRelease.id "arch" -}}
if [[ ${#missing_commands[@]} -gt 0 ]]; then
    sudo pacman -Sy --noconfirm "${missing_commands[@]}"
fi

if ! command -v paru >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm git base-devel
    make_temp_dir "paru-build"
    git clone --depth 1 https://aur.archlinux.org/paru.git "$TEMP_DIR/paru"
    (
        cd "$TEMP_DIR/paru"
        makepkg -si --noconfirm
    )
    require_command paru
fi
{{ else -}}
die "unsupported Linux distribution: {{ .chezmoi.osRelease.id }}"
{{ end -}}
{{ end -}}

info "bootstrap prerequisites satisfied"
```

Do not append to `.zprofile`; PATH configuration remains owned by managed shell
files.

- [ ] **Step 4: Add the Paru regression test**

In `tests/chezmoi-script-behavior.sh`, render the Arch phase with a fake PATH
where `curl`, `unzip`, and `wget` exist but `paru` does not. Fake `sudo`,
`pacman`, `git`, and `makepkg` must append their command names to
`$COMMAND_LOG`; fake `makepkg` creates a fake `paru` executable in the fake
binary directory. Assert:

```bash
assert_log_contains 'pacman -S --needed --noconfirm git base-devel'
assert_log_contains 'git clone --depth 1 https://aur.archlinux.org/paru.git'
assert_log_contains 'makepkg -si --noconfirm'
```

This specifically proves Paru installation is not nested under the missing
prerequisite-command condition.

- [ ] **Step 5: Run focused validation**

```bash
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected: both scripts print their `passed` messages.

- [ ] **Step 6: Commit**

```bash
jj commit -m "refactor(chezmoi): add bootstrap phase"
```

---

### Task 4: Replace System Package Scripts with Phase 10

**Files:**

- Create: `chezmoi/.chezmoitemplates/scripts/system/homebrew.bash`
- Create: `chezmoi/.chezmoitemplates/scripts/system/apt.bash`
- Create: `chezmoi/.chezmoitemplates/scripts/system/paru.bash`
- Create:
  `chezmoi/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl`
- Modify: `tests/chezmoi-render-scripts.sh`
- Modify: `tests/chezmoi-script-behavior.sh`

**Interfaces:**

- Consumes: `packages.homebrew`, `packages.mas`, `packages.apt`,
  `packages.pacman`, `features.*`, and core logging/error functions.
- Produces: `install_homebrew_packages`, `install_apt_packages`, or
  `install_paru_packages`; exactly one is rendered per platform.

- [ ] **Step 1: Add failing platform-isolation tests**

Render phase 10 for all three profiles and add:

```bash
system_source="$source_dir/.chezmoiscripts/run_onchange_before_10-system-packages.sh.tmpl"
for profile in mac ubuntu arch; do
    render_script "$tmp_dir/$profile.json" "$system_source" \
        "$tmp_dir/$profile-system.sh"
    check_rendered_script "$tmp_dir/$profile-system.sh"
done

assert_contains "$tmp_dir/mac-system.sh" 'brew install'
assert_contains "$tmp_dir/mac-system.sh" 'mas install'
assert_not_contains "$tmp_dir/mac-system.sh" 'apt-get|paru'

assert_contains "$tmp_dir/ubuntu-system.sh" 'apt-get install'
assert_contains "$tmp_dir/ubuntu-system.sh" 'deb.gierens.de'
assert_not_contains "$tmp_dir/ubuntu-system.sh" 'brew|paru'

assert_contains "$tmp_dir/arch-system.sh" 'paru -S'
assert_not_contains "$tmp_dir/arch-system.sh" 'brew|apt-get'
```

- [ ] **Step 2: Run render tests and verify failure**

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL because the phase 10 entrypoint is missing.

- [ ] **Step 3: Implement the phase 10 entrypoint**

```gotemplate
#!/usr/bin/env bash

PHASE="10-system-packages"
{{ template "scripts/core.bash" . }}

{{ if eq .chezmoi.os "darwin" -}}
{{ template "scripts/system/homebrew.bash" . }}
install_homebrew_packages
{{ else if and (eq .chezmoi.os "linux") (or (eq .chezmoi.osRelease.id "ubuntu") (eq .chezmoi.osRelease.id "debian")) -}}
{{ template "scripts/system/apt.bash" . }}
install_apt_packages
{{ else if and (eq .chezmoi.os "linux") (eq .chezmoi.osRelease.id "arch") -}}
{{ template "scripts/system/paru.bash" . }}
install_paru_packages
{{ else -}}
die "unsupported package-manager platform"
{{ end -}}
```

- [ ] **Step 4: Implement the Homebrew adapter**

Render the arrays from the exact owning tables:

```gotemplate
remove_formulae=(
{{- range .packages.homebrew.to_remove }}
    "{{ . }}"
{{- end }}
)

formulae=(
{{- range .packages.homebrew.common.formulae }}
    "{{ . }}"
{{- end }}
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
{{- range .packages.homebrew.common.casks }}
    "{{ . }}"
{{- end }}
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
```

Render the application-name map as a complete `case`:

```gotemplate
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
```

Then implement:

```bash
install_homebrew_packages() {
    require_command brew
    export HOMEBREW_NO_INSTALL_UPGRADE=1
    export HOMEBREW_NO_INSTALL_CLEANUP=1
    export HOMEBREW_CASK_OPTS="--appdir=/Applications"

    brew update

    for package in "${remove_formulae[@]}"; do
        brew list --formula "$package" >/dev/null 2>&1 &&
            brew uninstall --formula "$package"
    done

    for formula in "${formulae[@]}"; do
        brew list --formula "$formula" >/dev/null 2>&1 ||
            brew install --formula "$formula"
    done

    if [[ -z "${CI:-}" ]]; then
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

        if command -v mas >/dev/null 2>&1; then
            for app_id in "${mas_apps[@]}"; do
                mas list | awk '{print $1}' | grep -Fxq "$app_id" ||
                    mas install "$app_id"
            done
        fi
    fi
}
```

- [ ] **Step 5: Implement the APT adapter**

Add `"eza"` to `packages.apt.common.packages` in
`packages-system.toml`. Render `remove_packages` from `packages.apt.to_remove`
and `packages` from common plus each enabled capability, using the same
`range`/feature pattern shown for Homebrew.

Use exact package queries:

```bash
apt_package_installed() {
    dpkg-query -W -f='${db:Status-Abbrev}' "$1" 2>/dev/null |
        grep -q '^ii '
}

apt_package_available() {
    apt-cache show "$1" >/dev/null 2>&1
}

ensure_eza_repository() {
    command -v eza >/dev/null 2>&1 && return 0
    sudo install -d -m 0755 /etc/apt/keyrings
    make_temp_dir "eza-repository"
    curl --fail --show-error --silent --location --retry 3 \
        https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        --output "$TEMP_DIR/eza.asc"
    gpg --dearmor <"$TEMP_DIR/eza.asc" |
        sudo tee /etc/apt/keyrings/gierens.gpg >/dev/null
    printf '%s\n' \
        'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' |
        sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
}

install_apt_packages() {
    require_command apt-get
    require_command dpkg-query
    sudo apt-get update
    if ! command -v gpg >/dev/null 2>&1; then
        sudo apt-get install -y --no-upgrade gpg
    fi
    ensure_eza_repository
    sudo apt-get update

    for package in "${remove_packages[@]}"; do
        apt_package_installed "$package" &&
            sudo apt-get remove -y "$package"
    done

    for package in "${packages[@]}"; do
        apt_package_installed "$package" && continue
        apt_package_available "$package" ||
            die "APT package is unavailable: $package"
        sudo apt-get install -y --no-upgrade "$package"
    done
}
```

- [ ] **Step 6: Implement the Paru adapter**

Render `remove_packages` from `packages.pacman.to_remove` and `packages` from
common plus each enabled capability. If the current data lacks
`packages.pacman.to_remove`, add `to_remove = []` under `[packages.pacman]`.
Remove the spinner and current-working-directory log file; fail directly on a
failed package:

```bash
install_paru_packages() {
    require_command paru

    for package in "${remove_packages[@]}"; do
        pacman -Q "$package" >/dev/null 2>&1 &&
            paru -R --noconfirm "$package"
    done

    for package in "${packages[@]}"; do
        pacman -Q "$package" >/dev/null 2>&1 && continue
        paru -Si "$package" >/dev/null 2>&1 ||
            die "Pacman/AUR package is unavailable: $package"
        paru -S --noconfirm --needed --skipreview --batchinstall "$package"
    done
}
```

- [ ] **Step 7: Add fail-fast fake-manager tests**

Override each profile's package data to three packages:
`["package-ok", "package-fail", "package-never"]`. Fake each manager so
`package-fail` exits 42. For Homebrew, fake `brew list` as not installed and
`brew install package-fail` as failure. For APT and Paru, fake availability
checks as successful.

Use one dispatcher symlinked to each command name:

```bash
manager_stub="$fake_bin/manager-stub"
cat >"$manager_stub" <<'STUB'
#!/usr/bin/env bash
set -u
manager=${0##*/}
printf '%s %s\n' "$manager" "$*" >>"$COMMAND_LOG"

case "$manager:$*" in
    sudo:*) exec "$@" ;;
    brew:list*) exit 1 ;;
    brew:*package-fail*|apt-get:*package-fail*|paru:*package-fail*) exit 42 ;;
    dpkg-query:*) exit 1 ;;
    apt-cache:show*) exit 0 ;;
    pacman:-Q*) exit 1 ;;
    paru:-Si*) exit 0 ;;
    mas:list*) exit 0 ;;
    *) exit 0 ;;
esac
STUB
chmod +x "$manager_stub"
for command_name in brew mas sudo apt-get apt-cache dpkg-query pacman paru; do
    ln -s manager-stub "$fake_bin/$command_name"
done
```

This heredoc is test-fixture construction inside the test script, not a
repository file-editing mechanism.

For each profile assert:

```bash
[[ $status -ne 0 ]]
rg -q 'package-ok' "$COMMAND_LOG"
rg -q 'package-fail' "$COMMAND_LOG"
if rg -q 'package-never' "$COMMAND_LOG"; then
    fail "manager continued after package-fail"
fi
```

- [ ] **Step 8: Validate and commit**

```bash
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected: both pass.

```bash
jj commit -m "refactor(chezmoi): consolidate system packages"
```

---

### Task 5: Add Runtime and Language-Package Phases

**Files:**

- Create: `chezmoi/.chezmoitemplates/scripts/language/runtimes.bash`
- Create: `chezmoi/.chezmoitemplates/scripts/language/packages.bash`
- Create:
  `chezmoi/.chezmoiscripts/run_onchange_after_20-language-runtimes.sh.tmpl`
- Create:
  `chezmoi/.chezmoiscripts/run_onchange_after_30-language-packages.sh.tmpl`
- Modify: `tests/chezmoi-render-scripts.sh`
- Modify: `tests/chezmoi-script-behavior.sh`

**Interfaces:**

- Consumes: `runtimes[]`, `packages.python`, `packages.node`,
  `packages.cargo`, `features.*`, core helpers.
- Produces: `ensure_uv`, `ensure_mise`, `install_language_runtimes`,
  `install_uv_tools`, `install_npm_packages`, `install_cargo_packages`.

- [ ] **Step 1: Add failing render and ordering tests**

Render phases 20 and 30 for development and minimal-server data:

```bash
runtime_source="$source_dir/.chezmoiscripts/run_onchange_after_20-language-runtimes.sh.tmpl"
language_source="$source_dir/.chezmoiscripts/run_onchange_after_30-language-packages.sh.tmpl"

render_script "$ubuntu_data" "$runtime_source" "$tmp_dir/ubuntu-runtime.sh"
render_script "$ubuntu_data" "$language_source" "$tmp_dir/ubuntu-language.sh"
check_rendered_script "$tmp_dir/ubuntu-runtime.sh"
check_rendered_script "$tmp_dir/ubuntu-language.sh"

assert_contains "$tmp_dir/ubuntu-runtime.sh" 'node@latest'
assert_contains "$tmp_dir/ubuntu-runtime.sh" 'rust@latest'
assert_contains "$tmp_dir/ubuntu-language.sh" '@go-task/cli'
assert_contains "$tmp_dir/ubuntu-language.sh" 'cargo-binstall'
```

Create a server profile with all capabilities false and assert its runtime
script contains `ensure_uv` but not `node@latest`, `rust@latest`, or
`ensure_mise`.

- [ ] **Step 2: Run render tests and verify failure**

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL because phase 20 is missing.

- [ ] **Step 3: Implement runtime selection in the phase 20 entrypoint**

Render only runtimes with at least one enabled feature:

```gotemplate
#!/usr/bin/env bash

PHASE="20-language-runtimes"
{{ template "scripts/core.bash" . }}
{{ template "scripts/language/runtimes.bash" . }}

export PATH="{{ .xdg.data_home }}/mise/shims:$HOME/.local/bin:$PATH"

runtimes=(
{{- range $runtime := .runtimes }}
{{-   $enabled := false }}
{{-   range $feature := $runtime.features }}
{{-     if index $.features $feature }}
{{-       $enabled = true }}
{{-     end }}
{{-   end }}
{{-   if $enabled }}
    "{{ $runtime.name }}@{{ $runtime.version }}"
{{-   end }}
{{- end }}
)

ensure_uv
if [[ ${#runtimes[@]} -gt 0 ]]; then
    ensure_mise
    install_language_runtimes "${runtimes[@]}"
fi
```

- [ ] **Step 4: Implement runtime installation helpers**

Use package managers where available, otherwise download installers before
executing them:

```bash
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
    case "{{ .chezmoi.os }}:{{ .chezmoi.osRelease.id }}" in
        darwin:*) brew install uv ;;
        linux:arch) paru -S --needed --noconfirm uv ;;
        linux:ubuntu|linux:debian)
            download_installer https://astral.sh/uv/install.sh uv-install
            ;;
        *) die "cannot install uv on this platform" ;;
    esac
    export PATH="$HOME/.local/bin:$PATH"
    require_command uv
}

ensure_mise() {
    command -v mise >/dev/null 2>&1 && return 0
    case "{{ .chezmoi.os }}:{{ .chezmoi.osRelease.id }}" in
        darwin:*) brew install mise ;;
        linux:arch) paru -S --needed --noconfirm mise ;;
        linux:ubuntu|linux:debian)
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
```

Both installers reuse the single `TEMP_DIR`; their filenames are distinct
(`uv-install.sh` and `mise-install.sh`), so no reset is required.

- [ ] **Step 5: Implement the phase 30 entrypoint**

Render feature-filtered arrays from Python, Node, and Cargo data, then call the
three helpers in fixed order:

```gotemplate
#!/usr/bin/env bash

PHASE="30-language-packages"
{{ template "scripts/core.bash" . }}
{{ template "scripts/language/packages.bash" . }}

export PATH="{{ .xdg.data_home }}/mise/shims:$HOME/.local/bin:$PATH"

uv_remove=(
{{- range .packages.python.to_remove }}
    "{{ . }}"
{{- end }}
)
uv_packages=(
{{- range .packages.python.common.packages }}
    "{{ . }}"
{{- end }}
{{- if .features.development }}
{{- range .packages.python.development.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.python.homelab.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.python.personal.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
)

npm_remove=(
{{- range .packages.node.to_remove }}
    "{{ . }}"
{{- end }}
)
npm_packages=(
{{- range .packages.node.common.packages }}
    "{{ . }}"
{{- end }}
{{- if .features.development }}
{{- range .packages.node.development.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.node.homelab.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.node.personal.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
)

cargo_remove=(
{{- range .packages.cargo.to_remove }}
    "{{ . }}"
{{- end }}
)
cargo_packages=(
{{- range .packages.cargo.common.packages }}
    "{{ . }}"
{{- end }}
{{- if .features.development }}
{{- range .packages.cargo.development.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.homelab }}
{{- range .packages.cargo.homelab.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
{{- if .features.personal }}
{{- range .packages.cargo.personal.packages }}
    "{{ . }}"
{{- end }}
{{- end }}
)

install_uv_tools
install_npm_packages
install_cargo_packages
```

- [ ] **Step 6: Implement the language package helpers**

```bash
install_uv_tools() {
    require_command uv
    local package
    for package in "${uv_remove[@]}"; do
        uv tool list | awk '{print $1}' | grep -Fxq "$package" &&
            uv tool uninstall "$package"
    done
    for package in "${uv_packages[@]}"; do
        uv tool list | awk '{print $1}' | grep -Fxq "$package" ||
            uv tool install "$package"
    done
}

install_npm_packages() {
    [[ ${#npm_packages[@]} -eq 0 && ${#npm_remove[@]} -eq 0 ]] && return 0
    require_command npm
    local package
    for package in "${npm_remove[@]}"; do
        npm list -g --depth=0 "$package" >/dev/null 2>&1 &&
            npm uninstall -g "$package"
    done
    for package in "${npm_packages[@]}"; do
        npm list -g --depth=0 "$package" >/dev/null 2>&1 ||
            npm install -g "$package"
    done
}

install_cargo_packages() {
    [[ ${#cargo_packages[@]} -eq 0 && ${#cargo_remove[@]} -eq 0 ]] &&
        return 0
    require_command cargo
    local installed package
    installed=$(cargo install --list 2>/dev/null |
        awk '$2 ~ /^v/ {print $1}')
    for package in "${cargo_remove[@]}"; do
        grep -Fxq "$package" <<<"$installed" &&
            cargo uninstall "$package"
    done
    for package in "${cargo_packages[@]}"; do
        grep -Fxq "$package" <<<"$installed" ||
            cargo install "$package"
    done
}
```

Replace here-strings with `printf | grep` if ShellCheck or Bash 3.2 validation
finds a portability issue.

- [ ] **Step 7: Add cross-phase fake-command ordering tests**

With minimal overridden data containing one package per manager, execute the
rendered phase 20 and then phase 30 using fake `mise`, `uv`, `npm`, and `cargo`.
Use this dispatcher:

```bash
language_stub="$fake_bin/language-stub"
cat >"$language_stub" <<'STUB'
#!/usr/bin/env bash
set -u
manager=${0##*/}
printf '%s %s\n' "$manager" "$*" >>"$COMMAND_LOG"

case "$manager:$*" in
    uv:"tool list"*) exit 0 ;;
    npm:"list -g"*) exit 1 ;;
    cargo:"install --list"*) exit 0 ;;
    npm:*node-tool*)
        [[ "${FAIL_NPM:-false}" == true ]] && exit 42
        ;;
esac
exit 0
STUB
chmod +x "$language_stub"
for command_name in mise uv node npm go rustc cargo bun deno taplo; do
    ln -s language-stub "$fake_bin/$command_name"
done
```

Assert the log order with line numbers:

```bash
mise_line=$(rg -n 'mise use -g node@latest' "$COMMAND_LOG" | cut -d: -f1)
uv_line=$(rg -n 'uv tool install python-tool' "$COMMAND_LOG" | cut -d: -f1)
npm_line=$(rg -n 'npm install -g node-tool' "$COMMAND_LOG" | cut -d: -f1)
cargo_line=$(rg -n 'cargo install cargo-tool' "$COMMAND_LOG" | cut -d: -f1)

((mise_line < uv_line))
((uv_line < npm_line))
((npm_line < cargo_line))
```

Add a failing fake `npm install -g node-tool` and assert `cargo install` is
absent from the log.

- [ ] **Step 8: Validate and commit**

```bash
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected: both pass.

```bash
jj commit -m "refactor(chezmoi): order language tool installation"
```

---

### Task 6: Replace Standalone Installers with Phase 40

**Files:**

- Modify: `chezmoi/.chezmoidata/binaries.toml`
- Create:
  `chezmoi/.chezmoitemplates/scripts/standalone/github-release.bash`
- Create:
  `chezmoi/.chezmoiscripts/run_onchange_after_40-standalone-tools.sh.tmpl`
- Modify: `tests/chezmoi-render-scripts.sh`
- Modify: `tests/chezmoi-script-behavior.sh`

**Interfaces:**

- Consumes: Each selected binary's `name`, `repository`, `systems`,
  `required_architecture`, `install_filter`, `executable_name`,
  `version_regex`, and `remove_from_release`.
- Produces:
  `install_github_release(name, repository, executable, exclude_regex)` and
  `install_git_credential_manager`.

- [ ] **Step 1: Add a failing GitHub-release behavior test**

Create a fixture API response with two assets:

```json
{
  "tag_name": "v1.2.3",
  "prerelease": false,
  "draft": false,
  "assets": [
    {
      "name": "sample-v1.2.3-x86_64-unknown-linux-gnu.tar.gz",
      "browser_download_url": "https://fixtures.invalid/sample.tar.gz"
    },
    {
      "name": "SHA256SUMS",
      "browser_download_url": "https://fixtures.invalid/SHA256SUMS"
    }
  ]
}
```

Fake `curl` must return this JSON for `/releases/latest`, copy a prepared
archive for `sample.tar.gz`, and copy a matching checksum file for
`SHA256SUMS`. Execute phase 40 with a single overridden binary and assert:

```bash
cat >"$fake_bin/curl" <<'STUB'
#!/usr/bin/env bash
set -u
printf 'curl %s\n' "$*" >>"$COMMAND_LOG"
output_file=""
url=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            output_file=$2
            shift 2
            ;;
        -H)
            shift 2
            ;;
        --fail|--show-error|--silent|--location|--retry)
            if [[ "$1" == --retry ]]; then shift 2; else shift; fi
            ;;
        http*) url=$1; shift ;;
        *) shift ;;
    esac
done

case "$url" in
    */releases/latest) cat "$RELEASE_JSON_FIXTURE" ;;
    */sample.tar.gz) cp "$ARCHIVE_FIXTURE" "$output_file" ;;
    */SHA256SUMS) cp "$CHECKSUM_FIXTURE" "$output_file" ;;
    *) exit 64 ;;
esac
STUB
chmod +x "$fake_bin/curl"
```

Create the archive with a fixture executable at
`sample-v1.2.3/sample`, and generate `SHA256SUMS` with the archive's actual
SHA-256 digest before running:

```bash
fixture_root="$tmp_dir/release-fixture"
mkdir -p "$fixture_root/sample-v1.2.3"
cat >"$fixture_root/sample-v1.2.3/sample" <<'SAMPLE'
#!/usr/bin/env bash
printf 'sample 1.2.3\n'
SAMPLE
chmod +x "$fixture_root/sample-v1.2.3/sample"
ARCHIVE_FIXTURE="$tmp_dir/sample.tar.gz"
tar -czf "$ARCHIVE_FIXTURE" -C "$fixture_root" sample-v1.2.3
CHECKSUM_FIXTURE="$tmp_dir/SHA256SUMS"
if command -v sha256sum >/dev/null 2>&1; then
    digest=$(sha256sum "$ARCHIVE_FIXTURE" | awk '{print $1}')
else
    digest=$(shasum -a 256 "$ARCHIVE_FIXTURE" | awk '{print $1}')
fi
printf '%s  %s\n' "$digest" sample.tar.gz >"$CHECKSUM_FIXTURE"
export ARCHIVE_FIXTURE CHECKSUM_FIXTURE
```

```bash
[[ -x "$HOME/.local/bin/sample" ]]
"$HOME/.local/bin/sample" --version |
    rg -q '^sample 1.2.3$'
assert_log_contains 'releases/latest'
assert_log_contains 'sample.tar.gz'
assert_log_contains 'SHA256SUMS'
```

Add a second case with a deliberately wrong checksum and assert non-zero exit
with no installed executable.

- [ ] **Step 2: Run behavior tests and verify failure**

```bash
./tests/chezmoi-script-behavior.sh
```

Expected: FAIL because phase 40 and its helper are missing.

- [ ] **Step 3: Add Atuin to standalone binary data**

Add:

```toml
[binaries.atuin]
  description           = "Shell history search and synchronization"
  executable_name       = "atuin"
  install_filter        = ""
  name                  = "atuin"
  remove_from_release   = ""
  repository            = "atuinsh/atuin"
  required_architecture = ""
  systems               = ["linux"]
  version_regex         = ""
```

Keep Git Credential Manager as a special Debian-package function because its
installation uses `dpkg`.

- [ ] **Step 4: Implement GitHub release selection and download**

Create the GitHub API and asset-selection functions in
`github-release.bash`:

```bash
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
```

Add checksum selection and the complete installer:

```bash
select_checksum_asset() {
    local release_json=$1
    jq -r '
        .assets[]
        | select(.name | test(
            "^(sha256sums|sha256sums\\.txt|checksums|checksums\\.txt)$";
            "i"
        ))
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

    command -v "$executable" >/dev/null 2>&1 && return 0
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
    checksum_url=$(select_checksum_asset "$release_json")
    if [[ -n "$checksum_url" && "$checksum_url" != null ]]; then
        local checksum_file="$work_dir/${checksum_url##*/}"
        curl --fail --show-error --silent --location --retry 3 \
            "$checksum_url" --output "$checksum_file"
        verify_archive_checksum "$work_dir" "${archive##*/}" "$checksum_file"
    else
        notice "$name release does not publish a recognized checksum asset"
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
    mv "$temporary_target" "$target"
    "$target" --version >/dev/null
}
```

- [ ] **Step 5: Implement GCM and the phase 40 entrypoint**

For Ubuntu/Debian `amd64` development profiles, add:

```bash
install_git_credential_manager() {
    git credential-manager --version >/dev/null 2>&1 && return 0
    require_command dpkg
    make_temp_dir "git-credential-manager"
    release_json="$TEMP_DIR/gcm-release.json"
    github_api \
        https://api.github.com/repos/git-ecosystem/git-credential-manager/releases/latest \
        >"$release_json"
    deb_url=$(jq -r '
        .assets[]
        | select(.name | test("linux.*(amd64|x64).*\\.deb$"; "i"))
        | .browser_download_url
    ' "$release_json" | head -n 1)
    [[ -n "$deb_url" ]] || die "GCM amd64 Debian asset not found"
    deb_file="$TEMP_DIR/${deb_url##*/}"
    curl --fail --show-error --silent --location --retry 3 \
        "$deb_url" --output "$deb_file"
    sudo dpkg -i "$deb_file"
    git credential-manager --version >/dev/null
}
```

Create the phase entrypoint:

```gotemplate
{{- $is_ci := ne (env "CI") "" -}}
{{- if and (eq .chezmoi.os "linux") (not $is_ci) -}}
#!/usr/bin/env bash

PHASE="40-standalone-tools"
{{ template "scripts/core.bash" . }}
{{ template "scripts/standalone/github-release.bash" . }}

{{- $os := .chezmoi.os }}
{{- $arch := .chezmoi.arch }}
{{- range $binary := .binaries }}
{{-   $enabled := has $os $binary.systems }}
{{-   if and $enabled (ne $binary.required_architecture "") }}
{{-     $enabled = eq $binary.required_architecture $arch }}
{{-   end }}
{{-   if and $enabled (ne $binary.install_filter "") }}
{{-     $enabled = index $.features $binary.install_filter }}
{{-   end }}
{{-   if $enabled }}
install_github_release \
    "{{ $binary.name }}" \
    "{{ $binary.repository }}" \
    "{{ $binary.executable_name | default $binary.name }}" \
    "{{ $binary.remove_from_release }}"
{{-   end }}
{{- end }}

{{- if and .features.development (eq .chezmoi.arch "amd64") (or (eq .chezmoi.osRelease.id "ubuntu") (eq .chezmoi.osRelease.id "debian")) }}
install_git_credential_manager
{{- end }}
{{- end }}
```

- [ ] **Step 6: Add render isolation assertions**

Assert:

- macOS phase 40 renders empty.
- Ubuntu development renders Atuin, all applicable binary entries, and GCM.
- Arch development renders Atuin and applicable binaries but no `dpkg` or GCM.
- A minimal Ubuntu server does not render development-filtered binaries.
- `render_script_ci` produces an empty phase 40 script for Linux CI data.

- [ ] **Step 7: Validate and commit**

```bash
taplo check chezmoi/.chezmoidata/binaries.toml
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected: all pass.

```bash
jj commit -m "refactor(chezmoi): consolidate standalone tools"
```

---

### Task 7: Add Post-Install, Security, and Maintenance Phases

**Files:**

- Create: `chezmoi/.chezmoiscripts/run_after_50-post-install.sh.tmpl`
- Create:
  `chezmoi/.chezmoiscripts/run_onchange_after_60-security-material.sh.tmpl`
- Create:
  `chezmoi/.chezmoiscripts/run_once_after_90-monthly-maintenance.sh.tmpl`
- Modify: `tests/chezmoi-render-scripts.sh`
- Modify: `tests/chezmoi-script-behavior.sh`

**Interfaces:**

- Consumes: XDG paths, secret-provider data, remote-server records, core
  helpers, and `uv`.
- Produces: Antidote/nanorc local state, Debian compatibility symlinks, SSH key
  files, and monthly uv upgrades.

- [ ] **Step 1: Add failing render assertions**

Assert:

```bash
assert_contains "$post_install" 'ANTIDOTE_DIR='
assert_contains "$post_install" 'nanorc'
assert_contains "$post_install" 'fdfind'
assert_contains "$post_install" 'batcat'

[[ ! -s "$security_none" ]] ||
    fail "security phase must be empty for provider none"

assert_contains "$maintenance" 'uv tool upgrade --all'
assert_contains "$maintenance_source" 'output "date" "+%m"'
```

Render a onepassword security fixture only through a stub `op` executable; do
not use local 1Password state. The stub handles `op signin --raw` by printing
`test-session` and handles `op item get <id> --format json` by printing:

```json
{
  "fields": [
    {"label": "private key", "value": "PRIVATE-KEY-FIXTURE\n"},
    {"label": "public key", "value": "ssh-ed25519 PUBLIC-FIXTURE\n"}
  ]
}
```

- [ ] **Step 2: Run render tests and verify failure**

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL because phase 50 is missing.

- [ ] **Step 3: Implement phase 50**

Use the core template and local postconditions:

```bash
install_antidote() {
    local zdotdir
    zdotdir=${ZDOTDIR:-"$HOME/.config/zsh"}
    local antidote_dir="$zdotdir/.antidote"
    [[ -d "$antidote_dir" ]] && return 0
    require_command git
    mkdir -p "$zdotdir"
    git clone --depth 1 https://github.com/mattmc3/antidote.git \
        "$antidote_dir"
}

install_nanorc() {
    local nano_dir="{{ .xdg.data_home }}/nano"
    [[ -f "$nano_dir/conf.nanorc" ]] && return 0
    require_command unzip
    make_temp_dir "nanorc"
    curl --fail --show-error --silent --location --retry 3 \
        https://github.com/scopatz/nanorc/archive/master.zip \
        --output "$TEMP_DIR/nanorc.zip"
    unzip -q "$TEMP_DIR/nanorc.zip" -d "$TEMP_DIR"
    mkdir -p "$nano_dir"
    cp -R "$TEMP_DIR/nanorc-master/." "$nano_dir/"
}

ensure_debian_symlinks() {
    mkdir -p "$HOME/.local/bin"
    if command -v batcat >/dev/null 2>&1 &&
        [[ ! -e "$HOME/.local/bin/bat" ]]; then
        ln -s "$(command -v batcat)" "$HOME/.local/bin/bat"
    fi
    if command -v fdfind >/dev/null 2>&1 &&
        [[ ! -e "$HOME/.local/bin/fd" ]]; then
        ln -s "$(command -v fdfind)" "$HOME/.local/bin/fd"
    fi
}
```

Call `install_antidote` and `install_nanorc` on all platforms. Render and call
`ensure_debian_symlinks` only on Debian/Ubuntu.

- [ ] **Step 4: Implement phase 60**

Wrap the entire output in:

```gotemplate
{{- if eq .secrets.provider "onepassword" -}}
```

Port current server iteration and preserve "create only if absent" behavior.
Add a portable decoder:

```bash
decode_base64() {
    if printf '' | base64 --decode >/dev/null 2>&1; then
        base64 --decode
    else
        base64 -D
    fi
}
```

For each key, render `onepassword` values through `b64enc` so shell quoting
cannot alter key content:

```gotemplate
private_key="{{ $.directories.ssh_keys_dir }}/{{ .name }}"
public_key="$private_key.pub"

if [[ ! -f "$private_key" ]]; then
    (
        umask 077
        printf '%s' '{{ range (onepassword .op_id).fields }}{{ if or (eq .label "privkey") (eq .label "private key") }}{{ .value | b64enc }}{{ end }}{{ end }}' |
            decode_base64 >"$private_key"
    )
    chmod 0600 "$private_key"
fi

if [[ ! -f "$public_key" ]]; then
    printf '%s' '{{ range (onepassword .op_id).fields }}{{ if or (eq .label "pubkey") (eq .label "public key") }}{{ .value | b64enc }}{{ end }}{{ end }}' |
        decode_base64 >"$public_key"
    chmod 0644 "$public_key"
fi
```

Do not include rendered secret values in any log line.

- [ ] **Step 5: Implement phase 90**

```gotemplate
#!/usr/bin/env bash

# {{ output "date" "+%m" | trim }}

PHASE="90-monthly-maintenance"
{{ template "scripts/core.bash" . }}

if command -v uv >/dev/null 2>&1; then
    uv tool upgrade --all
else
    die "uv is required for monthly maintenance"
fi
```

- [ ] **Step 6: Add local postcondition behavior tests**

Execute phase 50 twice against a temporary HOME with fake `git`, `curl`,
`unzip`, `batcat`, and `fdfind`. Assert the second execution makes no network
or clone calls and both symlinks still exist.

Execute phase 90 with fake `uv` and assert exactly one logged call:

```text
uv tool upgrade --all
```

- [ ] **Step 7: Validate and commit**

```bash
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected: both pass.

```bash
jj commit -m "refactor(chezmoi): add final setup phases"
```

---

### Task 8: Remove Superseded Scripts and Enforce the Eight-Phase Contract

**Files:**

- Delete: Every old script and `shared_script_utils.bash` listed in
  **Target File Structure**
- Modify: `tests/chezmoi-render-scripts.sh`

**Interfaces:**

- Consumes: All eight replacement phases from Tasks 3-7.
- Produces: An exact, test-enforced `.chezmoiscripts` inventory.

- [ ] **Step 1: Add the failing exact-inventory assertion**

Append:

```bash
actual_scripts="$tmp_dir/actual-scripts.txt"
expected_scripts="$tmp_dir/expected-scripts.txt"

find "$source_dir/.chezmoiscripts" -maxdepth 1 -type f \
    -exec basename {} \; | sort >"$actual_scripts"

printf '%s\n' \
    run_after_50-post-install.sh.tmpl \
    run_before_00-bootstrap.sh.tmpl \
    run_onchange_after_20-language-runtimes.sh.tmpl \
    run_onchange_after_30-language-packages.sh.tmpl \
    run_onchange_after_40-standalone-tools.sh.tmpl \
    run_onchange_after_60-security-material.sh.tmpl \
    run_onchange_before_10-system-packages.sh.tmpl \
    run_once_after_90-monthly-maintenance.sh.tmpl |
    sort >"$expected_scripts"

diff -u "$expected_scripts" "$actual_scripts"
```

- [ ] **Step 2: Run render tests and verify failure**

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL with a diff listing the old scripts.

- [ ] **Step 3: Delete every superseded source**

Use `apply_patch` delete hunks for the 21 old script files and
`shared_script_utils.bash`. Do not delete any of the eight new entrypoints or
focused fragments.

- [ ] **Step 4: Check for stale executable references**

Run:

```bash
rg -n \
    'shared_script_utils|install-binary\.py|run_after_30-instal-atuin|run_onchange_before-10-paru' \
    chezmoi tests
```

Expected: no matches. Documentation matches are handled in Task 9.

- [ ] **Step 5: Run the complete script suite**

```bash
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected: all three print their `passed` messages.

- [ ] **Step 6: Commit**

```bash
jj commit -m "refactor(chezmoi): remove legacy script entrypoints"
```

---

### Task 9: Update Documentation

**Files:**

- Modify: `README.md`
- Modify: `docs/01-remote-server-flow.md`
- Modify: `docs/02-homebrew-packages-flow.md`
- Replace: `docs/03-shell-scripting-chezmoi.md`
- Modify: `docs/security-review.md`

**Interfaces:**

- Consumes: Final phase names and three-layer architecture.
- Produces: Documentation with no references to deleted script names or the
  deleted shared utility API.

- [ ] **Step 1: Add a failing stale-documentation check**

Append to `tests/chezmoi-render-scripts.sh`:

```bash
stale_docs_pattern='shared_script_utils|run_after_20-create-ssh-keys|run_onchange_before_10-homebrew-packages|run_after_30-instal-atuin|install-binary\.py'
if rg -n "$stale_docs_pattern" \
    "$repo_root/README.md" \
    "$repo_root/docs/01-remote-server-flow.md" \
    "$repo_root/docs/02-homebrew-packages-flow.md" \
    "$repo_root/docs/03-shell-scripting-chezmoi.md" \
    "$repo_root/docs/security-review.md"; then
    fail "documentation still refers to legacy script architecture"
fi
```

- [ ] **Step 2: Run the check and verify failure**

```bash
./tests/chezmoi-render-scripts.sh
```

Expected: FAIL and print legacy references from the documentation.

- [ ] **Step 3: Update the README script overview**

Replace the current two-line Scripts section with:

```markdown
## Scripts

Chezmoi automation uses three layers:

- `.chezmoidata` declares system, language, and standalone packages.
- `.chezmoitemplates/scripts` contains focused platform implementation
  fragments.
- `.chezmoiscripts` contains eight ordered execution phases from bootstrap
  through monthly maintenance.

Run `chezmoi apply --dry-run --verbose` to inspect rendered phases before the
first apply on a machine.
```

- [ ] **Step 4: Update flow documents**

In `docs/01-remote-server-flow.md`, replace the old SSH script name with
`run_onchange_after_60-security-material.sh.tmpl`.

In `docs/02-homebrew-packages-flow.md`, replace the old Homebrew script name
with `run_onchange_before_10-system-packages.sh.tmpl` and explain that the
Homebrew fragment is rendered only on macOS.

Replace `docs/03-shell-scripting-chezmoi.md` with these sections:

````markdown
# Shell Scripting with Chezmoi

## Three-Layer Architecture

Automation is divided by responsibility:

- `.chezmoidata/packages-system.toml` declares Homebrew, MAS, APT, and
  Pacman/Paru packages.
- `.chezmoidata/packages-language.toml` declares runtimes and uv, npm, and
  Cargo packages.
- `.chezmoidata/binaries.toml` declares standalone GitHub-release tools.
- `.chezmoitemplates/scripts/` contains reusable Bash implementation fragments.
- `.chezmoiscripts/` contains the ordered Chezmoi entrypoints.

Changing package data changes the rendered content of its owning
`run_onchange` phase. Platform conditions are evaluated while rendering, so a
Homebrew-only change does not alter the Ubuntu system-package script.

## Execution Phases

| Phase | Timing | Responsibility |
| --- | --- | --- |
| 00 | before, always | Bootstrap package managers and minimum commands |
| 10 | before, on change | Install system packages |
| 20 | after, on change | Install uv, mise, and language runtimes |
| 30 | after, on change | Install uv, npm, and Cargo packages |
| 40 | after, on change | Install standalone GitHub-release tools |
| 50 | after, always | Repair shell extras, nanorc, and compatibility symlinks |
| 60 | after, on change | Create SSH key material |
| 90 | after, monthly | Upgrade uv-managed tools |

The numeric phase is a dependency boundary. Runtime phase 20 must complete
before language-package phase 30.

## Core Shell Contract

Every non-empty phase:

- uses Bash 3.2-compatible syntax;
- enables `set -Eeuo pipefail`;
- stops on the first failed configured operation;
- reports the phase, line, command, and exit status;
- removes its private temporary directory on exit; and
- treats an already satisfied postcondition as success.

Package-manager transactions cannot be rolled back as a unit. Each operation
must therefore be idempotent so a later `chezmoi apply` can safely retry after
partial completion.

## Adding a Package

1. Add OS-managed applications to the matching table in
   `packages-system.toml`.
2. Add uv, npm, Cargo, or runtime entries to `packages-language.toml`.
3. Add archive-based Linux tools to `binaries.toml`.
4. Run the render and behavior tests.

Do not add a new entrypoint for a single package. Add manager-specific behavior
to its focused template fragment only when data alone cannot express it.

## Validation

Run:

```bash
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
chezmoi apply --dry-run --verbose
```

The tests render macOS, Ubuntu, and Arch profiles, run Bash syntax checks and
ShellCheck, and execute fake package managers to verify fail-fast ordering.
````

- [ ] **Step 5: Reconcile the security review**

Keep historical findings but mark resolved installer findings with the new
paths and behavior:

- Remote installers are downloaded before execution.
- Standalone release checksums are verified when published.
- SSH key writing uses `printf` and `umask 077`.

Do not mark unrelated SSH trust or secret-exposure findings resolved.

- [ ] **Step 6: Validate docs and commit**

```bash
markdownlint-cli2 README.md docs/01-remote-server-flow.md \
    docs/02-homebrew-packages-flow.md docs/03-shell-scripting-chezmoi.md \
    docs/security-review.md
./tests/chezmoi-render-scripts.sh
```

Expected: Markdown lint exits 0 and render scripts test passes.

```bash
jj commit -m "docs(chezmoi): document script phases"
```

---

### Task 10: Run Final Verification and Inspect the First-Apply Plan

**Files:**

- Modify only if a verification command exposes a defect.

**Interfaces:**

- Consumes: Entire implementation.
- Produces: Evidence that all acceptance gates pass and a reviewed dry-run.

- [ ] **Step 1: Format all changed Bash and TOML**

```bash
shfmt -w -i 4 \
    chezmoi/.chezmoitemplates/scripts/core.bash \
    tests/chezmoi-render-scripts.sh \
    tests/chezmoi-script-behavior.sh
taplo fmt chezmoi/.chezmoidata/packages-system.toml \
    chezmoi/.chezmoidata/packages-language.toml \
    chezmoi/.chezmoidata/binaries.toml
```

Expected: commands exit 0. Template-containing files are validated by
`check_rendered_script`, which must also run
`shfmt -d -i 4 "$script"` against every rendered script. Review formatting
changes before proceeding.

- [ ] **Step 2: Run all static and behavior tests**

```bash
./tests/chezmoi-render-config.sh
./tests/chezmoi-render-scripts.sh
./tests/chezmoi-script-behavior.sh
```

Expected:

```text
chezmoi render matrix passed
chezmoi script render tests passed
chezmoi script behavior tests passed
```

- [ ] **Step 3: Run repository formatting/lint hooks**

```bash
pre-commit run --all-files
```

Expected: every hook reports `Passed`. If a formatter changes files, rerun the
three test scripts before continuing.

- [ ] **Step 4: Render a no-install dry-run**

Use a temporary destination and a secretless server profile:

```bash
dry_run_root=$(mktemp -d)
dry_run_data=$(mktemp)
chezmoi -S chezmoi data |
    jq '
        .secrets.provider = "none"
        | .encrypted_files.enabled = false
        | .machine.role = "server"
        | .features = {
            development: false,
            homelab: false,
            personal: false,
            graphical: false
          }
    ' >"$dry_run_data"
chezmoi -S chezmoi -D "$dry_run_root" \
    --override-data-file "$dry_run_data" apply \
    --dry-run --verbose --no-tty --force --exclude externals
```

Expected: exit 0. Because this is a dry-run, no package manager or network
installer executes.

- [ ] **Step 5: Verify inventory and forbidden patterns**

```bash
find chezmoi/.chezmoiscripts -maxdepth 1 -type f | sort
rg -n \
    'curl[^|]*\|[[:space:]]*(sh|bash)|install-binary\.py|shared_script_utils|run_onchange_before-10' \
    chezmoi/.chezmoiscripts chezmoi/.chezmoitemplates/scripts
```

Expected: `find` prints exactly eight files. `rg` exits 1 with no matches.

- [ ] **Step 6: Review the final diff**

```bash
jj diff --stat
jj diff --color=never
```

Confirm the diff changes only package/runtime declarations, script
architecture, tests, and named documentation files.

- [ ] **Step 7: Commit any verification-only formatting fixes**

If Step 1 or Step 3 changed files:

```bash
jj commit -m "style(chezmoi): normalize script formatting"
```

If the working copy is already clean, do not create an empty commit.

- [ ] **Step 8: Record rollout guidance in the handoff**

The final handoff must state:

- New `run_onchange` paths execute on the first apply after migration.
- The first real apply should start with
  `chezmoi apply --dry-run --verbose`.
- Validate on one representative macOS, Ubuntu, and Arch machine before broad
  rollout.
- Tests never performed a real package installation.
