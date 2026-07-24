# Role-First Server Identity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Chezmoi initialization role-first and give servers an automatic, secretless `server-minimal` identity that supports unsigned local Git and Jujutsu commits.

**Architecture:** `.chezmoi.toml.tmpl` will resolve `machine.role` before identity, use role-specific prompt branches, and always emit the existing stable data schema. Focused tests will separately verify the interactive prompt contract, generated data and role transitions, render compatibility, and real local VCS commits. Git and Jujutsu consumers will treat the server profile's GitHub and signing fields as optional.

**Tech Stack:** Chezmoi Go templates, TOML, Bash, Python 3 standard-library pseudo-terminals, `jq`, `rg`, Git, and Jujutsu.

## Global Constraints

- The first fresh-init prompt is `Choose this machine's primary role`.
- A fresh server init asks only for role, development, and homelab choices.
- Server identity is exactly `server-minimal`, `chianyungcode-server`, and `chianyungcode-server@local.invalid`.
- Server values are always `features.personal = false`, `features.graphical = false`, `secrets.provider = "none"`, and `encrypted_files.enabled = false`.
- Server Git and Jujutsu commits are unsigned and local-only; do not add push credentials or a hard push prohibition.
- `development` and `homelab` remain independently selectable on servers.
- Workstation profiles remain `personal`, `secondary`, and `custom`.
- An exceptional graphical server can be enabled by manually editing generated data, but server reinitialization restores `graphical = false`.
- Existing machines are not rewritten by `chezmoi apply`; do not add an automatic migration script.
- Templates must fail clearly for unknown workstation profiles or missing required Git identity values.

---

## File Map

- `chezmoi/.chezmoidata/accounts.toml`: owns predefined identity records, including `server-minimal`.
- `chezmoi/.chezmoi.toml.tmpl`: owns prompt order, role-specific defaults, profile reconciliation, and generated data.
- `chezmoi/dot_config/git/config.tmpl`: consumes optional GitHub and signing fields safely.
- `chezmoi/dot_config/jj/config.toml.tmpl`: selects signed workstation behavior or explicit unsigned behavior.
- `tests/chezmoi-init-prompts.py`: verifies real interactive question order through a pseudo-terminal.
- `tests/chezmoi-init-data.sh`: verifies generated values, custom identity behavior, transitions, and invalid-profile errors.
- `tests/chezmoi-render-config.sh`: keeps the existing cross-feature render matrix role-consistent.
- `tests/chezmoi-vcs-local-commit.sh`: verifies rendered Git and Jujutsu configs by making real local commits.
- `README.md`: summarizes the new initialization path.
- `docs/06-server-initialization.md`: documents server defaults, emergency commits, overrides, and migration.

---

### Task 1: Implement the role-first initialization contract

**Files:**

- Create: `tests/chezmoi-init-prompts.py`
- Create: `tests/chezmoi-init-data.sh`
- Modify: `tests/chezmoi-render-config.sh`
- Modify: `chezmoi/.chezmoidata/accounts.toml`
- Modify: `chezmoi/.chezmoi.toml.tmpl`

**Interfaces:**

- Consumes: Chezmoi's `promptChoiceOnce`, `promptChoice`, `promptBoolOnce`, `promptBool`, `promptStringOnce`, `promptString`, `dig`, `hasKey`, and `fail` template functions.
- Produces: the unchanged `.identity`, `.machine`, `.features`, `.secrets`, and `.encrypted_files` data tables with role-consistent values.
- Produces: predefined account key `accounts.server-minimal`.
- Produces: executable test commands `./tests/chezmoi-init-prompts.py` and `./tests/chezmoi-init-data.sh`.

- [ ] **Step 1: Add the failing interactive prompt-contract test**

Create `tests/chezmoi-init-prompts.py` with this complete content:

```python
#!/usr/bin/env python3

from __future__ import annotations

import os
import pathlib
import pty
import select
import shutil
import subprocess
import sys
import tempfile
import time


ROLE = "Choose this machine's primary role?"
IDENTITY = "Choose your identity profile?"
DEVELOPMENT = "Enable development tools?"
HOMELAB = "Enable homelab tools?"
PERSONAL = "Enable personal tools?"
GRAPHICAL = "Enable graphical tools?"
SECRETS = "Choose the secrets provider?"
AGE = "Enable Age-encrypted files?"
ALL_QUESTIONS = (
    ROLE,
    IDENTITY,
    DEVELOPMENT,
    HOMELAB,
    PERSONAL,
    GRAPHICAL,
    SECRETS,
    AGE,
)


def fail(message: str, transcript: str) -> None:
    print(message, file=sys.stderr)
    print("----- prompt transcript -----", file=sys.stderr)
    print(transcript, file=sys.stderr)
    raise SystemExit(1)


def run_case(
    repo_root: pathlib.Path,
    name: str,
    expected: list[tuple[str, str]],
) -> str:
    with tempfile.TemporaryDirectory(prefix=f"chezmoi-{name}-") as temp_name:
        temp_root = pathlib.Path(temp_name)
        source_dir = temp_root / "source"
        data_dir = source_dir / ".chezmoidata"
        data_dir.mkdir(parents=True)
        shutil.copy2(
            repo_root / "chezmoi" / ".chezmoi.toml.tmpl",
            source_dir / ".chezmoi.toml.tmpl",
        )
        shutil.copy2(
            repo_root / "chezmoi" / ".chezmoidata" / "accounts.toml",
            data_dir / "accounts.toml",
        )

        command = [
            "chezmoi",
            "--cache",
            str(temp_root / "cache"),
            "--persistent-state",
            str(temp_root / "state.boltdb"),
            "-S",
            str(source_dir),
            "-c",
            str(temp_root / "chezmoi.toml"),
            "-D",
            str(temp_root / "home"),
            "init",
            "--prompt",
        ]
        environment = os.environ.copy()
        environment["TERM"] = "dumb"
        environment["NO_COLOR"] = "1"

        master_fd, slave_fd = pty.openpty()
        process = subprocess.Popen(
            command,
            stdin=slave_fd,
            stdout=slave_fd,
            stderr=slave_fd,
            env=environment,
            close_fds=True,
        )
        os.close(slave_fd)

        transcript = ""
        seen: set[str] = set()
        expected_index = 0
        deadline = time.monotonic() + 20

        try:
            while process.poll() is None:
                if time.monotonic() > deadline:
                    process.kill()
                    fail(f"{name}: timed out waiting for prompts", transcript)

                ready, _, _ = select.select([master_fd], [], [], 0.2)
                if not ready:
                    continue

                try:
                    chunk = os.read(master_fd, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                transcript += chunk.decode("utf-8", errors="replace")

                for question in ALL_QUESTIONS:
                    if question not in transcript or question in seen:
                        continue
                    if expected_index >= len(expected):
                        process.kill()
                        fail(f"{name}: unexpected prompt {question!r}", transcript)
                    expected_question, answer = expected[expected_index]
                    if question != expected_question:
                        process.kill()
                        fail(
                            f"{name}: expected {expected_question!r}, got {question!r}",
                            transcript,
                        )
                    seen.add(question)
                    expected_index += 1
                    os.write(master_fd, answer.encode("utf-8") + b"\r")

            return_code = process.wait(timeout=5)
        finally:
            os.close(master_fd)

        if return_code != 0:
            fail(f"{name}: chezmoi init exited with {return_code}", transcript)
        if expected_index != len(expected):
            missing = [question for question, _ in expected[expected_index:]]
            fail(f"{name}: missing prompts: {missing}", transcript)

        positions = [transcript.index(question) for question, _ in expected]
        if positions != sorted(positions):
            fail(f"{name}: prompts appeared out of order", transcript)
        return transcript


def main() -> None:
    repo_root = pathlib.Path(__file__).resolve().parents[1]
    if shutil.which("chezmoi") is None:
        raise SystemExit("missing required command: chezmoi")

    server_transcript = run_case(
        repo_root,
        "server",
        [
            (ROLE, ""),
            (DEVELOPMENT, ""),
            (HOMELAB, ""),
        ],
    )
    for forbidden in (IDENTITY, PERSONAL, GRAPHICAL, SECRETS, AGE):
        if forbidden in server_transcript:
            fail(f"server: forbidden prompt appeared: {forbidden!r}", server_transcript)

    run_case(
        repo_root,
        "workstation",
        [
            (ROLE, "workstation"),
            (IDENTITY, ""),
            (DEVELOPMENT, ""),
            (HOMELAB, ""),
            (PERSONAL, ""),
            (GRAPHICAL, ""),
            (SECRETS, ""),
            (AGE, ""),
        ],
    )
    print("chezmoi init prompt flow passed")


if __name__ == "__main__":
    main()
```

Make it executable:

```bash
chmod +x tests/chezmoi-init-prompts.py
```

- [ ] **Step 2: Add the failing generated-data and transition test**

Create `tests/chezmoi-init-data.sh` with this complete content:

```bash
#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
template_file="$source_dir/.chezmoi.toml.tmpl"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi jq rg; do
    command -v "$command_name" >/dev/null || {
        printf 'missing required command: %s\n' "$command_name" >&2
        exit 1
    }
done

missing_config="$tmp_dir/missing.toml"

render_config() {
    local output_file=$1
    local input_config=$2
    shift 2
    chezmoi -S "$source_dir" -c "$input_config" execute-template --init \
        "$@" --file "$template_file" >"$output_file"
}

config_data() {
    local config_file=$1
    local output_file=$2
    chezmoi -S "$source_dir" -c "$config_file" data >"$output_file"
}

server_config="$tmp_dir/server.toml"
server_data="$tmp_dir/server.json"
render_config "$server_config" "$missing_config"
config_data "$server_config" "$server_data"
jq -e '
    .machine.role == "server"
    and .identity == {
        profile: "server-minimal",
        git_name: "chianyungcode-server",
        git_email: "chianyungcode-server@local.invalid",
        github_username: "",
        signing_key: "",
        github_token: ""
    }
    and .features == {
        development: false,
        homelab: false,
        personal: false,
        graphical: false
    }
    and .secrets.provider == "none"
    and .encrypted_files.enabled == false
' "$server_data" >/dev/null

workstation_config="$tmp_dir/workstation.toml"
workstation_data="$tmp_dir/workstation.json"
render_config "$workstation_config" "$missing_config" \
    --promptChoice machine.role=workstation
config_data "$workstation_config" "$workstation_data"
jq -e '
    .machine.role == "workstation"
    and .identity.profile == "personal"
    and .features == {
        development: true,
        homelab: false,
        personal: true,
        graphical: true
    }
    and .secrets.provider == "onepassword"
    and .encrypted_files.enabled == true
' "$workstation_data" >/dev/null

custom_config="$tmp_dir/custom.toml"
custom_data="$tmp_dir/custom.json"
render_config "$custom_config" "$missing_config" \
    --promptChoice machine.role=workstation \
    --promptChoice identity.profile=custom \
    --promptString identity.git_name=Emergency \
    --promptString identity.git_email=emergency@example.invalid \
    --promptString identity.github_username=emergency \
    --promptChoice secrets.provider=none \
    --promptBool encrypted_files.enabled=false
config_data "$custom_config" "$custom_data"
jq -e '
    .identity.profile == "custom"
    and .identity.git_name == "Emergency"
    and .identity.git_email == "emergency@example.invalid"
    and .identity.github_username == "emergency"
    and .identity.signing_key == ""
    and .identity.github_token == ""
' "$custom_data" >/dev/null

server_to_workstation_input="$tmp_dir/server-to-workstation-input.toml"
printf '%s\n' \
    '[data.machine]' \
    'role = "workstation"' \
    '' \
    '[data.identity]' \
    'profile = "server-minimal"' \
    'git_name = "chianyungcode-server"' \
    'git_email = "chianyungcode-server@local.invalid"' \
    'github_username = ""' \
    'signing_key = ""' \
    'github_token = ""' \
    >"$server_to_workstation_input"

server_to_workstation_config="$tmp_dir/server-to-workstation.toml"
server_to_workstation_data="$tmp_dir/server-to-workstation.json"
render_config "$server_to_workstation_config" "$server_to_workstation_input"
config_data "$server_to_workstation_config" "$server_to_workstation_data"
jq -e '
    .machine.role == "workstation"
    and .identity.profile == "personal"
    and .features.personal == true
    and .features.graphical == true
    and .secrets.provider == "onepassword"
    and .encrypted_files.enabled == true
' "$server_to_workstation_data" >/dev/null

workstation_to_server_input="$tmp_dir/workstation-to-server-input.toml"
printf '%s\n' \
    '[data.machine]' \
    'role = "server"' \
    '' \
    '[data.identity]' \
    'profile = "personal"' \
    >"$workstation_to_server_input"

workstation_to_server_config="$tmp_dir/workstation-to-server.toml"
workstation_to_server_data="$tmp_dir/workstation-to-server.json"
render_config "$workstation_to_server_config" "$workstation_to_server_input"
config_data "$workstation_to_server_config" "$workstation_to_server_data"
jq -e '
    .machine.role == "server"
    and .identity.profile == "server-minimal"
    and .features.personal == false
    and .features.graphical == false
    and .secrets.provider == "none"
    and .encrypted_files.enabled == false
' "$workstation_to_server_data" >/dev/null

unknown_profile_input="$tmp_dir/unknown-profile-input.toml"
printf '%s\n' \
    '[data.machine]' \
    'role = "workstation"' \
    '' \
    '[data.identity]' \
    'profile = "mystery"' \
    >"$unknown_profile_input"

if render_config "$tmp_dir/unknown-profile.toml" "$unknown_profile_input" \
    2>"$tmp_dir/unknown-profile.err"; then
    printf 'unknown workstation profile unexpectedly rendered\n' >&2
    exit 1
fi
rg -q 'unknown workstation identity profile "mystery"' \
    "$tmp_dir/unknown-profile.err"

if render_config "$tmp_dir/empty-custom.toml" "$missing_config" \
    --promptChoice machine.role=workstation \
    --promptChoice identity.profile=custom \
    --promptString identity.git_name= \
    --promptString identity.git_email=emergency@example.invalid \
    --promptString identity.github_username= \
    2>"$tmp_dir/empty-custom.err"; then
    printf 'empty custom Git name unexpectedly rendered\n' >&2
    exit 1
fi
rg -q 'must define non-empty git_name and git_email' \
    "$tmp_dir/empty-custom.err"

missing_account_source="$tmp_dir/missing-server-account-source"
mkdir -p "$missing_account_source/.chezmoidata"
cp "$template_file" "$missing_account_source/.chezmoi.toml.tmpl"
awk '
    /^\[accounts\.server-minimal\]$/ { exit }
    { print }
' "$source_dir/.chezmoidata/accounts.toml" \
    >"$missing_account_source/.chezmoidata/accounts.toml"

if chezmoi -S "$missing_account_source" -c "$missing_config" \
    execute-template --init \
    --file "$missing_account_source/.chezmoi.toml.tmpl" \
    >"$tmp_dir/missing-account.toml" \
    2>"$tmp_dir/missing-account.err"; then
    printf 'missing server account unexpectedly rendered\n' >&2
    exit 1
fi
rg -q 'identity profile "server-minimal" is missing' \
    "$tmp_dir/missing-account.err"

printf 'chezmoi init data passed\n'
```

Make it executable:

```bash
chmod +x tests/chezmoi-init-data.sh
```

- [ ] **Step 3: Run both new tests and verify the current behavior fails**

Run:

```bash
./tests/chezmoi-init-prompts.py
```

Expected: FAIL because `Choose your identity profile?` appears before the role question.

Run:

```bash
./tests/chezmoi-init-data.sh
```

Expected: FAIL because a default server currently renders `identity.profile = "personal"`.

- [ ] **Step 4: Add the predefined server account**

Append this exact table to `chezmoi/.chezmoidata/accounts.toml`:

```toml

[accounts.server-minimal]
git_name = "chianyungcode-server"
git_email = "chianyungcode-server@local.invalid"
github_username = ""
signing_key = ""
github_token = ""
```

- [ ] **Step 5: Replace the initialization logic with the role-first branch**

Replace `chezmoi/.chezmoi.toml.tmpl` with:

```gotemplate
{{- $account_data := include ".chezmoidata/accounts.toml" | fromToml -}}
{{- $machine_role := promptChoiceOnce . "machine.role" "Choose this machine's primary role" (list "server" "workstation") "server" -}}
{{- $existing_identity_profile := dig "identity" "profile" "" . -}}
{{- $workstation_transition := and (eq $machine_role "workstation") (eq $existing_identity_profile "server-minimal") -}}
{{- $identity_profile := "server-minimal" -}}
{{- if eq $machine_role "workstation" -}}
{{-   if $workstation_transition -}}
{{-     $identity_profile = promptChoice "Choose your identity profile" (list "personal" "secondary" "custom") "personal" -}}
{{-   else if and (ne $existing_identity_profile "") (not (or (eq $existing_identity_profile "personal") (eq $existing_identity_profile "secondary") (eq $existing_identity_profile "custom"))) -}}
{{-     fail (printf "unknown workstation identity profile %q; expected personal, secondary, or custom" $existing_identity_profile) -}}
{{-   else -}}
{{-     $identity_profile = promptChoiceOnce . "identity.profile" "Choose your identity profile" (list "personal" "secondary" "custom") "personal" -}}
{{-   end -}}
{{- end -}}

{{- $git_name := "" -}}
{{- $git_email := "" -}}
{{- $github_username := "" -}}
{{- $signing_key := "" -}}
{{- $github_token := "" -}}
{{- if eq $identity_profile "custom" -}}
{{-   if $workstation_transition -}}
{{-     $git_name = promptString "Git author name" -}}
{{-     $git_email = promptString "Git author email" -}}
{{-     $github_username = promptString "GitHub username" -}}
{{-   else -}}
{{-     $git_name = promptStringOnce . "identity.git_name" "Git author name" -}}
{{-     $git_email = promptStringOnce . "identity.git_email" "Git author email" -}}
{{-     $github_username = promptStringOnce . "identity.github_username" "GitHub username" -}}
{{-   end -}}
{{- else -}}
{{-   if not (hasKey $account_data.accounts $identity_profile) -}}
{{-     fail (printf "identity profile %q is missing from .chezmoidata/accounts.toml" $identity_profile) -}}
{{-   end -}}
{{-   $account := index $account_data.accounts $identity_profile -}}
{{-   $git_name = $account.git_name -}}
{{-   $git_email = $account.git_email -}}
{{-   $github_username = $account.github_username -}}
{{-   $signing_key = $account.signing_key -}}
{{-   $github_token = $account.github_token -}}
{{- end -}}
{{- if or (eq $git_name "") (eq $git_email "") -}}
{{-   fail (printf "identity profile %q must define non-empty git_name and git_email" $identity_profile) -}}
{{- end -}}

{{- $workstation_defaults := eq $machine_role "workstation" -}}
{{- $development := promptBoolOnce . "features.development" "Enable development tools?" $workstation_defaults -}}
{{- $homelab := promptBoolOnce . "features.homelab" "Enable homelab tools?" false -}}
{{- $personal := false -}}
{{- $graphical := false -}}
{{- $secrets_provider := "none" -}}
{{- $encrypted_files := false -}}
{{- if $workstation_defaults -}}
{{-   if $workstation_transition -}}
{{-     $personal = promptBool "Enable personal tools?" true -}}
{{-     $graphical = promptBool "Enable graphical tools?" true -}}
{{-     $secrets_provider = promptChoice "Choose the secrets provider" (list "none" "onepassword") "onepassword" -}}
{{-     $encrypted_files = promptBool "Enable Age-encrypted files?" true -}}
{{-   else -}}
{{-     $personal = promptBoolOnce . "features.personal" "Enable personal tools?" true -}}
{{-     $graphical = promptBoolOnce . "features.graphical" "Enable graphical tools?" true -}}
{{-     $secrets_provider = promptChoiceOnce . "secrets.provider" "Choose the secrets provider" (list "none" "onepassword") "onepassword" -}}
{{-     $encrypted_files = promptBoolOnce . "encrypted_files.enabled" "Enable Age-encrypted files?" true -}}
{{-   end -}}
{{- end -}}

{{- $xdg_cache := env "XDG_CACHE_HOME" | default (joinPath .chezmoi.homeDir ".cache") -}}
{{- $xdg_config := env "XDG_CONFIG_HOME" | default (joinPath .chezmoi.homeDir ".config") -}}
{{- $xdg_data := env "XDG_DATA_HOME" | default (joinPath .chezmoi.homeDir ".local/share") -}}
{{- $xdg_state := env "XDG_STATE_HOME" | default (joinPath .chezmoi.homeDir ".local/state") -}}

{{ if $encrypted_files }}
encryption = "age"

[age]
identity = "{{ joinPath .chezmoi.homeDir ".local/share/ages/keys.txt" }}"
recipients = "age1z9fpa8c4v4fmdu42myc6uyapvs9436tns9myss5yqv6p3cmrny2s4rs6kt"
{{ end }}

[data.identity]
profile = {{ $identity_profile | quote }}
git_name = {{ $git_name | quote }}
git_email = {{ $git_email | quote }}
github_username = {{ $github_username | quote }}
signing_key = {{ $signing_key | quote }}
github_token = {{ $github_token | quote }}

[data.machine]
role = {{ $machine_role | quote }}

[data.features]
development = {{ $development }}
homelab = {{ $homelab }}
personal = {{ $personal }}
graphical = {{ $graphical }}

[data.secrets]
provider = {{ $secrets_provider | quote }}

[data.encrypted_files]
enabled = {{ $encrypted_files }}

[data.xdg]
cache_home = {{ $xdg_cache | quote }}
config_home = {{ $xdg_config | quote }}
data_home = {{ $xdg_data | quote }}
state_home = {{ $xdg_state | quote }}
```

- [ ] **Step 6: Run the focused init tests**

Run:

```bash
./tests/chezmoi-init-prompts.py
./tests/chezmoi-init-data.sh
```

Expected:

```text
chezmoi init prompt flow passed
chezmoi init data passed
```

- [ ] **Step 7: Make the existing render matrix use role-correct base data**

In `tests/chezmoi-render-config.sh`, replace the single `config_file` and
`base_data` setup with:

```bash
server_config_file="$tmp_dir/server-chezmoi.toml"
workstation_config_file="$tmp_dir/workstation-chezmoi.toml"
custom_config_file="$tmp_dir/custom-chezmoi.toml"
missing_config="$tmp_dir/missing.toml"

chezmoi -S "$source_dir" -c "$missing_config" execute-template --init \
    --file "$source_dir/.chezmoi.toml.tmpl" >"$server_config_file"
chezmoi -S "$source_dir" -c "$missing_config" execute-template --init \
    --promptChoice machine.role=workstation \
    --promptChoice secrets.provider=none \
    --promptBool encrypted_files.enabled=false \
    --file "$source_dir/.chezmoi.toml.tmpl" >"$workstation_config_file"
chezmoi -S "$source_dir" -c "$missing_config" execute-template --init \
    --promptChoice machine.role=workstation \
    --promptChoice identity.profile=custom \
    --promptString identity.git_name=Emergency \
    --promptString identity.git_email=emergency@example.invalid \
    --promptString identity.github_username=emergency \
    --promptChoice secrets.provider=none \
    --promptBool encrypted_files.enabled=false \
    --file "$source_dir/.chezmoi.toml.tmpl" >"$custom_config_file"

server_base_data=$(chezmoi -S "$source_dir" -c "$server_config_file" data)
workstation_base_data=$(chezmoi -S "$source_dir" -c "$workstation_config_file" data)
custom_base_data=$(chezmoi -S "$source_dir" -c "$custom_config_file" data)
```

Change `make_data` so its second argument is the role-correct base JSON:

```bash
make_data() {
    local output_file=$1
    local base_data=$2
    local role=$3
    local development=$4
    local homelab=$5
    local personal=$6
    local graphical=$7
    local provider=$8
    local encrypted=$9
    local xdg_root=${10}

    printf '%s\n' "$base_data" | jq \
        --arg role "$role" \
        --argjson development "$development" \
        --argjson homelab "$homelab" \
        --argjson personal "$personal" \
        --argjson graphical "$graphical" \
        --arg provider "$provider" \
        --argjson encrypted "$encrypted" \
        --arg xdg_root "$xdg_root" \
        '.machine.role = $role
         | .features = {
             development: $development,
             homelab: $homelab,
             personal: $personal,
             graphical: $graphical
           }
         | .secrets.provider = $provider
         | .encrypted_files.enabled = $encrypted
         | .xdg = {
             cache_home: ($xdg_root + "/cache"),
             config_home: ($xdg_root + "/config"),
             data_home: ($xdg_root + "/data"),
             state_home: ($xdg_root + "/state")
           }' >"$output_file"
}
```

Change `render_apply` so its second argument is the matching config:

```bash
render_apply() {
    local name=$1
    local config_file=$2
    local data_file=$3
    local ci=${4:-false}
    local destination="$tmp_dir/$name"
    mkdir -p "$destination"

    if [[ "$ci" == true ]]; then
        CI=1 chezmoi -S "$source_dir" -c "$config_file" \
            -D "$destination" --override-data-file "$data_file" apply \
            --dry-run --no-tty --force --exclude externals
    else
        chezmoi -S "$source_dir" -c "$config_file" \
            -D "$destination" --override-data-file "$data_file" apply \
            --dry-run --no-tty --force --exclude externals
    fi
}
```

Replace the fixture creation and render calls with:

```bash
server_data="$tmp_dir/server.json"
development_server_data="$tmp_dir/development-server.json"
homelab_server_data="$tmp_dir/homelab-server.json"
workstation_data="$tmp_dir/workstation.json"
custom_identity_data="$tmp_dir/custom-identity.json"
custom_xdg_data="$tmp_dir/custom-xdg.json"

make_data "$server_data" "$server_base_data" \
    server false false false false none false /tmp/chezmoi-server
make_data "$development_server_data" "$server_base_data" \
    server true false false false none false /tmp/chezmoi-development
make_data "$homelab_server_data" "$server_base_data" \
    server false true false false none false /tmp/chezmoi-homelab
make_data "$workstation_data" "$workstation_base_data" \
    workstation true true true true none false /tmp/chezmoi-workstation
make_data "$custom_identity_data" "$custom_base_data" \
    workstation true false true true none false /tmp/chezmoi-custom
make_data "$custom_xdg_data" "$workstation_base_data" \
    workstation true false true true none false /tmp/custom-xdg

render_apply server "$server_config_file" "$server_data"
render_apply development-server "$server_config_file" "$development_server_data"
render_apply homelab-server "$server_config_file" "$homelab_server_data"
render_apply workstation "$workstation_config_file" "$workstation_data"
render_apply custom-identity "$custom_config_file" "$custom_identity_data"
render_apply ci "$server_config_file" "$server_data" true
render_apply custom-xdg "$workstation_config_file" "$custom_xdg_data"
```

Replace the later render commands that used the old `"$config_file"` with
these exact commands:

```bash
server_config=$(<"$server_config_file")

custom_xdg=$(chezmoi -S "$source_dir" -c "$workstation_config_file" \
    execute-template --override-data-file "$custom_xdg_data" \
    --file "$source_dir/dot_config/fish/env.d/000-xdg.fish.tmpl")

ci_ignore=$(CI=1 chezmoi -S "$source_dir" -c "$server_config_file" \
    execute-template --override-data-file "$server_data" \
    --file "$source_dir/.chezmoiignore")

server_git=$(chezmoi -S "$source_dir" -c "$server_config_file" \
    execute-template --override-data-file "$server_data" \
    --file "$source_dir/dot_config/git/config.tmpl")
workstation_git=$(chezmoi -S "$source_dir" -c "$workstation_config_file" \
    execute-template --override-data-file "$workstation_data" \
    --file "$source_dir/dot_config/git/config.tmpl")

server_jj=$(chezmoi -S "$source_dir" -c "$server_config_file" \
    execute-template --override-data-file "$server_data" \
    --file "$source_dir/dot_config/jj/config.toml.tmpl")
workstation_jj=$(chezmoi -S "$source_dir" -c "$workstation_config_file" \
    execute-template --override-data-file "$workstation_data" \
    --file "$source_dir/dot_config/jj/config.toml.tmpl")
```

Add these identity assertions after the existing table assertions:

```bash
printf '%s\n' "$server_config" \
    | rg -q '^profile = "server-minimal"$'
printf '%s\n' "$server_config" \
    | rg -q '^git_email = "chianyungcode-server@local.invalid"$'

workstation_config=$(<"$workstation_config_file")
printf '%s\n' "$workstation_config" \
    | rg -q '^profile = "personal"$'

custom_config=$(<"$custom_config_file")
printf '%s\n' "$custom_config" \
    | rg -q '^profile = "custom"$'
printf '%s\n' "$custom_config" \
    | rg -q '^git_email = "emergency@example.invalid"$'
```

- [ ] **Step 8: Run the complete render tests**

Run:

```bash
./tests/chezmoi-init-prompts.py
./tests/chezmoi-init-data.sh
./tests/chezmoi-render-config.sh
```

Expected: all three commands exit `0` and end with their respective `passed`
messages.

- [ ] **Step 9: Commit the initialization behavior**

```bash
git add \
    chezmoi/.chezmoidata/accounts.toml \
    chezmoi/.chezmoi.toml.tmpl \
    tests/chezmoi-init-prompts.py \
    tests/chezmoi-init-data.sh \
    tests/chezmoi-render-config.sh
git commit -m "feat(chezmoi): make server init role-first"
```

---

### Task 2: Make Git and Jujutsu safe for the local-only server identity

**Files:**

- Create: `tests/chezmoi-vcs-local-commit.sh`
- Modify: `chezmoi/dot_config/git/config.tmpl`
- Modify: `chezmoi/dot_config/jj/config.toml.tmpl`

**Interfaces:**

- Consumes: `.identity.git_name`, `.identity.git_email`, `.identity.github_username`, `.identity.signing_key`, and `.secrets.provider`.
- Produces: valid Git configuration with optional GitHub username and signing.
- Produces: Jujutsu `signing.backend = "none"` and `signing.behavior = "drop"` whenever signing credentials are unavailable.
- Produces: executable test command `./tests/chezmoi-vcs-local-commit.sh`.

- [ ] **Step 1: Add the failing real-commit integration test**

Create `tests/chezmoi-vcs-local-commit.sh` with:

```bash
#!/usr/bin/env bash

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_root/chezmoi"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in chezmoi git jj rg; do
    command -v "$command_name" >/dev/null || {
        printf 'missing required command: %s\n' "$command_name" >&2
        exit 1
    }
done

config_file="$tmp_dir/chezmoi.toml"
chezmoi -S "$source_dir" -c "$tmp_dir/missing.toml" execute-template --init \
    --file "$source_dir/.chezmoi.toml.tmpl" >"$config_file"

git_config="$tmp_dir/gitconfig"
chezmoi -S "$source_dir" -c "$config_file" execute-template \
    --file "$source_dir/dot_config/git/config.tmpl" >"$git_config"

[[ $(git config --file "$git_config" --get user.name) == \
    chianyungcode-server ]]
[[ $(git config --file "$git_config" --get user.email) == \
    chianyungcode-server@local.invalid ]]
if git config --file "$git_config" \
    --get credential.https://github.com.username >/dev/null; then
    printf 'server Git config unexpectedly has a GitHub username\n' >&2
    exit 1
fi
if git config --file "$git_config" --get user.signingkey >/dev/null; then
    printf 'server Git config unexpectedly has a signing key\n' >&2
    exit 1
fi
if [[ $(git config --file "$git_config" --bool --get commit.gpgsign \
    2>/dev/null || true) == true ]]; then
    printf 'server Git config unexpectedly enables commit signing\n' >&2
    exit 1
fi

git_repo="$tmp_dir/git-repo"
mkdir -p "$git_repo" "$tmp_dir/home"
GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
    git -C "$git_repo" init -q
printf 'emergency\n' >"$git_repo/emergency.txt"
GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
    git -C "$git_repo" add emergency.txt
GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
    git -C "$git_repo" commit -q -m emergency
git_identity=$(
    GIT_CONFIG_GLOBAL="$git_config" GIT_CONFIG_NOSYSTEM=1 HOME="$tmp_dir/home" \
        git -C "$git_repo" log -1 --format='%an|%ae|%s'
)
[[ "$git_identity" == \
    'chianyungcode-server|chianyungcode-server@local.invalid|emergency' ]]

jj_config="$tmp_dir/jj-config.toml"
chezmoi -S "$source_dir" -c "$config_file" execute-template \
    --file "$source_dir/dot_config/jj/config.toml.tmpl" >"$jj_config"

[[ $(JJ_CONFIG="$jj_config" jj config list signing.backend \
    -T 'value ++ "\n"') == '"none"' ]]
[[ $(JJ_CONFIG="$jj_config" jj config list signing.behavior \
    -T 'value ++ "\n"') == '"drop"' ]]
if [[ -n $(JJ_CONFIG="$jj_config" jj config list signing.key 2>/dev/null) ]]; then
    printf 'server Jujutsu config unexpectedly has a signing key\n' >&2
    exit 1
fi

jj_repo="$tmp_dir/jj-repo"
JJ_CONFIG="$jj_config" jj git init "$jj_repo" >/dev/null
printf 'emergency\n' >"$jj_repo/emergency.txt"
JJ_CONFIG="$jj_config" jj -R "$jj_repo" describe -m emergency >/dev/null
jj_identity=$(
    JJ_CONFIG="$jj_config" jj -R "$jj_repo" log -r @ --no-graph \
        -T 'author.name() ++ "|" ++ author.email() ++ "|" ++ description.first_line() ++ "\n"'
)
[[ "$jj_identity" == \
    'chianyungcode-server|chianyungcode-server@local.invalid|emergency' ]]

if rg -q 'onepasswordRead|github_username.*chianyungcode' \
    "$git_config" "$jj_config"; then
    printf 'server VCS config unexpectedly contains secret-backed identity data\n' >&2
    exit 1
fi

printf 'chezmoi local VCS commits passed\n'
```

Make it executable:

```bash
chmod +x tests/chezmoi-vcs-local-commit.sh
```

- [ ] **Step 2: Run the VCS test and verify it fails at the unsafe consumer**

Run:

```bash
./tests/chezmoi-vcs-local-commit.sh
```

Expected: FAIL because the current Git template emits an empty GitHub username
block or because Jujutsu still selects SSH signing without a server key.

- [ ] **Step 3: Gate Git signing and the GitHub credential subsection**

At the top of `chezmoi/dot_config/git/config.tmpl`, immediately after the
introductory comments, add:

```gotemplate
{{- $signing_enabled := and (eq .secrets.provider "onepassword") (ne .identity.signing_key "") -}}
```

Replace the signing conditions in `[user]` and the commit-signing section with:

```gotemplate
[user]
    name = {{ .identity.git_name }}
    email = {{ .identity.git_email }}
    {{- if $signing_enabled }}
    signingkey = {{ onepasswordRead (index .secrets.git .identity.signing_key) }}
    {{- end }}

{{- if $signing_enabled }}
[gpg]
    format = ssh

[gpg "ssh"]
{{- if eq .chezmoi.os "darwin"}}
    program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
{{- end }}
{{- if eq .chezmoi.os "linux"}}
    program = "/opt/1Password/op-ssh-sign"
{{- end }}

[commit]
    gpgsign = true
{{- end }}
```

Replace the unconditional GitHub credential subsection with:

```gotemplate
{{- if ne .identity.github_username "" }}
[credential "https://github.com"]
    username = {{ .identity.github_username }}
{{- end }}
```

Keep the generic `[credential]` configuration unchanged; the design suppresses
profile-provided credentials but does not implement a hard push prohibition.

- [ ] **Step 4: Give Jujutsu an explicit unsigned fallback**

At the top of `chezmoi/dot_config/jj/config.toml.tmpl`, add:

```gotemplate
{{- $signing_enabled := and (eq .secrets.provider "onepassword") (ne .identity.signing_key "") -}}
```

Replace the existing `[signing]` table with:

```gotemplate
[signing]
{{- if $signing_enabled }}
  behavior = "own"
  backend = "ssh"
  key = "{{ onepasswordRead (index .secrets.git .identity.signing_key) }}"
{{- else }}
  behavior = "drop"
  backend = "none"
{{- end }}
```

This fallback also fixes custom or workstation profiles that deliberately use
`secrets.provider = "none"`.

- [ ] **Step 5: Run VCS and render verification**

Run:

```bash
./tests/chezmoi-vcs-local-commit.sh
./tests/chezmoi-render-config.sh
```

Expected:

```text
chezmoi local VCS commits passed
chezmoi render matrix passed
```

- [ ] **Step 6: Commit the VCS consumer changes**

```bash
git add \
    chezmoi/dot_config/git/config.tmpl \
    chezmoi/dot_config/jj/config.toml.tmpl \
    tests/chezmoi-vcs-local-commit.sh
git commit -m "fix(vcs): support local-only server identity"
```

---

### Task 3: Document server initialization and migration

**Files:**

- Create: `docs/06-server-initialization.md`
- Modify: `README.md`

**Interfaces:**

- Consumes: the final prompt flow and data keys from Tasks 1 and 2.
- Produces: operator instructions for fresh servers, existing servers, role changes, manual graphical override, and local emergency commits.

- [ ] **Step 1: Add the focused server initialization guide**

Create `docs/06-server-initialization.md` with:

```markdown
# Server Initialization

Chezmoi asks for the machine role before identity or feature choices. The
server path is optimized for VPS machines that host services and are not used
as daily workstations.

## Fresh initialization

Run:

```bash
chezmoi init --apply https://github.com/chianyungcode/dotfiles.git
```

Choose `server` for the first question. A fresh server then asks only:

1. whether to enable development tools;
2. whether to enable homelab tools.

Chezmoi stores these values automatically:

```toml
[data.identity]
profile = "server-minimal"
git_name = "chianyungcode-server"
git_email = "chianyungcode-server@local.invalid"
github_username = ""
signing_key = ""
github_token = ""

[data.features]
personal = false
graphical = false

[data.secrets]
provider = "none"

[data.encrypted_files]
enabled = false
```

`development` and `homelab` retain the answers selected during initialization.

## Local emergency commits

The server identity supports unsigned local Git and Jujutsu commits. It does
not provide a GitHub token, signing key, or push credential.

Inspect the active identity:

```bash
chezmoi data | jq '.machine, .identity, .features, .secrets, .encrypted_files'
git config --global --get-regexp '^user\.'
jj config list user
jj config list signing
```

Move an emergency Git commit to a workstation with a patch:

```bash
git format-patch -1 HEAD --stdout > emergency.patch
```

Copy `emergency.patch` to the workstation, inspect it, and apply it:

```bash
git am emergency.patch
```

The patch preserves `chianyungcode-server` as the author. The workstation
identity becomes the committer.

## Private repositories

Public clone and pull operations do not need credentials. If a server must read
a private repository, provision a separate read-only deploy key. Do not add a
personal GitHub token to `server-minimal`.

The profile does not technically block pushes. Existing SSH credentials or
agent forwarding can still authorize one, so avoid forwarding write-capable
credentials to hosting servers.

## Exceptional feature overrides

Server initialization sets `personal` and `graphical` to `false` without
prompting. An exceptional graphical server can be enabled after initialization
by editing the generated Chezmoi config:

```toml
[data.features]
graphical = true
```

Templates continue to use `features.graphical`, so the override is honored.
Running server initialization again restores `graphical = false`.

## Existing servers

An ordinary `chezmoi apply` does not regenerate the Chezmoi config. To adopt
the new identity, re-run initialization:

```bash
chezmoi init
chezmoi apply
```

Review the result before applying:

```bash
chezmoi data | jq '.machine, .identity, .features, .secrets, .encrypted_files'
chezmoi apply --dry-run --verbose
```

No migration script rewrites existing machines automatically.

## Changing roles

`machine.role` uses prompt-once state. To convert an existing machine, edit or
remove the stored role in the Chezmoi config, then run:

```bash
chezmoi init --prompt
```

When changing to `server`, Chezmoi replaces the prior identity with
`server-minimal`. When changing to `workstation`, Chezmoi rejects
`server-minimal` for that role and asks for `personal`, `secondary`, or
`custom`.
```

- [ ] **Step 2: Update the README initialization summary**

Replace the initialization explanation below `chezmoi init --apply` in
`README.md` with:

```markdown
   Initialization asks for the machine role first.

   - A `server` automatically uses the local-only `server-minimal` identity,
     disables personal and graphical features, uses no secrets provider, and
     disables Age-encrypted files. Only development and homelab capabilities
     are prompted.
   - A `workstation` prompts for its identity profile, capabilities, secrets
     provider, and Age-encrypted files.

   The server path does not require `op` or an Age identity. See
   [Server Initialization](./docs/06-server-initialization.md) for migration,
   exceptional overrides, and emergency local commits.
```

In the post-installation bullets, replace:

```markdown
- Enable `onepassword` or Age-encrypted files later by updating Chezmoi's configuration and applying again.
```

with:

```markdown
- Workstations can change their secrets provider or Age-encrypted file policy
  by updating Chezmoi's configuration and applying again. Server
  reinitialization restores both settings to their secretless defaults.
```

- [ ] **Step 3: Run the entire verification suite**

Run:

```bash
./tests/chezmoi-init-prompts.py
./tests/chezmoi-init-data.sh
./tests/chezmoi-render-config.sh
./tests/chezmoi-vcs-local-commit.sh
git diff --check
```

Expected: all four tests exit `0`, all four print `passed`, and
`git diff --check` prints nothing.

- [ ] **Step 4: Inspect the generated server data one final time**

Run:

```bash
verification_root=$(mktemp -d)
chezmoi -S chezmoi -c "$verification_root/missing.toml" \
    execute-template --init --file chezmoi/.chezmoi.toml.tmpl \
    >"$verification_root/chezmoi.toml"
chezmoi -S chezmoi -c "$verification_root/chezmoi.toml" data \
    | jq '{machine, identity, features, secrets, encrypted_files}'
```

Expected:

```json
{
  "machine": {
    "role": "server"
  },
  "identity": {
    "profile": "server-minimal",
    "git_name": "chianyungcode-server",
    "git_email": "chianyungcode-server@local.invalid",
    "github_username": "",
    "signing_key": "",
    "github_token": ""
  },
  "features": {
    "development": false,
    "homelab": false,
    "personal": false,
    "graphical": false
  },
  "secrets": {
    "provider": "none"
  },
  "encrypted_files": {
    "enabled": false
  }
}
```

Remove the validated temporary directory:

```bash
rm -r "$verification_root"
```

- [ ] **Step 5: Commit the documentation**

```bash
git add README.md docs/06-server-initialization.md
git commit -m "docs(chezmoi): explain server initialization"
```

- [ ] **Step 6: Confirm the branch is ready for review**

Run:

```bash
git status --short
git log -4 --oneline
```

Expected: `git status --short` prints nothing. The log shows the design commit
followed by the initialization, VCS, and documentation commits from this plan.
