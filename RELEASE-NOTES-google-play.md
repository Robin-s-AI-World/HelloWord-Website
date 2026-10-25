# Google Play website update

Website: https://github.com/Robin-s-AI-World/HelloWord-Website
Existing-app release source found: https://github.com/Robin-s-AI-World/HelloWord
Production listing: https://play.google.com/store/apps/details?id=mba.robin.helloword

The live website index matched the repository index byte for byte before editing.
Google Play identifies the app as Hello, Word: Latin Mass Missal and lists an update on 18 October 2026.
Robin-s-AI-World/HelloWord has a v2.39.76881 Android release stamp dated 21 October 2026 and package identifier mba.robin.helloword. HelloWord-April2026 is an April v2.33 snapshot; HelloWord-v2 is a distinct rewrite, not the existing Play app. A GitHub release stamp is not proof of the Play production build, so the website links to Play without claiming its version. The embedded deployment currently reports v2.32.91178.

Two Android install buttons now use the official Google Play badge. Direct APK links, APK checksum links, and sideload instructions have been removed. Existing v2.33 desktop artifacts retain their original labels and checksums. Three screenshots come from the production listing. The embedded app URL is preserved pending verification of the current deployment.

Deploy index.html, icons/google-play-badge.png, and previews/ to the existing SanctissiMissa.online document root. The package contains only these changed public assets. No app build or hosting deployment is included. Do not run the existing rsync --delete deployment script blindly: the remote document root also holds downloads.

Removed a pre-existing script containing only an unmatched closing brace, reproduced both on the live page and the original checkout.

Product direction confirmed: HelloWord is maintenance-only. The planned final production app update addresses Android 16 KB memory page size compatibility; no new features are included here. SanctissiMissa.com introduces the separate active product. API integration work is out of scope.
