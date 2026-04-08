# CHECKLIST: Deduplicate Config, Fix CSP/YouTube, Audit Downloads

Architecture doc: `DOCS/ARCHITECTURE/dedup-csp-youtube-downloads.md`
Cross-repo contract: `DOCS/CROSS-REPO-CONTRACTS.md`

---

## Completed Tasks

- [x] **1. Remove CSP meta tag** — Deleted restrictive `Content-Security-Policy` meta tag. Grep confirms 0 results.

- [x] **2. Add SITE_CONFIG script block** — Placed at top of `<head>` (lines 6-33), right after `<meta charset>`. Contains: version, build, releaseDate, youtubeVideoId, youtubeStartSec, downloadBaseUrl, webAppUrl, artifacts (apk/exe/appimage/deb with file+sha256), changelog[].

- [x] **3. Add `id` attributes** — All config-driven elements tagged: `cfg-version-hero`, `cfg-version-downloads`, `cfg-version-footer`, `cfg-dl-hero-apk`, `cfg-dl-apk`, `cfg-dl-exe`, `cfg-dl-appimage`, `cfg-dl-deb`, `cfg-install-appimage`, `cfg-install-deb`, `cfg-checksums`, `cfg-changelog`, `cfg-yt-thumb`, `cfg-webapp-open`, `cfg-webapp-launch`, `showcase-iframe`.

- [x] **4. Write DOMContentLoaded config-population logic** — JS block populates all version badges, download hrefs, YouTube thumbnail, web app URLs, checksums block, install instructions, and changelog from `SITE_CONFIG`. Zero hardcoded duplicates remain.

- [x] **5. Refactor openYTLightbox()** — Now reads `SITE_CONFIG.youtubeVideoId` + `SITE_CONFIG.youtubeStartSec`. Old video ID `qWvaGBiEl9I` eliminated.

- [x] **6. Add changelog section** — `<div id="cfg-changelog">` placed below SHA256 checksums block, rendered from `SITE_CONFIG.changelog[]` on DOMContentLoaded.

- [x] **7. Verify + update artifacts to v2.33.92878** — Confirmed actual filenames from HelloWord repo builds. SHA256 hashes computed for all 4 artifacts. SITE_CONFIG updated with real values.

- [x] **9. Update STACKCP.md** — Directory tree updated from stale v0.1.1-alpha filenames to current v2.33 naming.

- [x] **10. Create CROSS-REPO-CONTRACTS.md** — Documents upstream (HelloWord) → downstream (HelloWord-Website) version contract, artifact filename patterns, hosting targets, sync mechanism, and release checklist.

## Remaining Tasks

- [ ] **8. Upload v2.33 artifacts to sanctissimissa.online/downloads/**
  - Artifacts staged in `HelloWord-Website/downloads/` (4 files, 264 MB total)
  - Upload via SFTP to `ssh.gb.stackcp.com` or rsync to LXC
  - Verify: Every download link returns 200, not 404.

- [ ] **11. Browser-verify nav scroll positions**
  - Serve index.html locally, click each nav link, confirm it scrolls to the correct section.
  - Verify: All 10 nav links (#hero through #about) land on their respective sections.

- [ ] **12. Create CROSS-REPO-CONTRACTS.md in HelloWord repo** (mirror copy)
