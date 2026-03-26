# Proxmox LXC Container Configuration

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## Container: nginx-ui (192.168.0.126)

### Basic Info
- **Hostname**: nginx-ui
- **OS**: Debian GNU/Linux 13 (trixie)
- **IP**: 192.168.0.126/24
- **Role**: Reverse Proxy / Nginx Management

### Container Config Location
On Proxmox host: `/etc/pve/lxc/<CTID>.conf`

### To Export Container Config
```bash
# On Proxmox host
cat /etc/pve/lxc/<CTID>.conf
```

### To Clone/Restore Container
```bash
# On Proxmox host
# Create backup
vzdump <CTID> --compress zstd --mode stop --storage local

# Restore from backup
pct restore <NEW_CTID> /path/to/backup.tar.zst
```

### Resources (Example - Update with actual values)
```conf
# /etc/pve/lxc/CTID.conf
arch: amd64
cores: 2
hostname: nginx-ui
memory: 2048
net0: name=eth0,bridge=vmbr0,gw=192.168.0.1,hwaddr=XX:XX:XX:XX:XX:XX,ip=192.168.0.126/24,type=veth
onboot: 1
ostype: debian
rootfs: local-lvm:vm-CTID-disk-0,size=8G
swap: 512
```

### Services Running
- nginx (reverse proxy)
- nginx-ui (web management interface)

### Network Ports
| Port | Service | External |
|------|---------|----------|
| 80 | nginx HTTP | Yes |
| 443 | nginx HTTPS | Yes |
| 18080 | Internal - App | No |
| 18081 | Internal - Info Site | No |

## Backup Strategy

1. **Container Backup**: Use Proxmox vzdump for full container backup
2. **Config Backup**: This repo tracks all nginx configs
3. **Content Backup**: This repo tracks website content

## Migration Checklist

- [ ] Export container config from Proxmox
- [ ] Copy SSL certificates (or re-issue on new server)
- [ ] Update DNS records
- [ ] Deploy nginx configs from this repo
- [ ] Deploy website content from this repo
- [ ] Test all domains
