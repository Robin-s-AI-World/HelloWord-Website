# Project Index: HelloWord-Website (SanctissiMissa Infosite)

Generated: 2026-04-08
Version: v2.33 Build 92878 (from `index.html:8-9` `SITE_CONFIG.version` / `SITE_CONFIG.build`)
Repo type: Static HTML site (no build step, Tailwind via CDN)
License: Copyright (C) 2025-2026 Robin L. M. Cheung, MBA — Private repository

> **Paired index contract.** This file has a machine-readable sibling at `PROJECT_INDEX.json`. Both files MUST match on `generated`, `version`, file counts, and gotcha counts. If they diverge, treat both as suspect and regenerate from source. See user global CLAUDE.md → "Paired Index Integrity Rules".

> **Cross-references — single source of truth for facts maintained outside this repo:**
> - CI runner topology, IPs, container IDs, label strings: `~/forgejo/VE-forgejo-runners/README.md`
> - Upstream → downstream artifact contract (HelloWord → HelloWord-Website): `DOCS/CROSS-REPO-CONTRACTS.md`
> - Self-hosted runner & PAT env-var conventions: `~/.claude/CLAUDE.md` (CI / Self-Hosted Runners)

---

## Project Overview

Public-facing landing page and documentation for **SanctissiMissa**, a Traditional Latin Mass (1962 Extraordinary Form) digital companion. This repo contains:

1. The marketing/landing site (`index.html`, ~1,740 lines, vanilla HTML + Tailwind CDN + Chart.js, **all config-driven via `SITE_CONFIG` JS block** as of 2026-04-08).
2. A real-time CI/CD status dashboard (`status.html`).
3. A standalone privacy policy page (`privacy-policy.html`).
4. **Synced mirrors** of two production sites under `domains/` (read-only snapshots from servers, not source).
5. **Infrastructure-as-docs** under `infrastructure/` — nginx configs, deployment scripts, server runbooks.
6. **Architect-mode artifacts** (`CHECKLIST.md`, `DOCS/`) — currently in active use by a concurrent agent.

### Live Sites

| Domain | Purpose | Hosting | Nginx Config |
|---|---|---|---|
| https://helloword.robin.mba | Info site (this repo) | LXC `192.168.0.126:18081` | `infrastructure/nginx/conf.d/sanctissimissa-infosite.conf` |
| https://sanctissimissa-app.robin.mba | Web App (PWA) | LXC `192.168.0.126` | `infrastructure/nginx/conf.d/sanctissimissa-app.conf` |
| https://sanctissimissa.online | Mirror of info site | StackCP shared hosting | (external; SFTP only) |

---

## Active Concurrent Architect Work

Another agent (Windsurf-Claude) has been running the global CLAUDE.md architect-mode workflow in this repo. Tracking files:

- `CHECKLIST.md` (39 lines) — task contract for "Deduplicate Config, Fix CSP/YouTube, Audit Downloads"
- `DOCS/ARCHITECTURE/dedup-csp-youtube-downloads.md` — architecture doc
- `DOCS/CROSS-REPO-CONTRACTS.md` — **canonical** upstream/downstream artifact contract

**Status as of this index**: Tasks 1-7, 9, 10 are complete. The major outcome is that **all hardcoded version/URL/hash literals in `index.html` have been refactored into a single `SITE_CONFIG` JavaScript block at `index.html:7-33`**. Remaining tasks: 8 (upload v2.33 artifacts to sanctissimissa.online), 11 (browser-verify nav scroll), 12 (mirror CROSS-REPO-CONTRACTS to HelloWord repo).

**Implication for tooling**: Anything that previously used `sed` or regex against hardcoded strings in `index.html` (e.g., the CI workflow — see Gotcha #7) is now broken and needs to target `SITE_CONFIG` field updates instead.

---

## File Map (Root)

| Path | Purpose | Notes |
|---|---|---|
| `index.html` | Primary landing page | 1,740 lines, Tailwind CDN, dark/light theme, **`SITE_CONFIG` block at lines 7-33 is the version source of truth** |
| `status.html` | CI/CD status dashboard | 55 lines, polls release API |
| `privacy-policy.html` | App privacy policy | 253 lines, untracked, standalone styling (purple gradient — does NOT match parchment/gold theme of `index.html`); now linked from `index.html:1266` footer |
| `manifest.json` | PWA manifest | Theme `#B8860B` gold, 3 icon sizes |
| `deploy-to-lxc.sh` | **Legacy** deploy script | Duplicated at `infrastructure/deployment/deploy-to-lxc.sh` — see Gotcha #1 |
| `README.md` | Restore/migration runbook | 379 lines, infrastructure-focused |
| `CHECKLIST.md` | Architect-mode task contract (Windsurf) | 39 lines, untracked, see "Active Concurrent Architect Work" above |
| `PROJECT_INDEX.md` | This file | Pairs with `PROJECT_INDEX.json` |
| `.gitignore` | Excludes secrets, downloads, sshfs mounts | `*.key`, `.env*`, `downloads/*.apk`, `HELLOWORD.ROBIN.MBA/`, `SANCTISSIMISSA.ONLINE/` |

### Media Assets (root)

| File | Bytes | Use |
|---|---:|---|
| `robin-poet.jpg` | 46,118 | Author headshot, embedded in `index.html` |
| `Sanctissimissa-Infographic-18mar2026.png` | 5,247,553 | Architecture diagram |
| `AI__The_New_Blueprint.mp4` | 35,285,241 | Project vision video |
| `AI_agents_build_the_1962_Latin_Mass.m4a` | 36,724,332 | AI-generated podcast |

### Staged (Undeployed) Release Artifacts — `downloads/`

Gitignored. As of 2026-04-08, contains **v2.33 build 92878** artifacts staged but **not yet uploaded** to sanctissimissa.online (CHECKLIST task 8 pending):

| File | Bytes | Type |
|---|---:|---|
| `SanctissiMissa-Android-v2.33-release-signed.apk` | 130,006,493 | Android |
| `SanctissiMissa_0.2.33_amd64.AppImage` | 99,203,576 | Linux AppImage |
| `SanctissiMissa_0.2.33_amd64.deb` | 26,635,406 | Linux DEB |
| `SanctissiMissa-Windows-v2.33-build92878-x64.exe` | 20,082,905 | Windows |

Total: 4 files, ~264 MB. Filename patterns are documented in `DOCS/CROSS-REPO-CONTRACTS.md`.

---

## Directory Structure

```
HelloWord-Website/
├── index.html                       # Landing page (1,740 lines, SITE_CONFIG-driven)
├── status.html                      # CI/CD dashboard (55 lines)
├── privacy-policy.html              # Privacy policy (253 lines, untracked, off-brand)
├── manifest.json                    # PWA manifest
├── deploy-to-lxc.sh                 # ⚠️ Legacy duplicate — see Gotcha #1
├── README.md                        # Restore/migration runbook
├── CHECKLIST.md                     # ← Windsurf architect-mode contract
├── PROJECT_INDEX.md                 # ← this file
├── PROJECT_INDEX.json               # ← machine-readable sibling
├── DOCS/                            # ← Windsurf architect-mode output
│   ├── ARCHITECTURE/
│   │   └── dedup-csp-youtube-downloads.md
│   └── CROSS-REPO-CONTRACTS.md      # Canonical upstream/downstream contract
├── downloads/                       # Gitignored; staged v2.33 artifacts (4 files, 264 MB)
├── icons/                           # 4 favicons (svg, 32x32, 192x192, apple-touch)
├── Technical-HowItWorks/            # 8 large media files (videos, PDFs, infographics)
├── domains/                         # READ-ONLY mirrors of deployed sites (gotcha #5)
│   ├── helloword.robin.mba/
│   └── sanctissimissa-app.robin.mba/
│       ├── index.html               # PWA shell (1,197 bytes)
│       ├── liturgical.db            # SQLite, 27 MB — Mass propers, calendar
│       ├── sql-wasm.js              # SQL.js runtime (46 KB)
│       ├── manifest.json
│       ├── assets/                  # 8 hashed JS/CSS bundles (Vite output)
│       ├── icons/                   # 8 PWA icons + shortcut icons
│       └── plugins/situ-design/     # 4 bundled plugin chunks
├── .github/
│   └── workflows/
│       └── update-downloads.yml     # ⚠️ ubuntu-latest + stale sed patterns — Gotchas #2 & #7
└── infrastructure/
    ├── SERVER.md                    # Top-level server runbook
    ├── api/RELEASE_API.md           # Release API contract
    ├── deployment/                  # 3 scripts (canonical location)
    │   ├── deploy-to-lxc.sh
    │   ├── deploy-to-stackcp.sh
    │   └── sync-nginx-to-server.sh
    ├── nginx/
    │   ├── nginx.conf
    │   ├── conf.d/                  # 17 per-domain .conf files
    │   └── snippets/proxy-params.conf
    ├── nginx-ui/
    │   ├── CREDENTIALS.md
    │   └── NGINX-UI-SYNC.md
    ├── proxmox/LXC-nginx-ui.md
    └── shared-hosting/STACKCP.md    # Updated 2026-04-08 by Windsurf to v2.33 filenames
```

---

## Entry Points

| Type | Path | Description |
|---|---|---|
| Web (primary) | `index.html` | Landing page; loaded as `/` on all three domains |
| Web (status) | `status.html` | CI/CD dashboard; polls release API |
| Web (legal) | `privacy-policy.html` | App store privacy policy |
| Config (NEW) | `index.html:7-33` | `SITE_CONFIG` JS block — single source of truth for all version, URL, hash, changelog values |
| PWA | `manifest.json` | Theme `#B8860B`, standalone display |
| Deploy (canonical) | `infrastructure/deployment/deploy-to-lxc.sh` | rsync to `deploy@192.168.0.126:/var/www/sanctissimissa-infosite/releases/<ts>/` then symlink |
| Deploy (StackCP) | `infrastructure/deployment/deploy-to-stackcp.sh` | SFTP push (rsync unavailable) |
| Deploy (nginx) | `infrastructure/deployment/sync-nginx-to-server.sh` | Push nginx confs to LXC |
| CI | `.github/workflows/update-downloads.yml` | Triggered by `repository_dispatch` from main app repo — see Gotchas #2 and #7 |

---

## CI & Runners

**Authoritative source:** `~/forgejo/VE-forgejo-runners/README.md`. Do not duplicate runner facts here — link to that file.

Repo-local summary (the absolute minimum a new agent needs to avoid interrupting the user):

- This repo's CI runs on the self-hosted **Forgejo Actions runner** (LXC CT 124, hostname `forgejo-runner.robin.mba`). It is **not** on `192.168.0.126` (that's the nginx LXC) and **not** on `192.168.0.83` (that was a failed GitHub self-hosted runner install).
- Workflow files should live in `.forgejo/workflows/*.yml` per sibling-repo convention (`HelloWord/`, `DeepScriber/`). Currently this repo's only workflow still lives in `.github/workflows/` — see Gotcha #2 for the migration.
- Runner labels (registered in Forgejo): `linux-amd64`, `android`, `windows-x64-cross`. Use **bare** strings, **not** `[self-hosted, ...]` wrapping (that wrapping is GitHub Actions syntax).
- Forgejo authoritative remote: `https://git.robin.mba/rcheung/HelloWord-Website.git` (currently blank — initial push pending).
- PAT env vars (in `~/.bashrc`): `$GITHUB_API_KEY` for github.com, `$FORGEJO_API_KEY` for git.robin.mba.
- Forgejo project secret needed by the workflow: `FORGEJO_API_KEY` (set via Forgejo UI → Settings → Secrets).

---

## Nginx Domains (17 configs in `infrastructure/nginx/conf.d/`)

| Config | Domain | Purpose |
|---|---|---|
| `sanctissimissa-infosite.conf` | helloword.robin.mba | This repo's landing page |
| `sanctissimissa-app.conf` | sanctissimissa-app.robin.mba | Web App (PWA) |
| `git.conf` | git.robin.mba | Forgejo |
| `n8n.conf` | n8n.robin.mba | n8n automation |
| `draw.conf` | draw.robin.mba | Draw.io |
| `apisms.conf` | apisms.robin.mba | SMS gateway |
| `searxng.conf` | searxng.robin.mba | Search |
| `paper.conf` / `paperless.conf` | paper.robin.mba | Paperless-ngx |
| `odoo.conf` | odoo.robin.mba | ERP |
| `missa.conf` | missa.robin.mba | Redirect |
| `tuba.conf` | tuba.robin.mba | Mastodon client |
| `umbrel.conf` | umbrel.robin.mba | Umbrel |
| `npmplus.conf` | (npm-plus) | Reverse proxy mgmt |
| `robins-courses.conf` | (courses) | Courses site |
| `strapi.conf` | (strapi) | Strapi CMS |
| `00-upgrade-map.conf` | (shared) | WebSocket upgrade map |

---

## CI/CD

- **Workflow**: `.github/workflows/update-downloads.yml`
- **Trigger**: `repository_dispatch` types `update-downloads` or `new-release` (from main SanctissiMissa app repo) + `workflow_dispatch` manual.
- **Inputs**: `version`, `build_number`, `apk_url`, `exe_url`, `apk_hash`, `exe_hash`.
- **Steps (CURRENT — broken post-SITE_CONFIG refactor)**: download new APK/EXE → recompute SHA256 → `sed -i` patch hardcoded strings in `index.html` → write `downloads/hashes.json` → commit → POST to `DEPLOY_WEBHOOK_URL`.
- **Runner**: ❌ `ubuntu-latest` — violates global CLAUDE.md (Gotcha #2).
- **Patch logic**: ❌ targets hardcoded strings that no longer exist after Windsurf's refactor (Gotcha #7).

---

## Versioning

- Format: `v{MAJOR}.{MINOR}.{BUILD}` — e.g., `v2.33.92878`
- Build number scheme (per README): `(epoch % 100) * 1000 + minutes_past_hour`
- **Source of truth (NEW)**: `index.html:8-9` inside the `SITE_CONFIG` block:
  ```js
  var SITE_CONFIG = {
      version: '2.33',
      build: '92878',
      releaseDate: '7 April 2026',
      ...
  };
  ```
- Previous (now-stale) source: a hardcoded `<span>v2.17 · Build 76952</span>` and `data-version="…"` attribute. Both have been replaced by JS-driven population from `SITE_CONFIG`.
- Upstream version contract (HelloWord → this repo): `DOCS/CROSS-REPO-CONTRACTS.md`.

---

## Gotchas / Active Issues

> Authoritative count: **7 gotchas**. Must match `PROJECT_INDEX.json → gotchas.length`.

1. **Two `deploy-to-lxc.sh` files.** Root-level `./deploy-to-lxc.sh` is the legacy version; the README references `./infrastructure/deployment/deploy-to-lxc.sh` as canonical. They differ in argument handling. Pick one and delete the other to prevent drift.

2. **GitHub workflow uses hosted runner.** `.github/workflows/update-downloads.yml:29` declares `runs-on: ubuntu-latest`, which violates the user's global CLAUDE.md ("All CI runs on self-hosted runners. GitHub Actions hosted runners are not used"). Should be `runs-on: linux-amd64` (bare label for Forgejo Actions, NOT `[self-hosted, linux-amd64]`). The file should also move from `.github/workflows/` to `.forgejo/workflows/` per sibling-repo convention. **High priority** — runner-cost risk.

3. **PROJECT_INDEX requires manual refresh.** No CI hook updates this pair when `index.html` changes. Past versions of this index showed `0.1.1-alpha` while live site was many releases ahead. CI sed-patches `index.html` but not the index pair — accept that the index is regenerated on demand via `/sc:index-repo`, or add an index-update step to whatever process bumps version.

4. **`privacy-policy.html` styling diverges from brand — and is now linked from the landing page footer.** Uses purple gradient (`#667eea → #764ba2`) instead of the parchment/gold/crimson palette in `index.html`. Looks like an unedited template. `index.html:1266` links to it from the footer, so this off-brand page IS reachable from production. Re-skin before next deploy. (File is also still untracked — `?? privacy-policy.html` in `git status`.)

5. **`domains/` is a snapshot, not source.** Files under `domains/helloword.robin.mba/` and `domains/sanctissimissa-app.robin.mba/` are READ-ONLY mirrors fetched from production servers. Editing them does nothing. Edit `index.html` at the repo root and deploy via the canonical script.

6. **No build step / no `package.json`.** This is intentional — Tailwind, Chart.js, and Google Fonts load via CDN. Do not introduce a build pipeline without explicit user consent. Vercel/Next.js skill suggestions auto-injected by hooks (when reading workflow or README files) **must be ignored** for this repo: deployment is self-hosted nginx LXC per global CLAUDE.md, not Vercel.

7. **CI workflow `sed` patterns are stale post-refactor.** `.github/workflows/update-downloads.yml:80,83-84` regex-patches hardcoded strings (`data-version="…"`, `sanctissimissa-android-apk-…\.apk`, `SanctissiMissa-Windows-…\.exe`) in `index.html`. After Windsurf's `SITE_CONFIG` refactor (CHECKLIST tasks 1-7, complete 2026-04-08), those hardcoded strings no longer exist — they live inside the `SITE_CONFIG` JS block now. The next workflow trigger will silently no-op the version bump. **The workflow needs a coordinated rewrite** to patch `SITE_CONFIG.version` / `SITE_CONFIG.build` / `SITE_CONFIG.artifacts` fields instead. Should be addressed in the same change as Gotcha #2.

---

## File Counts (parity with JSON)

| Category | Count |
|---|---:|
| HTML pages (root) | 3 |
| Markdown docs (total) | 11 |
| Nginx `.conf` files | 17 |
| Deployment shell scripts (canonical) | 3 |
| Deployment shell scripts (legacy at root) | 1 |
| GitHub Actions workflows | 1 |
| Forgejo Actions workflows | 0 (target after Gotcha #2 fix) |
| Icons (root) | 4 |
| Synced domain mirrors | 2 |
| Staged release artifacts (downloads/) | 4 |
| Architect-mode docs (DOCS/) | 2 |
| Gotchas tracked | 7 |

Markdown breakdown: `README.md`, `CHECKLIST.md`, `PROJECT_INDEX.md`, `DOCS/ARCHITECTURE/dedup-csp-youtube-downloads.md`, `DOCS/CROSS-REPO-CONTRACTS.md`, `infrastructure/SERVER.md`, `infrastructure/api/RELEASE_API.md`, `infrastructure/nginx-ui/CREDENTIALS.md`, `infrastructure/nginx-ui/NGINX-UI-SYNC.md`, `infrastructure/proxmox/LXC-nginx-ui.md`, `infrastructure/shared-hosting/STACKCP.md`.

---

## Quick Start

```bash
# Local preview (no build needed)
python3 -m http.server 8080
# or
npx serve .

# Deploy to LXC (canonical path)
./infrastructure/deployment/deploy-to-lxc.sh helloword

# Deploy to StackCP shared hosting
./infrastructure/deployment/deploy-to-stackcp.sh

# Push nginx confs
./infrastructure/deployment/sync-nginx-to-server.sh
```

---

## Related Documentation

**In-repo:**
- `README.md` — full restore/migration runbook (servers, SSL, DNS, app deps)
- `CHECKLIST.md` — Windsurf architect-mode task contract
- `DOCS/ARCHITECTURE/dedup-csp-youtube-downloads.md` — SITE_CONFIG refactor architecture
- `DOCS/CROSS-REPO-CONTRACTS.md` — **canonical** upstream/downstream artifact contract
- `infrastructure/SERVER.md` — server overview
- `infrastructure/api/RELEASE_API.md` — release API contract used by `status.html`
- `infrastructure/shared-hosting/STACKCP.md` — StackCP-specific notes (updated 2026-04-08 to v2.33 filenames)
- `infrastructure/nginx-ui/NGINX-UI-SYNC.md` — Nginx-UI sync strategy
- `infrastructure/nginx-ui/CREDENTIALS.md` — secrets reference
- `infrastructure/proxmox/LXC-nginx-ui.md` — Proxmox LXC info

**External canonical sources:**
- `~/forgejo/VE-forgejo-runners/README.md` — Forgejo runner topology, IPs, container, label strings
- `~/.claude/CLAUDE.md` — global runner policy, namespace conventions, PAT env-var naming
- `~/.claude/CONVENTIONS.md` — naming SOP (companion doc, always loaded)

---

*Index pair last regenerated 2026-04-08 by `/sc:index-repo`. Both `PROJECT_INDEX.md` and `PROJECT_INDEX.json` were written together; if you find a discrepancy, regenerate both.*
