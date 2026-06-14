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

## 1. Project status

This repo currently contains the **Dart/Flutter source code** (`lib/`),
bundled Surah/Para metadata (`assets/data/`), and `pubspec.yaml`. The native
Android/iOS platform folders are **not** included yet — generate them with
`flutter create .` (see below).

## 2. One-time setup

```bash
# from the repo root
flutter create . --org com.yourcompany --project-name bangla_quran
flutter pub get
```

This generates `android/`, `ios/`, etc. without touching your `lib/` code.

### App icon / name

- Update the app display name in `android/app/src/main/AndroidManifest.xml`
  (`android:label="Bangla Quran"`).
- Replace icons under `android/app/src/main/res/mipmap-*/` with your channel
  logo (or use a tool like `flutter_launcher_icons`).

### Background audio permissions (Android)

`just_audio_background` needs a media service declared in
`android/app/src/main/AndroidManifest.xml`, inside `<application>`:

```xml
<service android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>

<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</receiver>
```

And these permissions inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

## 3. Firebase setup (for uploading recitation links)

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

## 4. Run

```bash
flutter run
```

## 5. Build for Google Play

```bash
flutter build appbundle --release
```

Upload the generated `.aab` from `build/app/outputs/bundle/release/` to the
Play Console.

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
