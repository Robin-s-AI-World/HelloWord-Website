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

⚠️ **rsync NOT available** - StackCP only supports SFTP/SCP, not rsync

⚠️ **SSHFS mount** - Mounted locally at `./SANCTISSIMISSA.ONLINE/` for convenience

### Directory Structure on StackCP

```
sanctissimissa.online/
├── index.html                    # Main site
├── status.html                   # Status page
├── robin-poet.jpg               # Image asset
├── Sanctissimissa-Infographic-18mar2026.png
├── downloads/                    # Downloadable files
│   ├── SanctissiMissa-Windows-v0.1.1-alpha.73029-build73031-x64.exe
│   └── sanctissimissa-android-apk-universal-release-v0.1.1-alpha.73016-signed.apk
└── Technical-HowItWorks/         # Technical docs
    ├── Hello,_Word__A_Sacred_App.mp4
    ├── The_Architecture_Upgrade__SanctissiMissa.mp4
    ├── Sanctissimissa-Data-Architecture.png
    └── ...
```

### Deployment to StackCP

#### Method 1: SFTP (Recommended)

```bash
# Using the deployment script
./infrastructure/deployment/deploy-to-stackcp.sh

# Or manually via sftp
sftp rochemedia.ca@ssh.gb.stackcp.com << 'EOF'
cd /home/sites/15b/9/9460530f84/sanctissimissa.online
put index.html
put status.html
put -r downloads
put -r Technical-HowItWorks
EOF
```

#### Method 2: SCP

```bash
# Upload single file
scp index.html rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/

# Upload directory
scp -r Technical-HowItWorks rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/
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
2. Upload content via SFTP/SCP to StackCP:
   ```bash
   scp -r ./*.html ./downloads ./Technical-HowItWorks rochemedia.ca@ssh.gb.stackcp.com:/home/sites/15b/9/9460530f84/sanctissimissa.online/
   ```
