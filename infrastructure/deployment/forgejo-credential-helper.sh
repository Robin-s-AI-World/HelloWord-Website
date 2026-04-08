#!/bin/bash
# Git credential helper for git.robin.mba (Forgejo)
# Reads FORGEJO_API_KEY from environment (set in ~/.bashrc)
# Usage: git config credential.https://git.robin.mba.helper \
#          /path/to/infrastructure/deployment/forgejo-credential-helper.sh
#
# One-time local setup (run from repo root):
#   git config credential.https://git.robin.mba.helper \
#     "$(pwd)/infrastructure/deployment/forgejo-credential-helper.sh"

# Source .env from repo root if FORGEJO_API_KEY not already in environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
if [ -f "${REPO_ROOT}/.env" ] && [ -z "${FORGEJO_API_KEY}" ]; then
    # shellcheck source=.env
    . "${REPO_ROOT}/.env"
fi

case "$1" in
    get)
        echo "username=rcheung"
        echo "password=${FORGEJO_API_KEY}"
        ;;
    store|erase)
        ;;
esac
