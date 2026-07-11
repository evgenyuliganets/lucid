# Lucid agent guidance

Smart sleep alarm: the user picks a wake window, Lucid wakes them at a
lighter-sleep moment inside it, with a hard deadline at the end of the window.
A Flutter phone app (Android only) plus a planned Kotlin Wear OS app for
Galaxy Watch. Shape: the owner's `app_product` Flutter template.

## Product facts that shape the code

- Samsung creates its sleep stages only after the user wakes up. Never build
  alarm logic on Samsung Health data (Data SDK or Health Connect): it is
  morning-only, used to check and tune Lucid's own detector.
- The wake decision comes from Lucid's own live detector on the watch (movement
  and heart rate). The phone holds settings, statistics and a fallback exact
  alarm at the deadline.
- Application id `com.greetyy.lucid`. The watch app must use the same
  application id and signing key, or the Wear Data Layer link between them does
  not work. Samsung partnership registration is tied to this id and the release
  key's SHA-256.

## What to read

Read only what the task needs: the affected files, their tests and one sibling
that solves the same kind of problem. Until the first real feature exists, the
template's example slice `lib/features/catalog/` shows the pattern; delete it
when the first real feature follows the same pattern.

## Where files go

Place new files by these rules, not by the nearest example, and review against
them:

- `lib/app/`: bootstrap and `MaterialApp`. No business rules.
- `lib/core/`: small cross-feature primitives with at least two consumers
  (`Result`/`AppFailure`). The template's `Dio` provider stays only if a
  feature needs HTTP.
- `lib/design_system/`: theme, `AppColors` (`context.appColors`),
  `AppSpacing`. Add a token only when a widget consumes it.
- `lib/features/<feature>/`: `domain/` (Flutter-free models), `data/`
  (external boundaries: Samsung SDK and platform channels, repositories),
  `presentation/` (Riverpod providers, notifiers, pages, widgets),
  `<feature>_providers.dart` (data-layer wiring). Features never import
  `lib/app/`.
- One public widget per file, named after it. Tests mirror `lib/` under
  `test/`.
- Android (phone): Kotlin in `android/app/src/main/kotlin/com/greetyy/lucid/`.
  Native code returns plain values over a method channel; business rules stay
  in Dart.

## Code rules

- Dependencies flow `presentation -> domain` and `data -> domain`;
  presentation reaches repositories only through `<feature>_providers.dart`.
  Domain imports only Dart and `core/result`.
- Riverpod 3 is the only DI and state system.
- External boundaries throw `AppFailure`; repositories return `Result<T>`;
  controllers turn it into `AsyncValue`. Never compare failure message
  strings.
- State holders show no snackbars and do not navigate; widgets use
  `ref.listen`. After an `await`, check `mounted` / `ref.mounted`.
- Widgets: no widget-returning methods or functions and no widget locals in
  `build`; colours from `colorScheme` / `context.appColors`, spacing from
  `AppSpacing`, text styles from `textTheme`; icon-only buttons have tooltips.
- Samsung Health Data SDK (when added): `minSdk` 29, Kotlin coroutines; the
  AAR stays out of git (vendor binary) and is read from a local path. Use the
  Data SDK API (`HealthDataService.getStore`, `DataTypes.SLEEP`), never the
  deprecated `HealthDataStore`/`HealthConstants` SDK; there is no API-key file.
- No abstractions, options or packages "for later".

## Before handing over

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
```

## Commits

- Subject: a short lowercase sentence saying what the change does.
- No AI co-author or "generated with" lines.
- Commit, push or build a release only when the owner asks.
