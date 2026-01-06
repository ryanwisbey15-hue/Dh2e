# Build an Android APK (no local Flutter install)

This project includes a GitHub Actions workflow that builds an **installable Android APK** for you.

## What you need
- A free GitHub account
- An Android phone

## Steps
1. **Create a new GitHub repository** (public or private).
2. **Upload this project** to the repo.
   - Easiest: use the GitHub web UI → *Add file → Upload files* → drag the project contents.
   - Make sure the folder `.github/workflows/build-apk.yml` is included.
3. Go to the repo’s **Actions** tab.
4. In the left sidebar, click **Build Android APK (Debug)**.
5. Click **Run workflow**.
6. Wait for the run to finish.
7. Open the finished run → under **Artifacts**, download **dh2e-acolyte-debug-apk**.
8. Unzip the artifact; you’ll get `app-debug.apk`.

## Install on Android
1. Copy `app-debug.apk` to your phone.
2. Tap it to install.
3. If blocked:
   - Android Settings → Apps → Special access → **Install unknown apps**
   - Allow it for Files/Chrome (whichever you used to open the APK).

## Notes
- This builds a **debug APK** because it installs easily without you needing to manage signing keys.
- If you later want a Play Store release build, we can add proper release signing and produce an `.aab`.
