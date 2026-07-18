# Lucid agent guidance

Smart sleep alarm: the user picks a wake window, Lucid wakes them at a
lighter-sleep moment inside it, with a hard deadline at the end of the window.
A Flutter phone app (Android only) and a Kotlin Wear OS app for Galaxy Watch.
Shape: the owner's `app_product` Flutter template.

## Product facts that shape the code

- Samsung creates its sleep stages only after the user wakes up. Never build
  alarm logic on Samsung Health data (Data SDK or Health Connect): it is
  morning-only, used to show the night and check Lucid's wake moment.
- The wake decision is made on the watch by Lucid's own detector (movement and
  optional heart rate) in `android/shared` `WakeDetector`. The phone holds the
  alarm, rings as a fallback at the window end, and shows the mornings.
- Application id `com.greetyy.lucid` for both apps, same signing key, or the
  Wear Data Layer between them does not work. Samsung partnership registration
  is tied to this id and the release key's SHA-256.

## Where things are

- `lib/`: the Flutter phone app.
  - `app/`: bootstrap and `MaterialApp`. No business rules.
  - `core/`: `Result`/`AppFailure`, time formatting (`context.clock`, ...).
  - `design_system/`: theme, `AppColors` (`context.appColors`, incl. sleep
    stage colours), `AppSpacing`. Add a token only when a widget consumes it.
  - `l10n/`: ARB files (`en` is the template, `uk` must get every key) and
    `l10n.dart` (`context.l10n`). Generated `app_localizations*.dart` are
    committed; regenerate with `flutter gen-l10n`.
  - `features/alarm`: the alarm, phone permissions, the watch state
    (channel `lucid/alarm`).
  - `features/sleep`: past nights from Samsung Health and the watch
    (channel `lucid/sleep`).
  - `features/setup`: the one-time setup checklist and guides; composes
    `alarm` and `sleep`.
  - `features/home`: the first screen; composes the others.
  - `alarm` and `sleep` never import each other or `setup`/`home`; nothing
    in `features/` imports `lib/app/`.
- `android/app`: the phone's native side (`com.greetyy.lucid`):
  `PhoneAlarm` (fallback alarm, ring notification, dismiss/snooze),
  `PhoneStore` (the alarm lives here so boot and the watch can re-arm without
  Flutter), `WatchLink` + `WatchListenerService` (Data Layer),
  `AlarmChannel`, `SleepChannel` (Samsung Health Data SDK), `RingActivity`.
- `android/wear`: the watch app (`com.greetyy.lucid.wear` namespace):
  `NightSchedule` (arms tracking and the deadline), `NightService` (health
  foreground service: sensors → detector → vibration and ring screen),
  `PhoneLink` + `PhoneListenerService`, `MainActivity` (status and
  permissions), `RingActivity`.
- `android/shared`: plain Kotlin used by both: `AlarmSettings` (next window),
  `WakeDetector`/`EpochAccumulator`, `Sync` paths and the encoded formats.

## Sync between phone and watch

- Data Layer items, one encoded string under `value` (see `Sync.kt`):
  phone → watch `/lucid/settings`, `/lucid/phone/dismissed`;
  watch → phone `/lucid/watch/status`, `/lucid/night/<windowEnd>`,
  `/lucid/watch/dismissed`.
- Dismissing on either device stops both and marks the window handled
  (`handledWindowEnd`), so the next arm skips it. A one-time alarm is switched
  off by the phone after it rang.

## Code rules

- Dart: dependencies flow `presentation -> domain` and `data -> domain`;
  presentation reaches repositories only through `<feature>_providers.dart`.
  Domain imports only Dart and `core/`.
- Riverpod 3 is the only DI and state system; `ProviderScope(retry: ...)`
  disables automatic retries.
- Channel adapters throw `AppFailure` (code = the native error code);
  repositories return `Result<T>`; controllers turn it into `AsyncValue`.
  Native replies are validated in the adapter. Never compare message strings.
- State holders show no snackbars and do not navigate; after an `await`,
  check `mounted` / `ref.mounted`.
- Widgets: no widget-returning methods or functions and no widget locals in
  `build`; colours from `colorScheme` / `context.appColors`, spacing from
  `AppSpacing`, text styles from `textTheme`; no hard-coded user-facing
  strings; icon-only buttons have tooltips.
- Kotlin: decisions in `android/shared` with JVM tests; Android classes stay
  thin. Native strings in `res/values` and `res/values-uk`.
- Samsung Health Data SDK: `android/app/libs/samsung-health-data-api-1.1.0.aar`
  is a vendor binary kept out of git (README). Use the Data SDK API
  (`HealthDataService.getStore`, `DataTypes.SLEEP`), never the deprecated
  `HealthDataStore`/`HealthConstants` SDK; there is no API-key file.
- No abstractions, options or packages "for later".

## Before handing over

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
cd android && ./gradlew :shared:test :wear:assembleDebug
flutter build apk --debug
```

## Commits

- Subject: a short lowercase sentence saying what the change does.
- No AI co-author or "generated with" lines.
- Commit, push or build a release only when the owner asks.
