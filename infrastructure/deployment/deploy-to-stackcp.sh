#!/bin/bash
# Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.
#
# Deploy to sanctissimissa.online (StackCP shared hosting)
# Note: StackCP uses SFTP, not rsync
#
# Usage: ./deploy-to-stackcp.sh

set -e

REMOTE_HOST="ssh.gb.stackcp.com"
REMOTE_USER="rochemedia.ca"
REMOTE_PATH="/home/sites/15b/9/9460530f84/sanctissimissa.online"

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }

log_info "Deploying to sanctissimissa.online via SFTP..."

# Use sftp for upload (rsync not available on StackCP)
sftp -b - ${REMOTE_USER}@${REMOTE_HOST} << 'EOF'
cd /home/sites/15b/9/9460530f84/sanctissimissa.online

# Upload main files
put index.html
put status.html
put robin-poet.jpg
put Sanctissimissa-Infographic-18mar2026.png

# Upload directories
put -r downloads
put -r Technical-HowItWorks
EOF

log_info "Deployed to sanctissimissa.online"
