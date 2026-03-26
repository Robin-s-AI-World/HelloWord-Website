# Release API for HelloWord-Website

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

## Overview

This document describes the API interface between the HelloWord (app) repo and HelloWord-Website (info site) repo for automatic updates when new builds are released.

## Architecture

```
HelloWord Repo                          HelloWord-Website Repo
┌─────────────────┐                    ┌─────────────────────┐
│ Build Workflow  │                    │ update-downloads.yml│
│   (release)     │───dispatch event──▶│   (triggered)       │
└─────────────────┘                    └─────────────────────┘
        │                                       │
        ▼                                       ▼
┌─────────────────┐                    ┌─────────────────────┐
│ GitHub Release  │                    │ downloads/ folder   │
│   artifacts     │                    │ hashes.json         │
└─────────────────┘                    │ index.html updates  │
                                       └─────────────────────┘
```

## Methods to Trigger Updates

### Method 1: repository_dispatch (Recommended)

From HelloWord repo's release workflow, add:

```yaml
- name: Notify HelloWord-Website
  if: startsWith(github.ref, 'refs/tags/v')
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.PAT_TOKEN }}
    repository: Robin-s-AI-World/HelloWord-Website
    event-type: new-release
    client-payload: |
      {
        "version": "${{ env.VERSION }}",
        "build_number": "${{ env.BUILD_NUMBER }}",
        "apk_url": "https://github.com/Robin-s-AI-World/HelloWord/releases/download/v${{ env.VERSION }}/sanctissimissa-android.apk",
        "exe_url": "https://github.com/Robin-s-AI-World/HelloWord/releases/download/v${{ env.VERSION }}/SanctissiMissa-Windows.exe"
      }
```

### Method 2: Manual API Call

```bash
curl -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token YOUR_PAT_TOKEN" \
  https://api.github.com/repos/Robin-s-AI-World/HelloWord-Website/dispatches \
  -d '{
    "event_type": "update-downloads",
    "client_payload": {
      "version": "0.1.2-alpha",
      "build_number": "73045",
      "apk_url": "https://github.com/.../app-release.apk",
      "exe_url": "https://github.com/.../SanctissiMissa.exe"
    }
  }'
```

### Method 3: Workflow Dispatch (Manual)

Go to Actions → "Update Downloads" → Run workflow

Fill in:
- version: `0.1.2-alpha`
- build_number: `73045`
- apk_url: GitHub release URL
- exe_url: GitHub release URL

## Required Secrets

### HelloWord-Website Repo Secrets

| Secret | Description |
|--------|-------------|
| `PAT_TOKEN` | GitHub PAT with repo scope (to allow push) |
| `DEPLOY_WEBHOOK_URL` | Webhook URL to trigger server deployment |

### HelloWord Repo Secrets

| Secret | Description |
|--------|-------------|
| `PAT_TOKEN` | GitHub PAT with repo scope (to dispatch to Website repo) |

## Adding to HelloWord Release Workflow

Edit `.github/workflows/build-all-platforms.yml` in HelloWord repo:

```yaml
  notify-website:
    name: Notify HelloWord-Website
    needs: [android, desktop, release]
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    steps:
      - name: Extract version
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          echo "VERSION=${VERSION}" >> $GITHUB_ENV

      - name: Get release assets
        id: release
        uses: softprops/action-gh-release@v1
        with:
          # This gets the release info

      - name: Dispatch to HelloWord-Website
        uses: peter-evans/repository-dispatch@v3
        with:
          token: ${{ secrets.PAT_TOKEN }}
          repository: Robin-s-AI-World/HelloWord-Website
          event-type: new-release
          client-payload: |
            {
              "version": "${{ env.VERSION }}",
              "build_number": "${{ github.run_number }}",
              "apk_url": "https://github.com/Robin-s-AI-World/HelloWord/releases/download/v${{ env.VERSION }}/app-universal-release.apk",
              "exe_url": "https://github.com/Robin-s-AI-World/HelloWord/releases/download/v${{ env.VERSION }}/SanctissiMissa-Windows.exe"
            }
```

## hashes.json Format

Generated automatically at `downloads/hashes.json`:

```json
{
  "version": "0.1.1-alpha",
  "build": "73029",
  "generated": "2026-03-26T14:00:00Z",
  "files": {
    "apk": {
      "file": "sanctissimissa-android-apk-universal-release-v0.1.1-alpha-build73029-signed.apk",
      "sha256": "abc123...def456",
      "size": 129949076
    },
    "exe": {
      "file": "SanctissiMissa-Windows-v0.1.1-alpha-build73029-x64.exe",
      "sha256": "789abc...012def",
      "size": 27304448
    }
  }
}
```

## Future Enhancements

1. **Add more platforms**: AppImage, DMG, MSI
2. **Auto-update PWA**: Deploy built PWA to sanctissimissa-app.robin.mba
3. **Version badge**: Update version badge in README
4. **Changelog**: Auto-generate changelog from commits
5. **Notification**: Send to Discord/Slack on new release

## Testing

```bash
# Test manual trigger
gh workflow run update-downloads.yml \
  -f version=0.1.1-alpha \
  -f build_number=73029 \
  -f apk_url=https://example.com/test.apk \
  -f exe_url=https://example.com/test.exe

# Check status
gh run list --workflow=update-downloads.yml
```
