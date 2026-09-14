# Remote Server Configuration Flow

This guide explains how to configure SSH access to remote servers using
1Password and Chezmoi for secure key management and automated configuration.

## Overview

The remote server configuration flow integrates 1Password for secure storage of
SSH keys and server credentials, with Chezmoi managing the SSH configuration
automatically. This approach provides:

- **Security**: SSH keys are stored securely in 1Password
- **Automation**: SSH config is generated automatically
- **Flexibility**: Support for both regular and Tailscale connections
- **Portability**: Easy migration between machines

## Prerequisites

Before starting, ensure you have:

- [ ] 1Password CLI installed (`op` command available)
- [ ] 1Password account with SSH key storage capability
- [ ] Chezmoi initialized and configured
- [ ] Access to the remote server(s) you want to configure

## Step-by-Step Configuration

### Step 1: Create 1Password Items

Create 1Password items using the single provided template. One template
covers both connection methods: fill `hostname`, `tailscale_ip`, or both,
and flip `via_tailscale` in the Chezmoi data to switch between them
without recreating the item.

```bash
op item create --template remote-server.json
```

> **Note**: When using Tailscale, the hostname typically uses Tailscale's Magic
> DNS format (e.g., `server-name.tailnet-name.ts.net`)

### Step 2: Configure 1Password Item Fields

After creating the item, manually fill in the following fields in 1Password:

| Field                      | Description                     | Required |
| -------------------------- | ------------------------------- | -------- |
| `privkey` or `private key` | Private SSH key content         | ✅       |
| `pubkey` or `public key`   | Public SSH key content          | ✅       |
| `user`                     | SSH username for the connection | ✅       |
| `hostname`                 | Server hostname or IP address   | ✅ (unless Tailscale-only) |
| `tailscale_ip`             | Tailscale IP or Magic DNS name  | ✅ (unless public-only)    |
| `port`                     | SSH port (default: 22)          | ❌       |

> **Security Note**: Store only the key content without any additional
> formatting or headers/footers.
>
> Provide one field from each accepted private-key and public-key label pair.

### Step 3: Add Server Configuration

Add your remote server configuration to
`./chezmoi/.chezmoidata/remote_servers.toml`. The file holds four tables
— one per role — so workstation, development, deployment, and git-host
entries stay separated:

```toml
[workstations]
  [workstations.ws-mbp]
  add_to_ssh_config = true
  name = "ws-mbp"
  op_id = "your-1password-item-id-here"
  forward_agent = true
  use_op_identity_agent = true
  via_tailscale = true

[development_servers]
  [development_servers.dev-atlas]
  add_to_ssh_config = true
  name = "dev-atlas"
  op_id = "your-development-server-item-id"
  forward_agent = true
  use_op_identity_agent = true
  # Flip this when the VPS moves between public IP and Tailscale.
  via_tailscale = true

[deployment_servers]
  [deployment_servers.prod-web-01]
  add_to_ssh_config = true
  name = "prod-web-01"
  op_id = "your-deployment-server-item-id"
  # Policy: deployment servers must keep both agent flags false.
  forward_agent = false
  use_op_identity_agent = false
  via_tailscale = false

[git_hosts]
  # Names here are frozen: they are embedded in git remote URLs
  # (e.g. ghcny:owner/repo.git). Do not rename or add prefixes.
  [git_hosts.ghcny]
  add_to_ssh_config = true
  name = "ghcny"
  op_id = "your-git-host-item-id"
  forward_agent = false
  use_op_identity_agent = true
  via_tailscale = false
```

#### Configuration Options

<!-- markdownlint-disable MD013 -->

| Option              | Type    | Description                                  | Default |
| ------------------- | ------- | -------------------------------------------- | ------- |
| `add_to_ssh_config` | boolean | Whether to include this server in SSH config | `false` |
| `name`              | string  | Server identifier (used for SSH host alias)  | -       |
| `op_id`             | string  | 1Password item UUID                          | -       |
| `via_tailscale`         | boolean | Connect via Tailscale (`Host tail<name>`)    | `false` |
| `forward_agent`         | boolean | Set `ForwardAgent yes` (never for deployment)| `false` |
| `use_op_identity_agent` | boolean | Use the 1Password SSH agent socket           | `false` |
| `generate_public_key_only` | boolean | Materialize only the `.pub` key file      | `false` |

<!-- markdownlint-enable MD013 -->

### Step 4: Automatic Key Materialization

The `run_onchange_after_60-security-material.sh.tmpl` script will, when a key
file is missing:

1. Fetch the required SSH key field from 1Password at script execution time.
2. Create the private and/or public key file in `~/.ssh-keys/`.
3. Set appropriate file permissions (600 for private keys, 644 for public keys).

Key material is not embedded in the rendered Chezmoi script, and no base64
encode/decode step is required.

### Step 5: SSH Configuration Generation

The `~/.ssh/config.tmpl` file automatically generates SSH configurations using
Go template syntax. The generated config includes:

- **Regular connections**: `Host [server-name]`
- **Tailscale connections**: `Host tail[server-name]` (prefix with 'tail')
- **Security settings**: IdentityFile, IdentitiesOnly, and other security
  options
- **Optional 1Password SSH agent**: IdentityAgent uses
  `~/.1password/agent.sock` on Linux or
  `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock` on macOS
  when `use_op_identity_agent = true` and the connection is not already an SSH
  shell (`SSH_TTY` is unset). The generated config scopes this with
  `Match originalhost` so forwarded agent sockets remain usable.

## Examples

### Example 1: Regular Server Setup

```toml
[deployment_servers]
  [deployment_servers.prod-web-01]
  add_to_ssh_config = true
  name = "prod-web-01"
  op_id = "abc123def456"
  forward_agent = false
  use_op_identity_agent = false
  via_tailscale = false
```

Generated SSH config:

```text
Host prod-web-01
    User ubuntu
    Hostname 192.168.1.100
    Port 22
    IdentityFile ~/.ssh-keys/prod-web-01.pub
    IdentitiesOnly yes
```

### Example 2: Tailscale Server Setup

```toml
[workstations]
  [workstations.ws-db]
  add_to_ssh_config = true
  name = "ws-db"
  op_id = "xyz789uvw012"
  forward_agent = true
  use_op_identity_agent = true
  via_tailscale = true
```

Generated SSH config:

```text
Host tailws-db
    User admin
    Hostname 100.64.0.1
    Port 22
    IdentityFile ~/.ssh-keys/ws-db.pub
    IdentitiesOnly yes
```

The logical alias keeps the short name (`ws-db` →
`ssh tailws-db`), so muscle memory keeps working while the rendered
`Host` carries the effective `tail` address.

## Verification Steps

After configuration, verify your setup:

1. **Check SSH key generation**:

   ```bash
   ls -la ~/.ssh-keys/
   ```

2. **Verify SSH config**:

   ```bash
   cat ~/.ssh/config
   ```

3. **Test connection**:

   ```bash
   ssh [server-name]
   # or for Tailscale
   ssh tail[server-name]
   ```

4. **Check 1Password integration**:

   ```bash
   op item get [server-name] --fields label=hostname
   ```

## Troubleshooting

### Common Issues

#### Issue: SSH key not found

**Symptoms**: `Permission denied (publickey)` **Solution**:

1. Verify the item has either `privkey` or `private key` for private material.
2. Verify it has either `pubkey` or `public key` for public material.
3. Check if `run_onchange_after_60-security-material.sh.tmpl` executed
   successfully.
4. Ensure key files exist in `~/.ssh-keys/`.

#### Issue: 1Password CLI not authenticated

**Symptoms**: `op: command not found` or authentication errors **Solution**:

```bash
# Install 1Password CLI
brew install 1password-cli

# Sign in
op signin
```

#### Issue: Tailscale connection fails

**Symptoms**: `Could not resolve hostname` **Solution**:

1. Verify Tailscale is running: `tailscale status`
2. Check if Magic DNS is enabled in Tailscale admin
3. Ensure `via_tailscale` is set to `true` in configuration

#### Issue: Wrong hostname in SSH config

**Symptoms**: Connection to wrong server **Solution**:

1. Check the 1Password item's `hostname` / `tailscale_ip` fields
2. Verify `via_tailscale` matches your intention
3. Re-run chezmoi apply: `chezmoi apply`

## Security Best Practices

1. **Key Management**:
   - Use Ed25519 keys for new setups (RSA 4096 for compatibility)
   - Never share private keys outside 1Password
   - Rotate keys regularly (quarterly recommended)

2. **Access Control**:
   - Use principle of least privilege for server users
   - Enable 2FA on 1Password account
   - Regular audit of 1Password items

3. **Network Security**:
   - Prefer Tailscale for private networks
   - Use non-standard SSH ports when possible
   - Implement fail2ban or similar protection

## Advanced Configuration

### Custom SSH Options

To add custom SSH options for specific servers, you can extend the template or
manually add entries after the managed section.

### Multiple Environments

For different environments (dev/staging/prod), use the role tables with
`dev-` / `prod-` name prefixes:

```toml
[development_servers]
  [development_servers.dev-web-01]
  # development configuration (agent forwarding allowed)

[deployment_servers]
  [deployment_servers.prod-web-01]
  # production configuration (agent forwarding forbidden)
```

## References

- [1Password SSH Key Management](https://developer.1password.com/docs/ssh/)
- [Chezmoi Templating Guide](https://www.chezmoi.io/user-guide/templating/)
- [Tailscale SSH Documentation](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Original Inspiration](https://github.com/natelandau/dotfiles?tab=readme-ov-file#ssh-configuration)
- [1Password Item Template](https://developer.1password.com/docs/cli/item-template-json/)
