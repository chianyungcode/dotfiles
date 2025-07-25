# Remote Server Configuration Flow

This guide explains how to configure SSH access to remote servers using 1Password and Chezmoi for secure key management and automated configuration.

## Overview

The remote server configuration flow integrates 1Password for secure storage of SSH keys and server credentials, with Chezmoi managing the SSH configuration automatically. This approach provides:

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

Create 1Password items using the provided templates. Choose the appropriate template based on your connection method:

#### For Regular SSH Connections

```bash
op item create --template remote-server.json
```

#### For Tailscale SSH Connections

```bash
op item create --template tailscale-remote-server.json
```

> **Note**: When using Tailscale, the hostname typically uses Tailscale's Magic DNS format (e.g., `server-name.tailnet-name.ts.net`)

### Step 2: Configure 1Password Item Fields

After creating the item, manually fill in the following fields in 1Password:

| Field         | Description                     | Required |
| ------------- | ------------------------------- | -------- |
| `ssh_key`     | Private SSH key content         | ✅       |
| `ssh_key.pub` | Public SSH key content          | ✅       |
| `user`        | SSH username for the connection | ✅       |
| `hostname`    | Server hostname or IP address   | ✅       |
| `port`        | SSH port (default: 22)          | ❌       |

> **Security Note**: Store only the key content without any additional formatting or headers/footers.

### Step 3: Add Server Configuration

Add your remote server configuration to `./chezmoi/.chezmoidata/remote-servers.toml`:

```toml
[remote_servers]
  [remote_servers.example-server]
  add_to_ssh_config = true
  name = "example-server"
  op_id = "your-1password-item-id-here"
  tailscale_ip = false

  [remote_servers.tailscale-server]
  add_to_ssh_config = true
  name = "tailscale-server"
  op_id = "your-tailscale-server-item-id"
  tailscale_ip = true
```

#### Configuration Options

| Option              | Type    | Description                                  | Default |
| ------------------- | ------- | -------------------------------------------- | ------- |
| `add_to_ssh_config` | boolean | Whether to include this server in SSH config | `false` |
| `name`              | string  | Server identifier (used for SSH host alias)  | -       |
| `op_id`             | string  | 1Password item UUID                          | -       |
| `tailscale_ip`      | boolean | Use Tailscale connection                     | `false` |

### Step 4: Automatic Key Generation

The `run_after_20-create-ssh-keys.sh.tmpl` script will:

1. Extract SSH keys from 1Password
2. Create private and public key files in `~/.ssh-keys/`
3. Set appropriate file permissions (600 for private keys)
4. Generate SSH config entries

### Step 5: SSH Configuration Generation

The `~/.ssh/config.tmpl` file automatically generates SSH configurations using Go template syntax. The generated config includes:

- **Regular connections**: `Host [server-name]`
- **Tailscale connections**: `Host tail[server-name]` (prefix with 'tail')
- **Security settings**: IdentityFile, IdentitiesOnly, and other security options

## Examples

### Example 1: Regular Server Setup

```toml
[remote_servers]
  [remote_servers.web-server]
  add_to_ssh_config = true
  name = "web-server"
  op_id = "abc123def456"
  tailscale_ip = false
```

Generated SSH config:

```
Host web-server
    User ubuntu
    Hostname 192.168.1.100
    Port 22
    IdentityFile ~/.ssh-keys/web-server
    IdentitiesOnly yes
```

### Example 2: Tailscale Server Setup

```toml
[remote_servers]
  [remote_servers.db-server]
  add_to_ssh_config = true
  name = "db-server"
  op_id = "xyz789uvw012"
  tailscale_ip = true
```

Generated SSH config:

```
Host db-server
    User admin
    Hostname db-server.company.ts.net
    Port 22
    IdentityFile ~/.ssh-keys/db-server
    IdentitiesOnly yes

Host tdb-server
    User admin
    Hostname 100.64.0.1
    Port 22
    IdentityFile ~/.ssh-keys/db-server
    IdentitiesOnly yes
```

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

**Symptoms**: `Permission denied (publickey)`
**Solution**:

1. Verify 1Password item contains correct `ssh_key` field
2. Check if `run_after_20-create-ssh-keys.sh.tmpl` executed successfully
3. Ensure key files exist in `~/.ssh-keys/`

#### Issue: 1Password CLI not authenticated

**Symptoms**: `op: command not found` or authentication errors
**Solution**:

```bash
# Install 1Password CLI
brew install 1password-cli

# Sign in
op signin
```

#### Issue: Tailscale connection fails

**Symptoms**: `Could not resolve hostname`
**Solution**:

1. Verify Tailscale is running: `tailscale status`
2. Check if Magic DNS is enabled in Tailscale admin
3. Ensure `tailscale_ip` is set to `true` in configuration

#### Issue: Wrong hostname in SSH config

**Symptoms**: Connection to wrong server
**Solution**:

1. Check 1Password item's `hostname` field
2. Verify `tailscale_ip` setting matches your intention
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

To add custom SSH options for specific servers, you can extend the template or manually add entries after the managed section.

### Multiple Environments

For different environments (dev/staging/prod), use naming conventions:

```toml
[remote_servers]
  [remote_servers.prod-web-01]
  # production configuration

  [remote_servers.staging-web-01]
  # staging configuration
```

## References

- [1Password SSH Key Management](https://developer.1password.com/docs/ssh/)
- [Chezmoi Templating Guide](https://www.chezmoi.io/user-guide/templating/)
- [Tailscale SSH Documentation](https://tailscale.com/kb/1193/tailscale-ssh/)
- [Original Inspiration](https://github.com/natelandau/dotfiles?tab=readme-ov-file#ssh-configuration)
- [1Password Item Template](https://developer.1password.com/docs/cli/item-template-json/)
