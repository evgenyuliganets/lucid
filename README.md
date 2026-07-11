# Lucid

A smart sleep alarm. You pick a wake window (for example 06:30-07:30); Lucid
wakes you at a lighter-sleep moment inside it and rings at the end of the
window if no such moment comes.

- Phone: this Flutter app (Android only): window settings, morning sleep
  statistics, a fallback alarm.
- Watch: a Kotlin Wear OS app for Galaxy Watch (planned): reads movement and
  heart rate during the night and decides the wake moment on the wrist.
- Samsung Health: the Samsung Health Data SDK reads each night's sleep stages
  in the morning to check the detector. Samsung creates those stages only after
  the user wakes up, so they never drive the alarm itself.

Application id: `com.greetyy.lucid` (the watch app must use the same id).

## Run

```sh
flutter pub get
flutter run
```

## Architecture

The app follows the owner's `app_product` template: feature-first vertical
slices with explicit external boundaries.

```text
lib/
  app/                    # bootstrap and app shell
  core/                   # small cross-feature primitives
  design_system/          # semantic theme tokens
  features/<feature>/
    data/                  # external boundaries (SDKs, platform channels), repository
    domain/                # Flutter-free product concepts
    presentation/          # Riverpod controller and widgets
    <feature>_providers.dart
```

Dependencies flow `presentation -> domain` and `data -> domain`. The domain
never imports `data` or `presentation`. Riverpod is the single DI and state
system. Repositories translate failures into a typed `Result`; controllers
translate that result into UI state.

`features/catalog` is the template's example slice. It stays until the first
real feature follows the same pattern, then it is deleted.
