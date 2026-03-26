# Server Infrastructure Documentation

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## Server Overview

### Primary Server (192.168.0.126)
- **Hostname**: `nginx-ui`
- **OS**: Debian GNU/Linux 13 (trixie)
- **Role**: Reverse Proxy / Nginx UI Container
- **IP**: 192.168.0.126/24
- **Running in**: LXC Container (systemd init scope)

### Key Services
- **Nginx**: Reverse proxy for all domains
- **Nginx UI**: Web-based nginx management (port not exposed externally)
- **SSL Certificates**: Managed in `/etc/nginx/ssl/`

## Domain Routing

| Domain | Type | Root/Upstream | Config File |
|--------|------|---------------|-------------|
| helloword.robin.mba | Info Site | `/var/www/sanctissimissa-infosite/current` | `sanctissimissa-infosite.conf` |
| sanctissimissa-app.robin.mba | SPA | `/var/www/sanctissimissa-app/current` | `sanctissimissa-app.conf` |
| sanctissimissa.online | External | StackCP hosting | N/A (external) |

## SSL Certificates

Location: `/etc/nginx/ssl/`

| Certificate | Domains |
|-------------|---------|
| fullchain1 | Wildcard cert |
| *.robin.mba_robin.mba_P256 | robin.mba wildcard |
| *.mba2003.biz_mba2003.biz_P256 | mba2003.biz wildcard |

## Deployment

### SanctissiMissa Info Site (HelloWord.robin.mba)
- **Path**: `/var/www/sanctissimissa-infosite/`
- **Structure**: Releases-based deployment with symlinks
- **Current**: `current` -> `releases/20260324-142430`

### SanctissiMissa App
- **Path**: `/var/www/sanctissimissa-app/`
- **API Backend**: `http://127.0.0.1:9837/`

## Port Mapping

| Port | Service |
|------|---------|
| 80 | HTTP (redirect to HTTPS) |
| 443 | HTTPS |
| 18080 | Internal - SanctissiMissa App |
| 18081 | Internal - SanctissiMissa Info Site |

## SSHFS Mounts (Development Machine)

```bash
# HelloWord.robin.mba -> LXC server
root@192.168.0.126:/var/www/sanctissimissa-infosite -> ./HELLOWORD.ROBIN.MBA

# SanctissiMissa.online -> StackCP hosting
rochemedia.ca@ssh.gb.stackcp.com:/home/sites/.../sanctissimissa.online -> ./SANCTISSIMISSA.ONLINE
```

## Backup/Restore

### Full Server Migration
1. Copy `infrastructure/` folder to new server
2. Install nginx: `apt install nginx`
3. Copy configs: `cp -r nginx/* /etc/nginx/`
4. Copy SSL certs: `cp -r ssl/* /etc/nginx/ssl/`
5. Create web directories: `mkdir -p /var/www/sanctissimissa-{app,infosite}/{releases,shared}`
6. Deploy content to releases folder
7. Update symlinks
8. Reload nginx: `systemctl reload nginx`

### Content Backup
- Website content is in this git repo
- Deployed content should be synced FROM git TO server
- Use `deploy-to-lxc.sh` script for deployment

## Related Files

- `nginx/nginx.conf` - Main nginx configuration
- `nginx/conf.d/` - Domain-specific server blocks
- `nginx/snippets/` - Reusable config snippets
- `deployment/` - Deployment scripts
- `domains/` - Domain-specific content backups
