# Chezmoi Agnostic Configuration Refactor Plan

<!-- markdownlint-disable MD013 -->

## Status

- **State:** Implemented; local render matrix verified
- **Scope:** Chezmoi configuration data model and its consumers
- **Primary target:** Portable personal dotfiles across Ubuntu servers, Arch
  Linux, macOS, and CI
- **Native entry point:** `chezmoi init --apply <repository-url>`

## Objective

Refactor `chezmoi/.chezmoi.toml.tmpl` into a smaller, clearer, capability-driven
configuration that does not assume a specific operating system, Linux
distribution, account, secrets provider, or optional CLI tool.

Chezmoi should continue detecting operating-system details through built-in data
such as:

```go
{{ .chezmoi.os }}
{{ .chezmoi.osRelease.id }}
{{ .chezmoi.arch }}
```

The generated configuration should describe only the user's identity, the
machine's role, enabled capabilities, secrets policy, and portable path
defaults.

## Decisions Already Made

1. Do not add a custom bootstrap wrapper.
2. Use the native chezmoi initialization flow.
3. Keep operating-system detection out of user prompts.
4. Support a secretless Ubuntu server installation.
5. Use machine roles only to express intent and choose initial defaults.
6. Use independent capability flags to control package and configuration
   selection.
7. Use structured, consistently named template data.

## Non-goals

- Rewriting all package installation scripts in the same change.
- Making this personal repository a generic dotfiles framework for unrelated
  users.
- Replacing chezmoi's native initialization or script lifecycle.
- Moving application configuration out of chezmoi.
- Adding Ubuntu-specific fields to the global configuration model.

## Problems in the Current Model

### Flat and mixed data

The current `[data]` table combines identity, machine classification, CI state,
secrets, and XDG paths:

```toml
git_email
git_user
github_user
dev_computer
homelab_member
is_ci_workflow
personal_computer
use_secrets
xdgCacheDir
xdgConfigDir
xdgDataDir
xdgStateDir
```

These values have different responsibilities and lifecycles but appear as one
undifferentiated group.

### Identity can become inconsistent

Git email, Git name, and GitHub username are selected independently. This
permits combinations that do not represent a real account.

The name `git_user` is also ambiguous. It is used as Git's `user.name`, a GitHub
account identifier, a signing-key selector, and part of a Jujutsu bookmark
expression.

### Machine roles are expressed only as booleans

The booleans are flexible, but they do not communicate the machine's main
purpose. A server can be a development machine and a homelab member at the same
time, so one rigid profile is also insufficient.

### Secrets and encryption are conflated

`use_secrets` primarily controls 1Password templates, while Age encryption is
configured unconditionally. A secretless machine can therefore still encounter
encrypted files that require an Age identity.

### CI is persisted as machine configuration

`is_ci_workflow` describes the current execution environment, not the long-term
identity of a machine. It should be derived from `CI` or supplied temporarily
during a test.

### Paths use inconsistent names

XDG fields use camelCase while most other data uses snake_case. The current
template also repeats nearly identical path-selection blocks.

### Optional diff tooling is global

The generated config always selects `difft`, even on machines where it is not
installed, including a minimal Ubuntu server.

## Target Data Model

The target model uses nested TOML namespaces and snake_case names:

```toml
[data.identity]
profile = "personal"
git_name = "chianyungcode"
git_email = "cnytechcode@gmail.com"
github_username = "chianyungcode"

[data.machine]
role = "server"

[data.features]
development = false
homelab = false
personal = false
graphical = false

[data.secrets]
provider = "none"

[data.encrypted_files]
enabled = false

[data.xdg]
cache_home = "/home/user/.cache"
config_home = "/home/user/.config"
data_home = "/home/user/.local/share"
state_home = "/home/user/.local/state"
```

### Identity

Use one coherent identity profile rather than three independent account prompts.

Suggested source data:

```toml
# chezmoi/.chezmoidata/accounts.toml

[accounts.personal]
git_name = "chianyungcode"
git_email = "cnytechcode@gmail.com"
github_username = "chianyungcode"

[accounts.secondary]
git_name = "seraphynee"
git_email = "seraphyne31@gmail.com"
github_username = "seraphynee"
```

The configuration template should prompt for an identity profile and copy its
related fields together. A `custom` option can prompt for raw values when
needed.

Account-specific signing keys should become explicit account data instead of
conditionals that compare usernames in Git and Jujutsu templates.

### Machine role and capabilities

`machine.role` expresses the machine's primary purpose:

- `server`: primarily runs services or remote workloads
- `workstation`: primarily used interactively for daily work

`features` expresses independently selectable capabilities:

- `development`
- `homelab`
- `personal`
- `graphical`

The role must not describe hardware form factor or whether a GUI is installed. A
laptop and a physical desktop can both be workstations. The `features.graphical`
capability controls graphical applications and configuration independently.

The role should provide convenient prompt defaults during initialization, but
package and configuration templates should depend on explicit capability flags.
This model allows a server to be a development machine, a homelab member, or
even graphical without introducing a distribution-specific profile.

CI is runtime context, not a machine role. It must be derived from the `CI`
environment variable or supplied as a temporary test override.

### Secrets policy

Separate secret lookup from encrypted source files:

```toml
[data.secrets]
provider = "none" # none or onepassword

[data.encrypted_files]
enabled = false
```

Rules:

1. `provider = "none"` must not call `onepasswordRead`.
2. `encrypted_files.enabled = false` must ignore every encrypted target that
   needs the personal Age identity.
3. Emit `[age]` configuration only when encrypted files are enabled.
4. Do not hardcode a personal Age identity path or recipient into the universal
   path unless the feature is enabled.
5. Keep the secrets-provider decision independent from the machine role.

### XDG paths

Prefer existing environment values and fall back to standard paths:

```go
{{- $xdgCache := env "XDG_CACHE_HOME" | default (joinPath .chezmoi.homeDir ".cache") -}}
{{- $xdgConfig := env "XDG_CONFIG_HOME" | default (joinPath .chezmoi.homeDir ".config") -}}
{{- $xdgData := env "XDG_DATA_HOME" | default (joinPath .chezmoi.homeDir ".local/share") -}}
{{- $xdgState := env "XDG_STATE_HOME" | default (joinPath .chezmoi.homeDir ".local/state") -}}
```

Templates should use:

```go
{{ .xdg.cache_home }}
{{ .xdg.config_home }}
{{ .xdg.data_home }}
{{ .xdg.state_home }}
```

### Runtime context

Do not persist `is_ci_workflow` as ordinary machine data.

Preferred behavior:

```go
{{- $isCI := ne (env "CI") "" -}}
```

If a test requires an explicit override, pass it with chezmoi's temporary
override-data mechanism rather than treating it as user configuration.

### Diff behavior

Remove the unconditional `[diff]` block from the portable configuration.

Initial behavior should use chezmoi's built-in diff. A user can add `difft`
through a machine-local config override after the binary is installed.

## Field Migration Map

| Current field       | Target field               | Notes                                  |
| ------------------- | -------------------------- | -------------------------------------- |
| `git_user`          | `identity.git_name`        | Remove GitHub/signing-key overloading  |
| `git_email`         | `identity.git_email`       | Selected through identity profile      |
| `github_user`       | `identity.github_username` | Use an explicit platform-specific name |
| `dev_computer`      | `features.development`     | Capability, not machine identity       |
| `homelab_member`    | `features.homelab`         | Capability                             |
| `personal_computer` | `features.personal`        | Capability                             |
| `is_ci_workflow`    | derived runtime value      | Read `CI` or use a temporary override  |
| `use_secrets`       | `secrets.provider`         | `none` or `onepassword`                |
| implicit Age usage  | `encrypted_files.enabled`  | Independent from 1Password             |
| `xdgCacheDir`       | `xdg.cache_home`           | Standard XDG terminology               |
| `xdgConfigDir`      | `xdg.config_home`          | Standard XDG terminology               |
| `xdgDataDir`        | `xdg.data_home`            | Standard XDG terminology               |
| `xdgStateDir`       | `xdg.state_home`           | Standard XDG terminology               |

## Affected Consumers

The migration must update every template that reads the current flat fields.

### Identity consumers

- `chezmoi/dot_config/git/config.tmpl`
- `chezmoi/dot_config/jj/config.toml.tmpl`
- `chezmoi/dot_config/fish/env.d/private_030-secrets-op.fish.tmpl`
- `chezmoi/dot_config/zsh/env.d/private_030-secrets-op.sh.tmpl`

### Feature consumers

- All package-installation templates under `chezmoi/.chezmoiscripts/`
- `chezmoi/.chezmoiexternals/my-project.toml.tmpl`
- Any templates gated by development, personal, or homelab status

### Secrets consumers

- `chezmoi/.chezmoiignore`
- `chezmoi/.chezmoiexternals/my-project.toml.tmpl`
- `chezmoi/.chezmoiscripts/run_onchange_after_15-create-ssh-keys.sh.tmpl`
- `chezmoi/private_dot_opencommit.tmpl`
- `chezmoi/dot_ssh/config.tmpl`
- `chezmoi/dot_codex/private_config.toml.tmpl`
- `chezmoi/dot_config/opencode/private_opencode.jsonc.tmpl`
- `chezmoi/dot_config/zed/private_settings.json.tmpl`
- Zsh and Fish secret environment templates

### XDG consumers

- Zsh history and completion configuration
- Bash history configuration
- Nano configuration
- Fish and Zsh chezmoi aliases
- Shared script utility templates
- Installer scripts that write cache or data files

## Migration Strategy

Use an incremental migration so the repository remains renderable between
commits.

### Phase 0: Capture the current behavior

1. Record representative generated data for:
   - macOS personal development workstation
   - Arch Linux personal development workstation
   - Ubuntu 24.04 secretless server
   - CI
2. List every current encrypted source target.
3. Record expected installed files and scripts for each platform.
4. Confirm the current working copy is clean before refactoring.

Deliverable: a baseline test matrix and expected output list.

### Phase 1: Introduce structured data alongside compatibility fields

1. Add `chezmoi/.chezmoidata/accounts.toml`.
2. Refactor `.chezmoi.toml.tmpl` to select one identity profile.
3. Add nested `identity`, `machine`, `features`, `secrets`, `encrypted_files`,
   and `xdg` tables.
4. Temporarily continue emitting the old flat fields with the same values.

Deliverable: old consumers still work while the new data model is visible
through `chezmoi data`.

### Phase 2: Migrate identity and feature consumers

1. Replace `.git_user`, `.git_email`, and `.github_user` references.
2. Replace the old machine booleans with `.features.*` references.
3. Move signing-key selection into identity/account data.
4. Verify Git and Jujutsu output for each identity profile.

Deliverable: no consumer depends on the old identity or role fields.

### Phase 3: Separate secrets and encryption

1. Replace `use_secrets` checks with a provider comparison.
2. Audit and classify all encrypted source files.
3. Update `.chezmoiignore` so a secretless machine never needs an Age identity.
4. Render `[age]` configuration only when encrypted files are enabled.
5. Test `provider = "none"` without `op` installed.
6. Test the 1Password path independently.

Deliverable: `chezmoi init --apply` succeeds on a fresh server without Age or
1Password.

### Phase 4: Normalize XDG paths and runtime context

1. Derive XDG values from environment variables with standard fallbacks.
2. Migrate all path consumers to `.xdg.*_home`.
3. Derive CI state from the environment or a temporary override.
4. Remove persistent `is_ci_workflow` data.

Deliverable: custom XDG environments and default home-directory layouts both
render correctly.

### Phase 5: Remove compatibility fields and optional global tools

1. Confirm no source template references the old fields.
2. Remove compatibility values from the generated config.
3. Remove the unconditional `difft` configuration.
4. Format the TOML template and generated config.

Deliverable: the generated configuration contains only the new structured model.

### Phase 6: End-to-end verification and documentation

1. Run the native installation command in a clean Ubuntu 24.04 VM.
2. Verify a second `chezmoi apply` is idempotent.
3. Test macOS and Arch Linux rendering.
4. Update GitHub Actions to test the real initialization flow.
5. Update the root README with profile selection and troubleshooting.

Deliverable: the documented native command reproduces the tested result.

## Validation Matrix

| Platform     | Role        | Graphical | Development | Secrets provider | Encrypted files | Required result                                          |
| ------------ | ----------- | --------: | ----------: | ---------------- | --------------: | -------------------------------------------------------- |
| Ubuntu 24.04 | server      |     false |       false | none             |           false | Basic server setup succeeds                              |
| Ubuntu 24.04 | server      |     false |        true | none             |           false | Development package path succeeds                        |
| Arch Linux   | workstation |      true |        true | onepassword      |            true | Existing workstation behavior is preserved               |
| macOS        | workstation |      true |        true | onepassword      |            true | Homebrew and personal configuration are preserved        |
| CI           | derived     |     false |       false | none             |           false | Rendering and apply complete without private credentials |

## Verification Commands

Use a temporary destination or test machine when validating rendered state.

```bash
chezmoi data
chezmoi doctor
chezmoi execute-template '{{ .identity | toJson }}'
chezmoi execute-template '{{ .features | toJson }}'
chezmoi execute-template '{{ .secrets | toJson }}'
chezmoi execute-template '{{ .xdg | toJson }}'
chezmoi apply --dry-run --verbose
```

After migration, search for legacy references:

```bash
rg '\.(git_user|git_email|github_user|dev_computer|homelab_member|personal_computer|is_ci_workflow|use_secrets|xdgCacheDir|xdgConfigDir|xdgDataDir|xdgStateDir)\b' chezmoi
```

The search should return no active template consumers before compatibility
fields are removed.

The repository-level render matrix exercises the secretless server,
development server, graphical workstation, CI, and custom-XDG paths without
modifying the real destination:

```bash
./tests/chezmoi-render-config.sh
```

Clean Ubuntu, Arch, and macOS machine validation remains environment-specific;
the matrix does not claim to replace those platform runs.

## Risks and Mitigations

### Breaking every template at once

**Risk:** Renaming flat fields immediately can make chezmoi unable to render.

**Mitigation:** Emit old and new fields together until consumers are migrated.

### Losing access to encrypted configuration

**Risk:** Incorrect Age conditions can hide required files or require a missing
key.

**Mitigation:** Inventory encrypted files first and test enabled and disabled
modes separately.

### Changing package-selection behavior

**Risk:** A role or capability mapping can accidentally install fewer or more
packages.

**Mitigation:** Compare rendered package arrays against the Phase 0 baseline.

### Identity/signing regressions

**Risk:** Git or Jujutsu signing can use the wrong account key.

**Mitigation:** Store signing configuration directly in each account profile and
verify generated configs.

### Custom XDG environments

**Risk:** Existing machines may already have non-default XDG variables.

**Mitigation:** Prefer environment values before applying fallback paths.

## Acceptance Criteria

- [x] `.chezmoi.toml.tmpl` is organized by identity, machine, features, secrets,
      encryption, and XDG paths.
- [x] All generated data uses consistent snake_case names.
- [x] Operating-system and distribution values come from `.chezmoi` built-in
      data.
- [x] One identity choice produces a coherent Git name, email, and GitHub
      username.
- [x] Git and Jujutsu do not select signing keys by comparing hardcoded
      usernames.
- [x] `machine.role` accepts only `server` or `workstation`.
- [x] The role selects initial defaults but does not directly control package
      installation.
- [x] Independent capability flags can describe all current machines.
- [x] `features.graphical` controls GUI-related packages and configuration
      independently from the role.
- [x] 1Password usage and Age-encrypted files are independently configurable.
- [x] Secretless Ubuntu initialization does not require `op` or an Age identity.
- [x] XDG paths respect existing environment variables.
- [x] CI state is not stored as permanent user configuration.
- [x] The generated config does not require `difft`.
- [x] No active template references a legacy flat field.
- [ ] Ubuntu 24.04, Arch Linux, macOS, and CI validation paths pass.
- [ ] A second `chezmoi apply` completes successfully.
- [x] The README documents the verified native initialization command.

## Decisions Recorded During Implementation

1. `git_name` remains the existing account handle so Git, GitHub credentials,
   and Jujutsu bookmark names stay coherent.
2. Secretless servers do not require encrypted files; encrypted targets are an
   explicit opt-in separate from the secrets provider.
3. The existing personal Age recipient and identity path are emitted only when
   encrypted files are enabled.
4. `features.personal` remains broad for this personal repository; graphical
   software is independently controlled by `features.graphical`.
5. Identity profiles include 1Password lookup keys for Git signing and GitHub
   tokens; custom identities leave those optional references empty.

Resolve these questions before Phase 1 so the initial target model does not
require another immediate rename.
