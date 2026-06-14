# Bangla Quran

A Flutter audio app for listening to your **Bangla Quran** YouTube channel's
Bengali-translation recitation of the Holy Qur'an, organized into:

- **সূরা প্লেলিস্ট (Surah Playlist)** – all 114 Surahs
- **পারা প্লেলিস্ট (Para Playlist)** – all 30 Paras (Juz)
- **ডাউনলোড (Downloads)** – offline listening

Theme color: **Islamic Green** (`#0E6B3A`). Playback resumes automatically
from the exact track + position the user left off at, even after the app is
closed (background audio + lock-screen controls included).

---

## 🚀 What YOU need to do (no coding needed)

The app itself is fully built. Here's the simple, non-technical checklist to
turn it into something on your phone and on the Play Store:

1. **Prepare your audio files** — one MP3 per Surah (114 files) and/or per
   Para (30 files). Name them however you like, e.g. `001_al_fatiha.mp3`.

2. **Create a free Firebase account** and upload your audio + paste the
   links into the app's data — see **"Firebase setup"** below. This is the
   only step where you connect *your* recitations to the app.

3. **Build the installable app file** — you don't need to install anything
   on your computer. Use a free service called **Codemagic**
   (https://codemagic.io):
   - Sign up with your GitHub account.
   - Connect this repository (`pakumia/bangla-quran`).
   - Choose "Flutter App" → Android → it auto-detects everything.
   - Click "Start new build" → it produces an `.apk` (install on your phone
     to test) and `.aab` (the file the Play Store needs).

4. **Test it** — download the `.apk` from Codemagic to your Android phone
   and install it (you may need to allow "install from unknown sources").

5. **Publish to Google Play** — create a Google Play Developer account
   (one-time $25 fee at https://play.google.com/console), create a new app,
   upload the `.aab` file from step 3, fill in your app's description,
   screenshots, and your channel logo as the icon, then submit for review.

If you get stuck on any step, come back and tell me exactly where — I can
walk you through it or adjust the project.

---

## 1. Project status

This repo contains a complete, working Flutter app:

- `lib/` – all the app's Dart code
- `assets/data/` – the 114 Surah and 30 Para names/info
- `android/` – the Android project (already configured with the
  permissions and background-audio service it needs)

`flutter analyze` and `flutter test` both pass. The only things left are
things only **you** can do (see "What you need to do" below), since they
involve your Firebase account, your audio files, and your app icon/branding.

### App icon / name

The app is currently named "Bangla Quran" (set in
`android/app/src/main/AndroidManifest.xml`). To use your channel's logo as
the app icon, replace the files under `android/app/src/main/res/mipmap-*/`
(named `ic_launcher.png`, different sizes per folder), or use the
`flutter_launcher_icons` package to generate them automatically from one
image.

## 2. Firebase setup (for uploading recitation links)

The app reads bundled Surah/Para info from `assets/data/surahs.json` and
`assets/data/paras.json`, then merges in **audio URLs** from a Firestore
collection called `tracks`. This means you can publish new recitations
without releasing an app update.

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app (and iOS app if needed) with package name matching
   your `android/app/build.gradle` `applicationId`.
3. Download `google-services.json` into `android/app/`.
4. Run `flutterfire configure` (or manually create `lib/firebase_options.dart`)
   to wire up `Firebase.initializeApp()`.
5. Enable **Cloud Firestore**.
6. For each Surah/Para, add a document to the `tracks` collection:
   - Document ID: `surah_1` ... `surah_114` for Surahs, `para_1` ... `para_30` for Paras
   - Field: `audioUrl` (string) — direct link (e.g. Firebase Storage download URL)
     to your uploaded MP3 for that Surah/Para.

   Example document `tracks/surah_1`:
   ```json
   { "audioUrl": "https://firebasestorage.googleapis.com/.../001_al_fatiha.mp3" }
   ```

7. Upload your audio files to **Firebase Storage** (or any direct-link host)
   and paste the public download URLs into the corresponding `audioUrl`
   fields.

> Until `audioUrl` is set for a track, the app shows
> "এই অডিওটি এখনো আপলোড করা হয়নি" (not uploaded yet) and disables
> play/download for that item.

If Firebase isn't configured at all, the app still runs fine — it just
won't have any audio links until you add them.

## 3. Run (for developers)

```bash
flutter run
```

## 4. Build for Google Play (for developers)

```bash
flutter build appbundle --release
```

Upload the generated `.aab` from `build/app/outputs/bundle/release/` to the
Play Console. If you'd rather not install Flutter yourself, use the
Codemagic option in the checklist above instead.

---

## Project structure

```
lib/
  models/        Track + PlaylistType data models
  services/      LibraryService (metadata + Firestore), DownloadManager,
                  PlaybackStorage (last-session persistence)
  providers/     PlayerProvider (just_audio playback, queue, resume)
  screens/       Splash, Home (tabs), Playlist, Player, Downloads
  widgets/       MiniPlayer, TrackTile
  theme/         Islamic Green theme
assets/data/     surahs.json (114), paras.json (30) – static metadata
```

## Key features implemented

- **Surah Playlist** (114) and **Para Playlist** (30) tabs
- **Resume last session**: track id + position saved continuously and on
  pause/seek; restored (paused) on next app launch
- **Offline downloads** per Surah/Para with progress indicator and delete
- **Background playback** with lock-screen / notification controls
- **Islamic Green** themed UI throughout
