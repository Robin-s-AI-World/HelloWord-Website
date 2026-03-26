# Nginx-UI Configuration

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## Server Location
- **Server**: 192.168.0.126 (nginx-ui LXC)
- **Config File**: `/usr/local/etc/nginx-ui/app.ini`
- **Service**: `nginx-ui.service`

## Access

| Item | Value |
|------|-------|
| Web UI | http://192.168.0.126:9000 |
| Config Path | `/usr/local/etc/nginx-ui/app.ini` |

## Credentials & Secrets

⚠️ **Store these securely - NOT in git!**

| Secret | Location in app.ini | Purpose |
|--------|---------------------|---------|
| JwtSecret | `[app]` section | JWT authentication |
| crypto.Secret | `[crypto]` section | Data encryption |
| node.Secret | `[node]` section | Node authentication |
| openai.Token | `[openai]` section | AI features |

## SSL Certificate Generation

nginx-ui uses **Let's Encrypt** with **HTTP-01 challenge**:

| Setting | Value |
|---------|-------|
| HTTPChallengePort | 9180 |
| Email | robinsai.world@gmail.com |
| Certificate Authority | Let's Encrypt |

**No DNS provider API needed** - certificates validated via HTTP, not DNS.

## DNS Provider

| Domain | DNS Provider | Nameservers |
|--------|--------------|-------------|
| robin.mba | Namecheap | dns1.registrar-servers.com, dns2.registrar-servers.com |
| cloud59.ca | Namecheap | dns1.registrar-servers.com, dns2.registrar-servers.com |

### Namecheap Credentials (if needed for DNS changes)

If you need to use DNS-01 validation or manage DNS programmatically:

1. Log into Namecheap: https://www.namecheap.com
2. Go to Profile → Tools → API Access
3. Enable API access
4. Generate API Key

**Store securely:**
- API Username
- API Key
- Client IP (must be whitelisted)

## OpenAI/AI Configuration

nginx-ui has AI chat/completion features:

| Setting | Value |
|---------|-------|
| BaseUrl | http://192.168.0.173:11434 |
| Model | qwen3.5:397b-cloud |
| API Type | OPEN_AI |

### ⚠️ AVAILABILITY ISSUE

**Current**: Ollama runs on laptop (192.168.0.173 = msi4090) which is NOT always available.

**Solutions**:
1. **Move Ollama to a server** - Create LXC container on Proxmox for dedicated Ollama
2. **Disable AI features** - Set empty BaseUrl in nginx-ui config
3. **Use external API** - Change to OpenAI API or other provider

### To Move Ollama to Dedicated Container

```bash
# Create new LXC on Proxmox (CT 173 recommended)
# Allocate: 8 cores, 16GB RAM, GPU passthrough if available

# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull model
ollama pull qwen3.5

# Update nginx-ui config on 192.168.0.126
ssh root@192.168.0.126 "sed -i 's|BaseUrl = http://192.168.0.173:11434|BaseUrl = http://192.168.0.173:11434|' /usr/local/etc/nginx-ui/app.ini"

# Or use static IP for the new container
```

## Backup nginx-ui Database

```bash
# Backup database and config
ssh root@192.168.0.126 "tar -czf /root/nginx-ui-backup-\$(date +%Y%m%d).tar.gz -C /usr/local/etc/nginx-ui ."

# Download
scp root@192.168.0.126:/root/nginx-ui-backup-*.tar.gz ~/secure-backups/
```

## Restore nginx-ui

```bash
# Upload backup
scp ~/secure-backups/nginx-ui-backup-*.tar.gz root@<NEW_IP>:/root/

# Restore
ssh root@<NEW_IP> "tar -xzf /root/nginx-ui-backup-*.tar.gz -C /usr/local/etc/nginx-ui"
systemctl restart nginx-ui
```
