# Architecture: Deduplicate Config, Fix CSP/YouTube, Audit Downloads

## Summary

Introduce a single `SITE_CONFIG` JS object in `index.html` so every version, URL, hash, date, and video ID is defined exactly once. Remove the restrictive CSP meta tag. Fix the YouTube video ID. Verify all download links. Add a changelog section.

## Data Flow

```
SITE_CONFIG (JS object, defined once near top of <body>)
    │
    ├─► DOMContentLoaded handler
    │       ├─► populates version badges (hero, downloads, footer)
    │       ├─► sets YouTube thumbnail + embed src
    │       ├─► sets all download hrefs
    │       ├─► renders SHA256 checksum block
    │       ├─► renders changelog history
    │       └─► sets web-app iframe + link hrefs
    │
    └─► openYTLightbox() reads SITE_CONFIG.youtubeVideoId
```

## Entity Table

| Entity | Type | File:line | Role | Key signatures / fields |
|--------|------|-----------|------|------------------------|
| CSP meta tag | HTML meta | index.html:374 | Restricts frame-src; blocks YouTube | `<meta http-equiv="Content-Security-Policy" ...>` |
| SITE_CONFIG | JS object | index.html (NEW, ~line 377) | Single source of truth for all repeated values | version, build, releaseDate, youtubeVideoId, youtubeStartSec, downloadBaseUrl, webAppUrl, artifacts{}, changelog[] |
| Version badge (hero) | HTML span | index.html:432 | Shows `v2.17 · Build 76952` | Add `id="cfg-version-hero"` |
| Version badge (downloads) | HTML strong | index.html:937 | Shows `v2.17.76952` + date | Add `id="cfg-version-downloads"` |
| Version badge (footer) | HTML text | index.html:1186 | Shows `v2.17.76952` | Add `id="cfg-version-footer"` |
| Hero APK button | HTML a | index.html:463 | APK download (hero section) | Add `id="cfg-dl-hero-apk"` |
| APK card link | HTML a | index.html:946 | APK download card | Add `id="cfg-dl-apk"` |
| Windows card link | HTML a | index.html:959 | EXE download card | Add `id="cfg-dl-exe"` |
| AppImage card link | HTML a | index.html:979 | AppImage download card | Add `id="cfg-dl-appimage"` |
| DEB card link | HTML a | index.html:994 | DEB download card | Add `id="cfg-dl-deb"` |
| AppImage install instructions | HTML code | index.html:983-984 | Shows filename in install commands | Add `id="cfg-install-appimage"` |
| DEB install instructions | HTML code | index.html:998 | Shows filename in install commands | Add `id="cfg-install-deb"` |
| SHA256 checksums block | HTML div | index.html:1009-1016 | Shows hash + filename per artifact | Add `id="cfg-checksums"` |
| Changelog section | HTML div | index.html (NEW, after checksums) | Rendered from SITE_CONFIG.changelog[] | Add `id="cfg-changelog"` |
| YouTube thumbnail | HTML img | index.html:469 | Thumbnail from img.youtube.com | Add `id="cfg-yt-thumb"` |
| YouTube embed | JS function | index.html:495 | Sets iframe src on click | openYTLightbox() reads SITE_CONFIG |
| Web app iframe | HTML iframe | index.html:446-447 | Embedded app showcase | Add `id="showcase-iframe"` (already has id) |
| Web app "Open Full Screen" link | HTML a | index.html:462 | Links to web app | Add `id="cfg-webapp-open"` |
| Web app "Launch" link | HTML a | index.html:971 | Links to web app from downloads | Add `id="cfg-webapp-launch"` |
| sanctissimissa-infosite.conf | nginx conf | infrastructure/nginx/conf.d/sanctissimissa-infosite.conf | No CSP headers (confirmed clean) | N/A |

## Decisions

1. **Remove CSP entirely** rather than adding YouTube to whitelist — user explicitly instructed removal for all reasons.
2. **JS config object + DOMContentLoaded** rather than server-side templating — this is a static HTML site with no build step.
3. **Config placed in a `<script>` tag just after `<body>`** so it's available before any HTML element references it.
4. **Artifact filenames**: Need browser verification against `sanctissimissa.online/downloads/` before finalizing. STACKCP.md documents show ancient `v0.1.1-alpha` files, while index.html references v2.14–v2.17. Actual server state is unknown until verified.
5. **Changelog**: Rendered from `SITE_CONFIG.changelog[]` array, newest first, placed below SHA256 block.
