# StackCP Shared Hosting Configuration

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## Domain: sanctissimissa.online

### Hosting Provider
- **Provider**: StackCP (via rochemedia.ca)
- **SSH Host**: `ssh.gb.stackcp.com`
- **Username**: `rochemedia.ca`
- **Base Path**: `/home/sites/15b/9/9460530f84/`
- **Site Path**: `/home/sites/15b/9/9460530f84/sanctissimissa.online/`

### Connection Details

```bash
# SSH/SFTP access
ssh rochemedia.ca@ssh.gb.stackcp.com

# Or via SFTP
sftp rochemedia.ca@ssh.gb.stackcp.com

# Navigate to site
cd /home/sites/15b/9/9460530f84/sanctissimissa.online/
```

### Important Notes

✅ **rsync available** - rsync over SSH is supported and is the recommended deploy method (confirmed 2026-04-08)

⚠️ **SSHFS mount** - Mounted locally at `./SANCTISSIMISSA.ONLINE/` for convenience

### Directory Structure on StackCP

```
sanctissimissa.online/
├── index.html                    # Main site
├── status.html                   # Status page
├── robin-poet.jpg               # Image asset
├── Sanctissimissa-Infographic-18mar2026.png
├── downloads/                    # Downloadable artifacts (see CROSS-REPO-CONTRACTS.md)
│   ├── SanctissiMissa-Android-v2.33-release-signed.apk
│   ├── SanctissiMissa-Windows-v2.33-build92878-x64.exe
│   ├── SanctissiMissa_0.2.33_amd64.AppImage
│   └── SanctissiMissa_0.2.33_amd64.deb
└── Technical-HowItWorks/         # Technical docs
    ├── Hello,_Word__A_Sacred_App.mp4
    ├── The_Architecture_Upgrade__SanctissiMissa.mp4
    ├── Sanctissimissa-Data-Architecture.png
    └── ...
```

### Deployment to StackCP

#### Method 1: rsync (Recommended)

```bash
# Using the deployment script (handles excludes, --delete, etc.)
./infrastructure/deployment/deploy-to-stackcp.sh

# Or manually
rsync -avz --delete \
    --exclude '.git' --exclude 'infrastructure' --exclude 'domains' \
    --exclude 'DOCS' --exclude '*.log' --exclude 'node_modules' \
    ./ rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/
```

#### Method 2: SCP (single files)

```bash
scp index.html rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/
scp -r downloads/ rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/
```

#### Method 3: SSHFS Mount + Copy

```bash
# Mount (requires root/sudo for proper permissions)
sudo mkdir -p /mnt/sanctissimissa-online
sudo sshfs rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online /mnt/sanctissimissa-online -o allow_other

# Copy files
cp -r ./* /mnt/sanctissimissa-online/

# Unmount
sudo fusermount -u /mnt/sanctissimissa-online
```

### DNS Configuration

| Record | Type | Value |
|--------|------|-------|
| sanctissimissa.online | A | (StackCP IP) |
| www.sanctissimissa.online | CNAME | sanctissimissa.online |

### SSL Certificate

StackCP provides automatic SSL via Let's Encrypt. Managed through StackCP control panel.

### File Permissions

```bash
# On StackCP, set permissions via SSH
chmod 644 *.html *.jpg *.png
chmod 755 downloads/ Technical-HowItWorks/
```

### Sync Status

The content at `./domains/sanctissimissa.online/` should be kept in sync with:
1. The local working files (root of this repo)
2. The StackCP hosted site

To sync FROM StackCP to local:
```bash
# Using sftp to download
sftp rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/* ./domains/sanctissimissa.online/
```

### Control Panel Access

- **URL**: https://control.stackcp.com (or provider-specific URL)
- **Account**: rochemedia.ca
- **Features Available**:
  - File Manager
  - SSL Certificate Management
  - DNS Management
  - Email (if configured)

---

## Migration/Restore Checklist

### To Migrate sanctissimissa.online to New Hosting

1. **Download all files** from current StackCP:
   ```bash
   scp -r rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/ ./sanctissimissa-online-backup/
   ```

2. **Download database** (if any - currently static site, no DB)

3. **Update DNS** to point to new hosting

4. **Upload to new hosting**

5. **Configure SSL** on new hosting

6. **Test all pages** and downloads

### To Restore from Git Repo

1. Clone this repo
2. Deploy via rsync:
   ```bash
   ./infrastructure/deployment/deploy-to-stackcp.sh
   ```
