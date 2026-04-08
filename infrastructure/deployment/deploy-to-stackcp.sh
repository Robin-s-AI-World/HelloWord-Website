#!/bin/bash
# Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.
#
# Deploy to sanctissimissa.online (StackCP shared hosting)
# Note: rsync over SSH is available and works (confirmed 2026-04-08)
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

log_info "Deploying to sanctissimissa.online via rsync over SSH..."

rsync -avz --delete \
    --exclude '.git' \
    --exclude 'infrastructure' \
    --exclude 'domains' \
    --exclude 'HELLOWORD.ROBIN.MBA' \
    --exclude 'SANCTISSIMISSA.ONLINE' \
    --exclude 'DOCS' \
    --exclude 'CHECKLIST.md' \
    --exclude '*.log' \
    --exclude 'node_modules' \
    ./ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/

log_info "Deployed to sanctissimissa.online"
