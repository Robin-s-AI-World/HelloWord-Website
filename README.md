# HelloWord-Website

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## ⚠️ PRIVATE REPOSITORY - NOT FOR PUBLIC DISTRIBUTION

This repository contains:
- Complete infrastructure configuration
- Server deployment scripts
- Internal IP addresses and paths
- Nginx configurations for all domains

**Keep this repository private.**

---

## Overview

Public-facing informational website for **SanctissiMissa** (https://helloword.robin.mba), serving as the landing page and documentation for the SanctissiMissa Traditional Latin Mass application.

### Live Sites

| Domain | Purpose | Hosting |
|--------|---------|---------|
| [helloword.robin.mba](https://helloword.robin.mba) | Info Site | LXC 192.168.0.126 |
| [sanctissimissa-app.robin.mba](https://sanctissimissa-app.robin.mba) | Web App | LXC 192.168.0.126 |
| [sanctissimissa.online](https://sanctissimissa.online) | Mirror | StackCP Shared |

---

## Quick Start

```bash
# Clone
git clone <repo-url>
cd HelloWord-Website

# Local development
npx serve .
# or
python -m http.server 8080

# Deploy to LXC server
./infrastructure/deployment/deploy-to-lxc.sh helloword
```

---

## Directory Structure

```
HelloWord-Website/
├── index.html              # Main website
├── status.html             # Status page
├── manifest.json           # PWA manifest
├── icons/                  # Favicons and app icons
│   ├── favicon.svg
│   ├── favicon-32x32.png
│   ├── apple-touch-icon.png
│   └── icon-192x192.png
├── downloads/              # Downloadable files
│   ├── SanctissiMissa-Windows-*.exe
│   └── sanctissimissa-android-*.apk
├── Technical-HowItWorks/   # Technical documentation assets
├── domains/                # Synced content from remote servers
│   ├── helloword.robin.mba/
│   └── sanctissimissa-app.robin.mba/
└── infrastructure/         # Server configuration and deployment
    ├── SERVER.md          # Main server documentation
    ├── nginx/
    │   ├── nginx.conf
    │   ├── conf.d/        # All domain configs
    │   └── snippets/
    ├── nginx-ui/
    ├── proxmox/
    ├── shared-hosting/
    │   └── STACKCP.md     # sanctissimissa.online config
    └── deployment/
        ├── deploy-to-lxc.sh
        ├── deploy-to-stackcp.sh
        └── sync-nginx-to-server.sh
```

---

## Infrastructure Architecture

### Servers

| Server | IP | Role | OS |
|--------|-----|------|-----|
| nginx-ui | 192.168.0.126 | Reverse Proxy | Debian 13 (trixie) |
| StackCP | ssh.gb.stackcp.com | Shared Hosting | Linux |

### Domain Routing

| Domain | Config File | Target |
|--------|-------------|--------|
| helloword.robin.mba | sanctissimissa-infosite.conf | /var/www/sanctissimissa-infosite/current |
| sanctissimissa-app.robin.mba | sanctissimissa-app.conf | /var/www/sanctissimissa-app/current |
| sanctissimissa.online | (external) | StackCP hosting |

### All Nginx Domains on 192.168.0.126

| Domain | Purpose | Config |
|--------|---------|--------|
| helloword.robin.mba | SanctissiMissa Info Site | sanctissimissa-infosite.conf |
| sanctissimissa-app.robin.mba | SanctissiMissa Web App | sanctissimissa-app.conf |
| git.robin.mba | Forgejo | git.conf |
| n8n.robin.mba | n8n Automation | n8n.conf |
| draw.robin.mba | Draw.io | draw.conf |
| apisms.robin.mba | SMS Gateway | apisms.conf |
| searxng.robin.mba | Search | searxng.conf |
| paper.robin.mba | Paperless-ngx | paper.conf |
| odoo.robin.mba | ERP | odoo.conf |
| missa.robin.mba | Redirect | missa.conf |
| tuba.robin.mba | Tuba (Mastodon) | tuba.conf |
| umbrel.robin.mba | Umbrel | umbrel.conf |

---

## Full Restore/Migration Guide

### Part 1: Restore This Website

#### Step 1: Prepare New Server (LXC Container)

```bash
# On Proxmox host, create LXC container
# Recommended: 2 cores, 2GB RAM, 8GB disk

# Start container
apt update && apt install -y nginx rsync curl
systemctl enable nginx
systemctl start nginx
```

#### Step 2: Clone and Deploy

```bash
git clone <repo-url>
cd HelloWord-Website

# Deploy content
./infrastructure/deployment/deploy-to-lxc.sh helloword

# Deploy nginx configs
./infrastructure/deployment/sync-nginx-to-server.sh
```

#### Step 3: SSL Certificates

**Certificate Locations on 192.168.0.126:**

| Certificate | Server Path | Domains |
|-------------|-------------|---------|
| Primary Wildcard | `/etc/nginx/ssl/fullchain1/` | Primary domains |
| *.robin.mba | `/etc/nginx/ssl/*.robin.mba_robin.mba_P256/` | All robin.mba subdomains |
| *.mba2003.biz | `/etc/nginx/ssl/*.mba2003.biz_mba2003.biz_P256/` | mba2003.biz subdomains |

**Files in each certificate directory:**
- `fullchain.cer` - Full certificate chain
- `private.key` - Private key (KEEP SECURE!)

**Backup SSL Certificates:**
```bash
# Create backup on server
ssh root@192.168.0.126 "cd /etc/nginx && tar -czf /root/ssl-backup-\$(date +%Y%m%d).tar.gz ssl/"

# Download to secure location (NOT in git repo!)
scp root@192.168.0.126:/root/ssl-backup-*.tar.gz ~/secure-backups/

# Or encrypted backup
ssh root@192.168.0.126 "cd /etc/nginx && tar -cz ssl/ | gpg -c > /root/ssl-backup-\$(date +%Y%m%d).gpg"
```

**Restore SSL Certificates:**
```bash
# Option A: New certificates via certbot
apt install certbot python3-certbot-nginx
certbot --nginx -d helloword.robin.mba -d sanctissimissa-app.robin.mba

# Option B: Restore from backup
scp ~/secure-backups/ssl-backup-*.tar.gz root@<IP>:/root/
ssh root@<IP> "cd /etc/nginx && tar -xzf /root/ssl-backup-*.tar.gz"
```

**⚠️ NEVER commit certificates to git - they are excluded in .gitignore**

#### Step 4: DNS Updates

Update DNS A records:
- helloword.robin.mba → <NEW_IP>
- sanctissimissa-app.robin.mba → <NEW_IP>

### Part 2: Restore sanctissimissa.online (StackCP)

See [infrastructure/shared-hosting/STACKCP.md](infrastructure/shared-hosting/STACKCP.md) for full details.

```bash
# Deploy via SFTP (rsync not available)
./infrastructure/deployment/deploy-to-stackcp.sh
```

### Part 3: Restore SanctissiMissa App

#### App Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| Rust | 1.75+ | Backend/Tauri |
| Node.js | 18+ | Frontend build |
| Tauri CLI | 2.0+ | Desktop app |
| Android SDK | 34+ | Android build |
| JDK | 17+ | Android build |

#### Expected App Structure

```
SanctissiMissa/
├── src-tauri/
│   ├── src/mass/          # Mass construction
│   ├── src/calendar/      # Liturgical calendar
│   ├── src/texts/         # Latin/English texts
│   ├── src/database/      # SQLite
│   └── tauri.conf.json
├── src/                   # Frontend
├── public/icons/
└── package.json
```

#### Localization Standards

| Standard | Format | Usage |
|----------|--------|-------|
| Dates | ISO 8601 (YYYY-MM-DD) | All date storage |
| Time | 24-hour (HH:MM:SS) | Timestamps |
| Timezone | UTC storage, local display | Server/client |
| Locale | en-US UI, la for Latin | User preference |
| Liturgical | 1962 Roman Calendar | Mass propers |

---

## Deployment Scripts

```bash
# Deploy to LXC (192.168.0.126)
./infrastructure/deployment/deploy-to-lxc.sh helloword  # Info site
./infrastructure/deployment/deploy-to-lxc.sh app        # App
./infrastructure/deployment/deploy-to-lxc.sh sync       # Sync FROM remote

# Deploy to StackCP (sanctissimissa.online)
./infrastructure/deployment/deploy-to-stackcp.sh

# Sync nginx configs
./infrastructure/deployment/sync-nginx-to-server.sh
```

---

## File Naming Conventions

### Website Files
- `index.html` - Main page
- `status.html` - Status page
- `manifest.json` - PWA manifest
- `icons/favicon.svg` - SVG favicon
- `icons/favicon-32x32.png` - PNG favicon
- `icons/apple-touch-icon.png` - iOS (180x180)
- `icons/icon-192x192.png` - Android

### Download Files
- `sanctissimissa-android-apk-universal-release-v{VERSION}-signed.apk`
- `SanctissiMissa-Windows-v{VERSION}-build{BUILD}-x64.exe`

### Nginx Configs
- `{domain}.conf` - Domain-specific
- `00-upgrade-map.conf` - WebSocket upgrade
- `proxy-params.conf` - Proxy parameters

---

## Versioning

Format: `v{MAJOR}.{MINOR}.{PATCH}[-{PRERELEASE}] Build {BUILD}`
- Build: `(epoch % 100) * 1000 + minutes_past_hour`
- Example: `v0.1.1-alpha Build 73029`

---

## Troubleshooting

### Favicon Not Showing
1. Hard refresh: Ctrl+Shift+R
2. Verify files exist: `ls icons/`
3. Check nginx serving: `curl -I https://helloword.robin.mba/icons/favicon.svg`

### Nginx Errors
```bash
ssh root@192.168.0.126 "nginx -t"
ssh root@192.168.0.126 "tail -50 /var/log/nginx/error.log"
```

### StackCP Deployment Issues
- rsync NOT available, use SFTP/SCP only
- See [infrastructure/shared-hosting/STACKCP.md](infrastructure/shared-hosting/STACKCP.md)

---

## Security

### SSL Certificates (192.168.0.126)

| Location | Certificate | Use |
|----------|-------------|-----|
| `/etc/nginx/ssl/fullchain1/` | Primary wildcard | Main domains |
| `/etc/nginx/ssl/*.robin.mba_robin.mba_P256/` | *.robin.mba | All robin.mba subdomains |
| `/etc/nginx/ssl/*.mba2003.biz_mba2003.biz_P256/` | *.mba2003.biz | mba2003.biz subdomains |

**Each directory contains:**
- `fullchain.cer` - Certificate chain (public, safe to share)
- `private.key` - Private key (SECRET - never share or commit!)

### Sensitive Files (Excluded from Git)

| File/Pattern | Reason | Location |
|--------------|--------|----------|
| `*.key` | Private keys | /etc/nginx/ssl/*/ |
| `*.pem` (certs) | SSL certs | /etc/nginx/ssl/*/ |
| `.env*` | Credentials | Various projects |
| `*_password*` | Passwords | Anywhere |
| `*.secret` | Secrets | Anywhere |

### Security Practices
- **Server access**: SSH keys only (no password auth)
- **This repo**: Must remain private
- **Backups**: Encrypt before storing off-site

---

## External Dependencies

### ⚠️ Ollama on Laptop (192.168.0.173)

nginx-ui's AI features depend on Ollama running on **this laptop**:
- **IP**: 192.168.0.173 (msi4090)
- **Port**: 11434
- **Model**: qwen3.5:397b-cloud

**Issue**: Laptop not always available → AI features will fail.

**Solutions**:
1. Move Ollama to dedicated LXC container
2. Disable AI features in nginx-ui
3. Use external OpenAI API

See [infrastructure/nginx-ui/CREDENTIALS.md](infrastructure/nginx-ui/CREDENTIALS.md) for details.

---

## Related Documentation

- [infrastructure/SERVER.md](infrastructure/SERVER.md) - Server overview
- [infrastructure/shared-hosting/STACKCP.md](infrastructure/shared-hosting/STACKCP.md) - StackCP config
- [infrastructure/nginx-ui/NGINX-UI-SYNC.md](infrastructure/nginx-ui/NGINX-UI-SYNC.md) - Nginx-UI sync strategy
- [infrastructure/nginx-ui/CREDENTIALS.md](infrastructure/nginx-ui/CREDENTIALS.md) - Nginx-UI credentials & secrets
- [infrastructure/proxmox/LXC-nginx-ui.md](infrastructure/proxmox/LXC-nginx-ui.md) - Container info

---

## Contact

**Robin L. M. Cheung, MBA**
- Email: robin@robin.mba
- GitHub: @Robin-s-AI-World

---

*Last updated: 2026-03-26*
