# Role-First Server Identity Design

## Summary

Chezmoi initialization will ask for the machine role before any identity
question. A server will receive a dedicated `server-minimal` identity without
prompting for an identity profile. It will also use secretless, non-graphical,
and non-personal defaults without prompting for those choices.

The server identity exists only to keep local Git and Jujutsu operations valid
for emergency changes. It does not provide credentials, signing keys, GitHub
tokens, or a supported push workflow.

## Goals

- Make the first initialization question describe the machine's purpose.
- Keep the common VPS initialization path short and predictable.
- Allow emergency local Git and Jujutsu commits on a server.
- Keep server commits distinct from normal workstation commits.
- Prevent the server path from requiring 1Password or an Age identity.
- Preserve capability choices for development and homelab servers.
- Preserve the existing workstation identity and secrets workflow.
- Reconcile identity safely when a machine changes role.

## Non-Goals

- Prevent every possible `git push` or `jj git push` invocation.
- Provision server deployment credentials.
- Manage read-only deploy keys for private repositories.
- Create a different identity profile for every server hostname.
- Treat `server-minimal` as a GitHub account or automated service identity.
- Remove the ability to override feature data manually after initialization.

## Initialization Flow

The template resolves data in this order:

1. Resolve `machine.role`.
2. Resolve an identity allowed for that role.
3. Resolve the role-appropriate feature choices.
4. Resolve the secrets provider and Age-encrypted file policy.
5. Render the Chezmoi configuration.

The resulting prompt flow is:

```text
Choose machine role
├── server
│   ├── identity.profile = server-minimal
│   ├── Enable development tools? (default: false)
│   ├── Enable homelab tools? (default: false)
│   ├── features.personal = false
│   ├── features.graphical = false
│   ├── secrets.provider = none
│   └── encrypted_files.enabled = false
└── workstation
    ├── Choose identity profile
    ├── Enable development tools? (default: true)
    ├── Enable homelab tools? (default: false)
    ├── Enable personal tools? (default: true)
    ├── Enable graphical tools? (default: true)
    ├── Choose secrets provider (default: onepassword)
    └── Enable Age-encrypted files? (default: true)
```

The server path therefore asks only three questions on a fresh initialization:
machine role, development tools, and homelab tools.

## Server Identity

The shared account data will define:

```toml
[accounts.server-minimal]
git_name = "chianyungcode-server"
git_email = "chianyungcode-server@local.invalid"
github_username = ""
signing_key = ""
github_token = ""
```

The generated Chezmoi data will still contain the complete identity schema:

```toml
[data.identity]
profile = "server-minimal"
git_name = "chianyungcode-server"
git_email = "chianyungcode-server@local.invalid"
github_username = ""
signing_key = ""
github_token = ""
```

Using a complete schema keeps consumer templates predictable. The `.invalid`
address explicitly communicates that the identity is local-only and must not be
treated as a deliverable or GitHub-associated address.

The hostname is not added to `git_name`. A stable identity avoids creating an
unbounded account list or unusual per-host author names. When the origin machine
matters, the operator can include its hostname in the emergency commit body.

## Git and Jujutsu Behavior

Both Git and Jujutsu will render their user name and email from
`data.identity`, so `server-minimal` can create valid local commits.

Consumer templates must handle empty optional account fields:

- Render the GitHub-specific credential block only when
  `identity.github_username` is non-empty.
- Read a signing key only when the selected secrets provider supports it and
  `identity.signing_key` is non-empty.
- Read a GitHub token only when `identity.github_token` is non-empty.
- Do not enable Git or Jujutsu commit signing for `server-minimal`.

The server profile supplies no push credential. Public clone and pull operations
remain possible. Private read access, if later required, must use a separately
managed read-only deploy key.

This design does not enforce a hard push prohibition. Existing credentials,
SSH agent forwarding, or manually installed authentication can still authorize
a push. That behavior is deliberately outside identity-profile policy.

An emergency commit can be moved to a workstation using a patch, bundle, or
another explicit transfer workflow. Applying it on a workstation preserves
`chianyungcode-server` as the author while recording the workstation identity
as the committer.

## Features and Secrets

Role controls the initialization experience, while feature values remain the
data consumed by package and target templates.

For a server:

```toml
[data.features]
development = false # prompted, with false as the default
homelab = false     # prompted, with false as the default
personal = false
graphical = false

[data.secrets]
provider = "none"

[data.encrypted_files]
enabled = false
```

`development` and `homelab` remain prompts because they describe valid server
capabilities. `personal` and `graphical` are assigned automatically because
they are not part of the normal hosting-server use case.

The generated fields remain present even when their values are disabled. This
preserves a stable data schema and prevents missing-key failures in consumers.

After initialization, an exceptional graphical server can be enabled by
manually setting `features.graphical = true`. Templates must continue to gate
graphical targets on that feature rather than directly on `machine.role`.
Re-running initialization with the server role restores the role-managed value
to `false`.

The same rule applies to other automatically managed server values:
`features.personal`, `secrets.provider`, and `encrypted_files.enabled` return to
their server defaults when initialization regenerates the configuration.

## Role and Profile Reconciliation

The generated configuration must satisfy these invariants:

- `machine.role = "server"` implies
  `identity.profile = "server-minimal"`.
- `machine.role = "workstation"` must not retain `server-minimal`.
- A known workstation profile remains unchanged across workstation
  reinitialization.
- An unknown profile fails with a clear error instead of producing blank
  identity fields or an account lookup failure.

The transition behavior is:

| Previous state | Requested role | Result |
| --- | --- | --- |
| Server | Server | Reuse `server-minimal` without an identity prompt |
| Workstation | Workstation | Reuse the known workstation profile |
| Server | Workstation | Prompt for `personal`, `secondary`, or `custom` |
| Workstation | Server | Replace the previous identity with `server-minimal` |

Because `machine.role` currently uses a prompt-once value, changing roles on an
existing machine requires explicitly changing or removing the stored role
before re-running initialization. Once the new role reaches the template, the
identity reconciliation above is automatic.

For workstation role resolution:

- A missing profile opens the normal workstation profile prompt.
- `personal`, `secondary`, and `custom` are accepted.
- `server-minimal` triggers the workstation profile prompt.
- Any other existing value stops initialization with a descriptive error.

For the server role, the template ignores any prior workstation identity and
selects `server-minimal` directly.

## Existing Machines and Migration

Changing `.chezmoi.toml.tmpl` does not rewrite the active Chezmoi configuration
during an ordinary `chezmoi apply`. Existing machines retain their current
values until the operator re-runs initialization or edits the generated
configuration manually.

Documentation must explain:

- the new role-first prompt order;
- the automatic server values;
- the local-only purpose of `server-minimal`;
- how an existing server adopts the new profile;
- how to change a stored role safely;
- that reinitializing a server restores its automatically managed defaults.

No automatic migration script will rewrite existing machine configuration.

## Error Handling

- Missing `accounts.server-minimal` data is a template error.
- An unknown workstation profile produces a descriptive error naming the
  invalid profile and the allowed choices.
- Empty Git name or email in any selected account is a template error.
- Empty optional GitHub username, signing key, and token fields are valid and
  suppress their corresponding configuration.
- A server render must not call `onepasswordRead` or require an Age identity.
- Git and Jujutsu configuration must remain syntactically valid when all
  optional server identity fields are empty.

## Verification

The render matrix will cover at least:

1. Minimal secretless server.
2. Development server.
3. Homelab server.
4. Personal graphical workstation.
5. Workstation custom identity.
6. Server-to-workstation identity reconciliation.
7. Workstation-to-server identity reconciliation.
8. Unknown workstation profile failure.
9. CI rendering.
10. Custom XDG paths.

Server assertions will verify:

- `identity.profile` is `server-minimal`;
- the server name and email are present;
- `features.personal` and `features.graphical` are `false`;
- `secrets.provider` is `none`;
- `encrypted_files.enabled` is `false`;
- no Age configuration is emitted;
- no GitHub credential username is emitted;
- no OnePassword-backed signing or token lookup occurs;
- workstation-only diff tooling remains disabled;
- Git accepts the rendered configuration and can create a local commit;
- Jujutsu accepts the rendered configuration and can create a local commit
  without a signing key.

Workstation assertions will verify that the existing personal, secondary, and
custom identity behavior remains available and that workstation defaults are
unchanged.

An initialization integration test must capture the interactive questions and
verify their order for both roles. The server case must verify that identity,
personal, graphical, secrets-provider, and Age questions never appear. The
implementation must not rely only on source-order inspection to validate this
behavior.

## Acceptance Criteria

- The first fresh-init prompt is the machine role.
- A fresh server init asks only for role, development, and homelab choices.
- A server stores the complete `server-minimal` identity automatically.
- A server automatically stores `personal = false`, `graphical = false`,
  `provider = "none"`, and `encrypted_files.enabled = false`.
- Git and Jujutsu can make unsigned local commits under the server identity.
- Server rendering requires neither 1Password nor an Age identity.
- Workstation initialization retains its identity, feature, secrets, and Age
  choices.
- Role transitions reconcile identity without retaining an invalid profile.
- Existing machines are not silently rewritten by `chezmoi apply`.
