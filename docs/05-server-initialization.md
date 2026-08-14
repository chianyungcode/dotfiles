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
