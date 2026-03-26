#!/bin/bash
# Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.
#
# Sync nginx configs from this repo to the server
# Usage: ./sync-nginx-to-server.sh

set -e

REMOTE="root@192.168.0.126"
LOCAL_DIR="$(dirname "$0")/../nginx"
REMOTE_DIR="/etc/nginx"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

log_info "Syncing nginx configs to ${REMOTE}..."

# Backup current configs
BACKUP_FILE="/root/nginx-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
log_info "Creating backup: ${BACKUP_FILE}"
ssh $REMOTE "tar -czf ${BACKUP_FILE} -C /etc/nginx conf.d snippets 2>/dev/null || true"

# Sync configs
log_info "Syncing conf.d..."
rsync -av ${LOCAL_DIR}/conf.d/ ${REMOTE}:${REMOTE_DIR}/conf.d/

log_info "Syncing snippets..."
rsync -av ${LOCAL_DIR}/snippets/ ${REMOTE}:${REMOTE_DIR}/snippets/

# Test nginx config
log_info "Testing nginx configuration..."
if ssh $REMOTE "nginx -t"; then
    log_info "Reloading nginx..."
    ssh $REMOTE "systemctl reload nginx"
    log_info "Done! Nginx configs synced and reloaded."
else
    log_warn "Nginx config test failed! Rolling back..."
    ssh $REMOTE "tar -xzf ${BACKUP_FILE} -C /etc/nginx && systemctl reload nginx"
    exit 1
fi
