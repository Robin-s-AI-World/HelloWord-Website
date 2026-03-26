#!/bin/bash
# Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.
#
# Deploy HelloWord-Website to LXC container at 192.168.0.126
# Usage: ./deploy-to-lxc.sh [domain]
#
# Domains:
#   helloword     -> helloword.robin.mba (info site)
#   app           -> sanctissimissa-app.robin.mba (SPA)
#   online        -> sanctissimissa.online (external StackCP)

set -e

REMOTE_HOST="192.168.0.126"
REMOTE_USER="root"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

deploy_helloword() {
    log_info "Deploying helloword.robin.mba..."

    REMOTE_BASE="/var/www/sanctissimissa-infosite"
    RELEASE_DIR="${REMOTE_BASE}/releases/${TIMESTAMP}"

    # Create release directory
    ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RELEASE_DIR}"

    # Sync content
    rsync -av --delete \
        --exclude '.git' \
        --exclude 'infrastructure' \
        --exclude 'domains' \
        --exclude 'HELLOWORD.ROBIN.MBA' \
        --exclude 'SANCTISSIMISSA.ONLINE' \
        --exclude '*.log' \
        --exclude 'firebase-debug.log' \
        ./ ${REMOTE_USER}@${REMOTE_HOST}:${RELEASE_DIR}/

    # Update symlink
    ssh ${REMOTE_USER}@${REMOTE_HOST} \
        "cd ${REMOTE_BASE} && ln -sfn releases/${TIMESTAMP} current"

    # Reload nginx
    ssh ${REMOTE_USER}@${REMOTE_HOST} "nginx -t && systemctl reload nginx"

    log_info "Deployed to ${RELEASE_DIR}"
    log_info "Current symlink updated"
}

deploy_app() {
    log_info "Deploying sanctissimissa-app.robin.mba..."

    REMOTE_BASE="/var/www/sanctissimissa-app"
    RELEASE_DIR="${REMOTE_BASE}/releases/${TIMESTAMP}"

    # Check if we have the app content locally
    if [ ! -d "domains/sanctissimissa-app.robin.mba" ]; then
        log_error "App content not found in domains/sanctissimissa-app.robin.mba"
        log_error "Please build the app first or sync from existing deployment"
        exit 1
    fi

    # Create release directory
    ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${RELEASE_DIR}"

    # Sync content
    rsync -av --delete \
        domains/sanctissimissa-app.robin.mba/ \
        ${REMOTE_USER}@${REMOTE_HOST}:${RELEASE_DIR}/

    # Update symlink
    ssh ${REMOTE_USER}@${REMOTE_HOST} \
        "cd ${REMOTE_BASE} && ln -sfn releases/${TIMESTAMP} current"

    # Reload nginx
    ssh ${REMOTE_USER}@${REMOTE_HOST} "nginx -t && systemctl reload nginx"

    log_info "Deployed to ${RELEASE_DIR}"
}

deploy_online() {
    log_info "Deploying to sanctissimissa.online (StackCP)..."

    # StackCP uses different deployment
    REMOTE_HOST="rochemedia.ca@ssh.gb.stackcp.com"
    REMOTE_PATH="/home/sites/15b/9/9460530f84/sanctissimissa.online"

    rsync -av --delete \
        --exclude '.git' \
        --exclude 'infrastructure' \
        --exclude 'domains' \
        ./ ${REMOTE_HOST}:${REMOTE_PATH}/

    log_info "Deployed to StackCP"
}

sync_from_remote() {
    log_info "Syncing FROM remote server to local domains/ folder..."

    # Sync helloword.robin.mba
    rsync -av --delete \
        ${REMOTE_USER}@${REMOTE_HOST}:/var/www/sanctissimissa-infosite/current/ \
        domains/helloword.robin.mba/

    # Sync sanctissimissa-app.robin.mba
    rsync -av --delete \
        ${REMOTE_USER}@${REMOTE_HOST}:/var/www/sanctissimissa-app/current/ \
        domains/sanctissimissa-app.robin.mba/

    log_info "Sync complete"
}

case "$1" in
    helloword|info)
        deploy_helloword
        ;;
    app)
        deploy_app
        ;;
    online|stackcp)
        deploy_online
        ;;
    sync)
        sync_from_remote
        ;;
    *)
        echo "Usage: $0 {helloword|app|online|sync}"
        echo ""
        echo "Commands:"
        echo "  helloword  - Deploy info site to helloword.robin.mba"
        echo "  app        - Deploy SPA to sanctissimissa-app.robin.mba"
        echo "  online     - Deploy to sanctissimissa.online (StackCP)"
        echo "  sync       - Sync FROM remote server to local domains/ folder"
        exit 1
        ;;
esac
