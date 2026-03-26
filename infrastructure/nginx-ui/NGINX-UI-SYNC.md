# Nginx-UI Synchronization Strategy

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## Current Situation

The nginx configs on 192.168.0.126 are in `/etc/nginx/conf.d/` but Nginx-UI's web interface doesn't show them because:

1. **Nginx-UI expects configs in a specific directory structure** (usually `/etc/nginx/sites-available/` or its own managed directory)
2. **Configs in `conf.d/` are included but not managed by Nginx-UI** by default

## Synchronization Strategies

### Option 1: Import Existing Configs to Nginx-UI (Recommended)

**Steps:**
1. Access Nginx-UI web interface
2. Go to **Settings → Nginx**
3. Add `/etc/nginx/conf.d` to the "Conf Dir" setting
4. Restart Nginx-UI service
5. Existing configs should now appear in the UI

```bash
# On the LXC server
# Check current nginx-ui config
cat /etc/nginx-ui/app.ini

# If needed, add conf.d to monitored directories
# Then restart
systemctl restart nginx-ui
```

### Option 2: Convert to Nginx-UI Managed Structure

**Steps:**
1. Create Nginx-UI managed directories
2. Move/convert configs to the new structure
3. Update nginx.conf to include the new directory

```bash
# Create Nginx-UI structure
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# Convert a config
mv /etc/nginx/conf.d/sanctissimissa-infosite.conf /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/sanctissimissa-infosite.conf /etc/nginx/sites-enabled/

# Update nginx.conf to include sites-enabled
echo "include /etc/nginx/sites-enabled/*;" >> /etc/nginx/nginx.conf

# Reload nginx
nginx -t && systemctl reload nginx
```

### Option 3: Direct File Sync (No UI Management)

Keep configs in `conf.d/` and manage via git/sync:

```bash
# Sync infrastructure configs to server
rsync -av infrastructure/nginx/conf.d/*.conf root@192.168.0.126:/etc/nginx/conf.d/

# Reload nginx
ssh root@192.168.0.126 "nginx -t && systemctl reload nginx"
```

## Recommended Approach

**Hybrid Strategy:**

1. **Keep existing working configs in `conf.d/`** - they're stable and working
2. **Use this repo to track all changes** - git is the source of truth
3. **Configure Nginx-UI to monitor `conf.d/`** for visibility only
4. **Use deployment script for changes** - maintain git workflow

```bash
# One-time setup: Configure Nginx-UI to see conf.d
ssh root@192.168.0.126 "cat >> /etc/nginx-ui/app.ini << 'EOF'

[nginx]
ConfDir = /etc/nginx/conf.d
EOF"
ssh root@192.168.0.126 "systemctl restart nginx-ui"
```

## File: sync-nginx-to-server.sh

```bash
#!/bin/bash
# Sync nginx configs from this repo to the server

set -e

REMOTE="root@192.168.0.126"
LOCAL_DIR="infrastructure/nginx"
REMOTE_DIR="/etc/nginx"

# Backup current configs
ssh $REMOTE "tar -czf /root/nginx-backup-\$(date +%Y%m%d-%H%M%S).tar.gz -C /etc/nginx conf.d snippets"

# Sync configs
rsync -av ${LOCAL_DIR}/conf.d/ ${REMOTE}:${REMOTE_DIR}/conf.d/
rsync -av ${LOCAL_DIR}/snippets/ ${REMOTE}:${REMOTE_DIR}/snippets/

# Test and reload
ssh $REMOTE "nginx -t && systemctl reload nginx"

echo "Nginx configs synced and reloaded"
```

## Automation

Add to git hooks or CI/CD:

```bash
# .git/hooks/pre-push
#!/bin/bash
# Sync nginx configs before pushing
./infrastructure/deployment/sync-nginx-to-server.sh
```
