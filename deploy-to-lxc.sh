#!/bin/bash
# Deploy SanctissiMissa infosite to Debian Trixie server
set -e

LXC_HOST="192.168.0.126"
LXC_USER="deploy"
PROJECT_NAME="sanctissimissa-infosite"
PROJECT_PORT="18081"
VERSION=$(date +%Y%m%d-%H%M%S)

# Create version directory
echo "Creating release directory on LXC..."
ssh ${LXC_USER}@${LXC_HOST} "mkdir -p /var/www/${PROJECT_NAME}/releases/${VERSION}"

# Deploy files
echo "Deploying files..."
rsync -avz --delete . ${LXC_USER}@${LXC_HOST}:/var/www/${PROJECT_NAME}/releases/${VERSION}/ --exclude='.git' --exclude='README.md' --exclude='deploy-to-lxc.sh'

# Update current symlink
echo "Updating current symlink..."
ssh ${LXC_USER}@${LXC_HOST} "ln -sfn /var/www/${PROJECT_NAME}/releases/${VERSION} /var/www/${PROJECT_NAME}/current"

echo "Deployment complete! Version: ${VERSION}"
echo "Access at: http://${LXC_HOST}:${PROJECT_PORT}"
