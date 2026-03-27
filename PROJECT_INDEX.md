# Project Index: HelloWord-Website (SanctissiMissa Infosite)

Generated: 2026-03-24
Version: 0.1.1-alpha

## Project Overview

**SanctissiMissa Infosite** — The landing page and public documentation for the SanctissiMissa project.
Hosted at: https://helloword.robin.mba and https://sanctissimissa.online

## File Map

| Path | Description |
|------|-------------|
| `index.html` | Primary landing page (Tailwind CSS + Vanilla JS) |
| `status.html` | Real-time CI/CD status dashboard |
| `robin-poet.jpg` | Biography headshot of Robin L. M. Cheung |
| `deploy-to-lxc.sh` | Atomic deployment script for Debian Trixie LXC |
| `Sanctissimissa-Infographic-18mar2026.png` | Architecture infographic |
| `AI__The_New_Blueprint.mp4` | Project vision video |
| `AI_agents_build_the_1962_Latin_Mass.m4a` | AI-generated podcast about the project |
| `Technical-HowItWorks/` | Directory containing technical deep-dives and media |
| `downloads/` | Directory containing signed APK and Windows builds |

## CI/CD System
- **Runner**: Self-hosted on LXC 192.168.0.126 (16GB RAM).
- **Workflows**: `.github/workflows/` in main repo handles web, android, and windows.
- **Dashboard**: https://helloword.robin.mba/status.html

## Deployment Instructions

### To LXC Container (helloword.robin.mba)
1. Ensure SSH access to `deploy@192.168.0.126`.
2. Run the deployment script:
   ```bash
   ./deploy-to-lxc.sh
   ```

### To Shared Hosting (sanctissimissa.online)
1. Mount the server via SSHFS to `SANCTISSIMISSA.ONLINE/` in the main repo.
2. Sync the files:
   ```bash
   cp -r * /path/to/HelloWord/SANCTISSIMISSA.ONLINE/
   ```
