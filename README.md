# Lucid

A smart sleep alarm. You pick the latest wake-up time and a smart window (for
example 06:30-07:00). Your Galaxy Watch listens to your sleep during the window
and gently vibrates at a restless, light-sleep moment; if none comes, the watch
and the phone ring at the latest time. In the morning the phone shows the
night's sleep stages from Samsung Health and whether Lucid woke you in light
sleep.

- `lib/`: the Flutter phone app (Android only).
- `android/app`: its native side: the fallback alarm, the watch link, Samsung
  Health.
- `android/wear`: the Wear OS app for Galaxy Watch4 and newer.
- `android/shared`: Kotlin shared by both (alarm schedule, wake detector,
  sync format).

Samsung creates its sleep stages only after you wake up, so they never drive
the alarm itself; the watch decides on its own from movement and, if allowed,
heart rate.

## Build

1. Samsung Health Data SDK: download it from Samsung Developers and copy
   `samsung-health-data-api-1.1.0.aar` into `android/app/libs/` (kept out of
   git).
2. Phone app:

   ```sh
   flutter pub get
   flutter build apk --release
   ```

   Output: `build/app/outputs/flutter-apk/app-release.apk`.
3. Watch app:

   ```sh
   cd android
   ./gradlew :wear:assembleRelease
   ```

   Output: `build/wear/outputs/apk/release/wear-release.apk`.

## Release

Both apps ship in one Play listing (`com.greetyy.lucid`): the phone bundle on
the normal tracks, the watch bundle on the "Wear OS only" tracks. Version codes
must be unique across both: the phone uses `pubspec.yaml` (1, 2, ...), the
watch `100_000 + n` in `android/wear/build.gradle.kts`.

Release builds are signed with the upload key from `android/key.properties`
(git-ignored; it points to a keystore outside the repo). Play re-signs both
apps with the same app signing key, so they can talk to each other.

```sh
flutter build appbundle --release
cd android && ./gradlew :wear:bundleRelease
```

Store graphics (Play icon, feature graphic, phone screenshots in English and
Ukrainian) are rendered from the real screens into `build/store/`:

```sh
flutter test tool/render_store_assets_test.dart
```

The launcher icon is the vector adaptive icon in `res/drawable` and
`res/mipmap-anydpi-v26` (the same files in `android/app` and `android/wear`).
The privacy policy is [PRIVACY.md](PRIVACY.md), linked from Setup.

## Install

Testers join the internal test in a browser, install Lucid from Play on the
phone, then use Setup → "Open on the watch" to install it on the watch.
Sideloading (`adb install`) works too, but then both apps must come from the
same local build, not mixed with Play.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
cd android && ./gradlew :shared:test :wear:assembleDebug
```
