# Hosting Infrastructure

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**
> Last updated: 2026-04-08

---

## Overview

The SanctissiMissa public website is served from two independent hosting environments that are kept in sync on every deploy:

| Host | Domain | Purpose | Type |
|------|--------|---------|------|
| Proxmox LXC 192.168.0.126 | `helloword.robin.mba` | Info site (canonical) | Self-hosted nginx |
| StackCP Shared Hosting | `sanctissimissa.online` | Mirror / wider reach | Shared Linux |

Both serve identical content deployed from this repo.

---

## LXC Host: helloword.robin.mba

### Server Details

| Property | Value |
|----------|-------|
| IP | 192.168.0.126 |
| OS | Debian 13 (trixie) |
| Role | Reverse proxy + static hosting |
| Container type | Proxmox LXC |
| SSH access | `root@192.168.0.126` (key-based only) |

### Directory Structure on Server

```
/var/www/sanctissimissa-infosite/
├── releases/
│   ├── 20260408-053648/     ← timestamped release
│   │   ├── index.html
│   │   ├── status.html
│   │   ├── manifest.json
│   │   ├── robin-poet.jpg
│   │   ├── Sanctissimissa-Infographic-18mar2026.png
│   │   ├── icons/
│   │   │   ├── favicon.svg
│   │   │   ├── favicon-32x32.png
│   │   │   ├── apple-touch-icon.png
│   │   │   └── icon-192x192.png
│   │   ├── downloads/           ← v2.33 artifacts
│   │   │   ├── SanctissiMissa-Android-v2.33-release-signed.apk
│   │   │   ├── SanctissiMissa-Windows-v2.33-build92878-x64.exe
│   │   │   ├── SanctissiMissa_0.2.33_amd64.AppImage
│   │   │   └── SanctissiMissa_0.2.33_amd64.deb
│   │   └── Technical-HowItWorks/
│   └── ... (older releases retained for rollback)
└── current -> releases/20260408-053648   ← symlink, updated on every deploy
```

### Nginx Config

Config file: `/etc/nginx/conf.d/sanctissimissa-infosite.conf`

```nginx
# HTTP → HTTPS redirect
server {
    listen 80;
    server_name helloword.robin.mba;
    return 301 https://$host$request_uri;
}

# HTTPS — public info site
server {
    listen 443 ssl;
    server_name helloword.robin.mba;
    ssl_certificate     /etc/nginx/ssl/fullchain1/fullchain.cer;
    ssl_certificate_key /etc/nginx/ssl/fullchain1/private.key;

    root  /var/www/sanctissimissa-infosite/current;
    index index.html;

    location / { try_files $uri $uri/ /index.html; }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot|webp)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}

# Internal port — nginx-ui routing
server {
    listen 18081;
    server_name _;
    root  /var/www/sanctissimissa-infosite/current;
    ...
}
```

### Deploy Command

```bash
./infrastructure/deployment/deploy-to-lxc.sh helloword
```

Uses `rsync` with atomically-updated symlink (`current`). Nginx is reloaded after each deploy. Old releases retained for rollback.

---

## Shared Hosting: sanctissimissa.online (StackCP)

### Server Details

| Property | Value |
|----------|-------|
| Provider | StackCP |
| SSH host | `ssh.gb.stackcp.com` |
| SSH user | `rochemedia.ca` |
| Site path | `/home/sites/15b/9/9460530f84/sanctissimissa.online/` |
| rsync | ✅ Available (confirmed working) |

### Directory Structure on Server

```
/home/sites/15b/9/9460530f84/sanctissimissa.online/
├── index.html
├── status.html
├── manifest.json
├── robin-poet.jpg
├── Sanctissimissa-Infographic-18mar2026.png
├── icons/
│   ├── favicon.svg
│   ├── favicon-32x32.png
│   ├── apple-touch-icon.png
│   └── icon-192x192.png
├── downloads/
│   ├── SanctissiMissa-Android-v2.33-release-signed.apk
│   ├── SanctissiMissa-Windows-v2.33-build92878-x64.exe
│   ├── SanctissiMissa_0.2.33_amd64.AppImage
│   └── SanctissiMissa_0.2.33_amd64.deb
└── Technical-HowItWorks/
```

Note: StackCP deploys to the live directory directly (no release/symlink pattern). Rollback requires re-deploying.

### Deploy Command

```bash
./infrastructure/deployment/deploy-to-stackcp.sh
```

Uses `rsync -avz --delete` over SSH. Internal DOCS/, infrastructure/, domains/ are excluded.

---

## SSL Certificates

All certificates on 192.168.0.126 are stored under `/etc/nginx/ssl/`.

| Certificate | Path | CN | Issued | Expires | Used by |
|-------------|------|----|--------|---------|---------|
| Primary wildcard | `/etc/nginx/ssl/fullchain1/` | `*.cloud59.ca` | 2026-01-14 | 2026-04-14 (auto-renews) | `helloword.robin.mba` |
| `*.robin.mba` | `/etc/nginx/ssl/*.robin.mba_robin.mba_P256/` | `*.robin.mba` | 2026-04-03 | 2026-07-02 (auto-renews) | All robin.mba subdomains |
| `*.mba2003.biz` | `/etc/nginx/ssl/*.mba2003.biz_mba2003.biz_P256/` | `*.mba2003.biz` | 2026-04-03 | 2026-07-02 (auto-renews) | mba2003.biz subdomains |

### Auto-Renewal

All certs are configured to auto-renew via nginx-ui / acme.sh. No manual intervention needed under normal operation.

To manually verify renewal status:
```bash
ssh root@192.168.0.126 "for d in /etc/nginx/ssl/*/; do echo \"=== \$d ==="; openssl x509 -in \$d/fullchain.cer -noout -dates 2>/dev/null; done"
```

### Certificate File Format

Each directory contains:
- `fullchain.cer` — Full certificate chain (public)
- `private.key` — Private key (**NEVER commit to git**)

### Backup Certs

```bash
ssh root@192.168.0.126 "cd /etc/nginx && tar -czf /root/ssl-backup-$(date +%Y%m%d).tar.gz ssl/"
scp root@192.168.0.126:/root/ssl-backup-*.tar.gz ~/secure-backups/
```

---

## All Nginx Domains on 192.168.0.126

| Domain | Purpose | Config file | SSL cert |
|--------|---------|-------------|----------|
| `helloword.robin.mba` | Info site | `sanctissimissa-infosite.conf` | `fullchain1/` ⚠️ expires Apr 14 |
| `sanctissimissa-app.robin.mba` | Web app | `sanctissimissa-app.conf` | `*.robin.mba` |
| `git.robin.mba` | Forgejo | `git.conf` | `*.robin.mba` |
| `n8n.robin.mba` | n8n Automation | `n8n.conf` | `*.robin.mba` |
| `draw.robin.mba` | Draw.io | `draw.conf` | `*.robin.mba` |
| `apisms.robin.mba` | SMS Gateway | `apisms.conf` | `*.robin.mba` |
| `searxng.robin.mba` | Search | `searxng.conf` | `*.robin.mba` |
| `paper.robin.mba` | Paperless-ngx | `paper.conf` | `*.robin.mba` |
| `odoo.robin.mba` | ERP | `odoo.conf` | `*.robin.mba` |
| `missa.robin.mba` | Redirect | `missa.conf` | `*.robin.mba` |
| `tuba.robin.mba` | Tuba (Mastodon) | `tuba.conf` | `*.robin.mba` |
| `umbrel.robin.mba` | Umbrel | `umbrel.conf` | `*.robin.mba` |

---

## sanctissimissa.online SSL

StackCP manages SSL for `sanctissimissa.online` internally (Let's Encrypt via control panel). Check renewal status in the StackCP dashboard.

---

## Deploy Runbook (both hosts)

```bash
# 1. Build artifacts in HelloWord repo (see DOCS/CROSS-REPO-CONTRACTS.md)
# 2. Copy artifacts to downloads/ and update SITE_CONFIG in index.html
# 3. Deploy to LXC
cd /home/robin/forgejo/HelloWord-Website
./infrastructure/deployment/deploy-to-lxc.sh helloword

# 4. Deploy to StackCP
./infrastructure/deployment/deploy-to-stackcp.sh

# 5. Verify
curl -sI https://helloword.robin.mba | grep -E "HTTP|Server"
curl -sI https://sanctissimissa.online | grep -E "HTTP|Server"
```
