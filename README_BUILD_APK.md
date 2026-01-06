# Build an installable Android APK (no Flutter on phone needed)

This repo includes a GitHub Actions workflow that builds an **installable debug APK** and lets you download it.

## Steps (GitHub Actions)

1. Create a new GitHub repository (public or private).
2. Upload **all files** from this folder to the repo (or `git push`).
3. In GitHub, go to **Actions**.
4. Click **Build Android APK (Debug)** on the left.
5. Click **Run workflow**.
6. Wait for it to finish, then open the workflow run.
7. Scroll to **Artifacts** and download **dh2e-acolyte-debug-apk**.

The downloaded zip contains `app-debug.apk`.

## Install on Android

1. Copy `app-debug.apk` to your phone (Downloads is fine).
2. Tap the file to install.
3. If blocked: Settings → Apps → Special access → **Install unknown apps** → allow for Files/Chrome.

## Notes

- Debug APK is easiest to install because it doesn't require release signing.
- If you later want a Play Store release, we can add proper signing + an AAB build.
