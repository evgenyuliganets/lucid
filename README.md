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

Both release builds are signed with the debug key for now; the phone and the
watch app must be signed with the same key or they cannot talk to each other.

## Install

- Phone: `adb install -r app-release.apk`, or copy the APK to the phone and
  open it.
- Watch: the phone app's Setup screen walks through it (developer mode on the
  watch, wireless debugging, `adb pair`, `adb connect`,
  `adb install -r lucid-watch.apk`).

Then open Lucid on the phone and follow Setup until every step is green, and
open Lucid on the watch once to allow notifications and the alarm screen.

Samsung Health sleep stages (optional): Samsung Health → Settings → About
Samsung Health → tap the version 10 times → Developer mode → "Developer Mode
for Data Read", then Setup → Samsung Health → Connect.

## Checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
cd android && ./gradlew :shared:test :wear:assembleDebug
```
