# Cross-Repo Contracts

> **Copyright (C) 2025-2026 Robin L. M. Cheung, MBA. All rights reserved.**

---

## Upstream: HelloWord

- **Repo**: `git.robin.mba/rcheung/HelloWord` (`/home/robin/forgejo/HelloWord`)
- **Canonical version**: `src-tauri/tauri.conf.json` → `"version"` field (semver, e.g. `0.2.33`)
- **Artifacts produced**:

| Platform | Filename pattern | Build output dir |
|----------|-----------------|------------------|
| Android APK | `SanctissiMissa-Android-v{VER}-release-signed.apk` | `dist-android/` |
| Android AAB | `SanctissiMissa-Android-v{VER}-release-signed.aab` | `dist-android/` |
| Android symbols | `SanctissiMissa-Android-v{VER}-native-debug-symbols.zip` | `dist-android/` |
| Windows EXE | `SanctissiMissa-Windows-v{VER}-build{BUILD}-x64.exe` | `dist-windows/` |
| Linux AppImage | `SanctissiMissa_{TAURIVER}_amd64.AppImage` | `dist-linux/` |
| Linux DEB | `SanctissiMissa_{TAURIVER}_amd64.deb` | `dist-linux/` |

### Version number conventions

- `{VER}` = major.minor from Tauri version, dropping leading `0.` (e.g. `0.2.33` → `2.33`)
- `{TAURIVER}` = full Tauri version as-is (e.g. `0.2.33`)
- `{BUILD}` = Android versionCode / build number from `src/version.json`

---

## This repo consumes (HelloWord-Website)

- **Version** → `index.html` `SITE_CONFIG` object (lines 7-33, top of `<head>`)
- **Artifact filenames** → `SITE_CONFIG.artifacts.{apk,exe,appimage,deb}.file`
- **SHA256 hashes** → `SITE_CONFIG.artifacts.{apk,exe,appimage,deb}.sha256`
- **Changelog** → `SITE_CONFIG.changelog[]`
- **Web app (PWA)** → `SITE_CONFIG.webAppUrl` (iframe + links)

All download links, version badges, checksums, install instructions, and changelog
entries on the website derive exclusively from `SITE_CONFIG`. No other hardcoded
values exist in `index.html`.

---

## Hosting targets

| Host | URL | Upload method |
|------|-----|---------------|
| Proxmox LXC (canonical) | `https://helloword.robin.mba/downloads/` | rsync via `deploy-to-lxc.sh` |
| StackCP (mirror) | `https://sanctissimissa.online/downloads/` | SFTP to `ssh.gb.stackcp.com` |

---

## Sync mechanism: Manual (with checklist)

There is no automated CI pipeline between the two repos yet. After every build
in HelloWord, the following checklist must be executed manually in HelloWord-Website.

---

## Release checklist (copy-paste per release)

```
- [ ] Build all platforms in HelloWord repo (scripts/build-android.sh, npx tauri build, scripts/build-windows.sh)
- [ ] Read HelloWord/src-tauri/tauri.conf.json to get canonical version
- [ ] Read HelloWord/src/version.json to get build number
- [ ] Copy artifacts to HelloWord-Website/downloads/
      cp HelloWord/dist-android/SanctissiMissa-Android-v{VER}-release-signed.apk downloads/
      cp HelloWord/dist-linux/SanctissiMissa_{TAURIVER}_amd64.AppImage downloads/
      cp HelloWord/dist-linux/SanctissiMissa_{TAURIVER}_amd64.deb downloads/
      cp HelloWord/dist-windows/SanctissiMissa-Windows-v{VER}-build{BUILD}-x64.exe downloads/
- [ ] Compute hashes: sha256sum downloads/SanctissiMissa-*
- [ ] Update SITE_CONFIG in index.html (top of <head>):
      - version, build, releaseDate
      - artifacts.*.file (exact filenames)
      - artifacts.*.sha256 (computed hashes)
      - changelog[] (prepend new entry)
- [ ] Test locally: python3 -m http.server 8080
      - All download links resolve (200, not 404)
      - Version badges show correct version
      - SHA256 checksums match
      - YouTube plays correctly
      - Changelog renders
- [ ] Upload artifacts to hosting:
      - LXC: rsync downloads/ to helloword.robin.mba
      - StackCP: sftp downloads/ to sanctissimissa.online
- [ ] Deploy updated index.html to both hosting targets
- [ ] Verify live site: download links, version badges, checksums
```

---

## Desync detection

If the iframe'd web app (`sanctissimissa-app.robin.mba`) shows a different version
than `SITE_CONFIG.version`, the release is incomplete. The web app is deployed
independently (PWA build → nginx) and can advance ahead of the download artifacts.
This must be treated as a release blocker.
