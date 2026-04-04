# Security Review

This document summarizes security and maintainability findings from a review of this Chezmoi-based dotfiles repository.

## Overview

The repository is primarily a personal dotfiles and workstation automation setup using Chezmoi. It includes shell configuration, SSH configuration, package/install scripts, and app/tool configuration that integrates with 1Password-managed secrets.

Overall, the repo does a few things well:
- uses 1Password references instead of committing raw secrets
- has pre-commit protections such as `gitleaks` and `detect-private-key`
- separates templated and encrypted content reasonably well

The most important issues are around SSH trust policy, secret exposure scope, and installer supply-chain safety.

## Findings

### High

#### 1. Global SSH host verification is disabled

- File: `chezmoi/dot_ssh/config.tmpl:42`
- Current setting: `StrictHostKeyChecking no`

This disables SSH host key verification for all hosts under `Host *`. In practice, SSH will continue even when a host key is new, unexpected, or changed. That weakens one of SSH's main defenses against man-in-the-middle attacks.

Impact:
- a spoofed or intercepted SSH endpoint is more likely to be trusted silently
- host key changes that should be treated as suspicious may go unnoticed

Recommendation:
- replace with `StrictHostKeyChecking accept-new` for a safer default
- consider adding `UpdateHostKeys yes`
- only relax host verification for narrowly scoped ephemeral/dev hosts if truly needed

---

### Medium

#### 2. Agent forwarding is enabled for some hosts

- File: `chezmoi/dot_ssh/config.tmpl:27`
- Current setting rendered per host: `ForwardAgent yes`

Agent forwarding can be useful for bastion/jump-host workflows, but it increases risk if a remote host is compromised. A hostile host may abuse the forwarded agent to authenticate onward as the local user.

Impact:
- lateral movement risk from compromised SSH targets
- broader blast radius for workstation credentials

Recommendation:
- keep the default as disabled
- enable only for explicitly trusted hosts that require it
- document why each forwarded host needs it

#### 3. Several installers execute remote scripts directly

Files:
- `chezmoi/.chezmoiscripts/run_before_00-install-pre-requisites.sh.tmpl:9`
- `chezmoi/.chezmoiscripts/run_before_02-install-uv.sh.tmpl:59`
- `chezmoi/.chezmoiscripts/run_after_30-instal-atuin.sh.tmpl:56`
- `others/macos/shell-script/curl-installer.sh:16`
- `others/macos/shell-script/curl-installer.sh:28`
- `others/macos/shell-script/curl-installer.sh:68`

Patterns found:
- `curl ... | sh`
- `curl ... | bash`
- `/bin/bash -c "$(curl ...)"`

This is a supply-chain risk and makes installs less auditable and less reproducible.

Impact:
- remote code execution trust is delegated to the current network path and upstream endpoint
- harder to pin or verify exact installed content

Recommendation:
- prefer package-manager installs when available
- otherwise download to a file, verify checksum/signature, then execute
- pin versions where possible

#### 4. Secrets are exposed too broadly across shell sessions and config files

Examples:
- `chezmoi/dot_config/zsh/env.d/private_030-secrets-op.sh.tmpl:4`
- `chezmoi/dot_config/fish/env.d/private_030-secrets-op.fish.tmpl:4`
- `chezmoi/dot_config/opencode/private_opencode.jsonc.tmpl:8`
- `chezmoi/dot_codex/private_config.toml.tmpl:20`
- `chezmoi/private_dot_opencommit.tmpl:2`

Although the repository does not hardcode raw secrets directly in source, several templates render secrets into:
- global shell environment variables
- app config files stored in plaintext
- tool-specific config files on disk

This is not automatically wrong, but it increases the exposure surface.

Impact:
- secrets may be inherited by child processes
- secrets may be exposed through logs, crash dumps, diagnostics, or accidental process inspection
- secrets stored in plaintext config files may be included in backups/snapshots/sync

Recommendation:
- prefer per-app or per-command injection over global shell exports
- keep app-specific tokens scoped to the app that needs them
- avoid ambient credentials in every shell unless there is a strong productivity reason

#### 5. API keys are embedded in URL query strings

Files:
- `chezmoi/dot_config/opencode/private_opencode.jsonc.tmpl:8`
- `chezmoi/dot_config/opencode/private_opencode.jsonc.tmpl:49`
- `chezmoi/dot_codex/private_config.toml.tmpl:23`
- `chezmoi/dot_codex/private_config.toml.tmpl:35`

Examples:
- `apiKey=...`
- `tavilyApiKey=...`

Query-string secrets are more likely to leak through logs, telemetry, proxy diagnostics, copied URLs, and debugging output than secrets carried in headers or environment variables.

Recommendation:
- move these to headers or env-based runtime configuration if supported by the target tool/server

---

### Low

#### 6. SSH key creation uses `echo` for key material

- File: `chezmoi/.chezmoiscripts/run_onchange_after_15-create-ssh-keys.sh.tmpl:19`
- File: `chezmoi/.chezmoiscripts/run_onchange_after_15-create-ssh-keys.sh.tmpl:27`

Using `echo` to write key material can be brittle because of newline behavior and escaping edge cases.

Recommendation:
- use `printf '%s'`
- set `umask 077` before writing private material

#### 7. Antidote bootstrap fallback appears broken

- File: `chezmoi/dot_config/zsh/conf.d/004-plugin-manager.zsh.tmpl:43`

After cloning antidote, the script still sources `"$antidote_script"` even though that variable is not set in the fallback branch. This is more of a reliability/maintainability issue than a direct security issue, but broken bootstrap paths often lead to ad hoc manual recovery steps.

Recommendation:
- set the cloned script path explicitly before sourcing

#### 8. Global shell secret export has at least one likely logic bug

Files:
- `chezmoi/dot_config/zsh/env.d/private_030-secrets-op.sh.tmpl:9`
- `chezmoi/dot_config/fish/env.d/private_030-secrets-op.fish.tmpl:9`
- `chezmoi/.chezmoi.toml.tmpl:19`

The templates check for `chianyung_code`, but the configured choice appears to be `chianyungcode`. This may cause `GITHUB_TOKEN` not to be exported as intended for that identity.

Recommendation:
- align the username values across templates and data

## Secret Exposure Review

The current repo uses a mix of:
- global shell exports
- plaintext rendered app config
- public metadata/reference values

Recommended classification:

### Keep app-scoped or on-demand
- `GITHUB_TOKEN`
- `OPENROUTER_OPENCODE_APIKEY`
- `CONTEXT7_MCP_API_KEY`
- `WAKATIME_API_KEY`
- `APIDOG_ACCESS_TOKEN`
- `OCO_API_KEY`

### Migrate away from query string transport
- `ref_apikey`
- `tavily_apikey`

### Low concern / acceptable as-is
- SSH signing public keys in Git/JJ config

## Prioritized Remediation Plan

1. Change SSH default from `StrictHostKeyChecking no` to `accept-new`
2. Remove secrets from URL query strings
3. Reduce global shell exports for app-specific tokens
4. Narrow agent forwarding to the minimum required hosts
5. Replace direct `curl | sh` install flows where feasible
6. Fix template inconsistencies and bootstrap reliability issues

## Notes

This review did not find raw committed secrets in normal source files. The biggest concerns are around:
- SSH trust defaults
- token exposure scope
- supply-chain safety in install scripts
