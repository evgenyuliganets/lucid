import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/alarm/alarm_providers.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';

final alarmControllerProvider =
    AsyncNotifierProvider<AlarmController, AlarmOverview>(AlarmController.new);

/// The alarm and readiness of the phone and the watch.
///
/// Reloads on its own when the app returns to the foreground (the user may
/// have changed a permission in Settings) and when native code reports a
/// change from the watch. A reload keeps the shown data until the new one
/// arrives.
class AlarmController extends AsyncNotifier<AlarmOverview> {
  @override
  Future<AlarmOverview> build() async {
    final channel = ref.watch(alarmChannelProvider);
    final lifecycle = AppLifecycleListener(onResume: refresh);
    channel.onChanged(refresh);
    ref.onDispose(() {
      lifecycle.dispose();
      channel.onChanged(null);
    });
    return (await ref.read(alarmRepositoryProvider).load()).unwrap();
  }

  Future<void> refresh() async {
    final result = await ref.read(alarmRepositoryProvider).load();
    if (!ref.mounted) return;
    state = switch (result) {
      Success(:final value) => AsyncData(value),
      FailureResult(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Saves, re-arms both devices and returns the failure, if any; on failure
  /// the shown alarm stays as it was.
  Future<AppFailure?> save(AlarmSettings settings) async {
    final result = await ref.read(alarmRepositoryProvider).save(settings);
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        return null;
      case FailureResult(:final failure):
        return failure;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.value?.settings;
    if (current == null || current.enabled == enabled) return;
    await save(current.copyWith(enabled: enabled));
  }

  Future<void> requestNotifications() async {
    final overview = await _run(
      ref.read(alarmChannelProvider).requestNotifications,
    );
    if (overview != null && ref.mounted) state = AsyncData(overview);
  }

  Future<void> openExactAlarmSettings() =>
      _run(ref.read(alarmChannelProvider).openExactAlarmSettings);

  Future<void> openFullScreenSettings() =>
      _run(ref.read(alarmChannelProvider).openFullScreenSettings);

  Future<void> requestBatteryUnrestricted() =>
      _run(ref.read(alarmChannelProvider).requestBatteryUnrestricted);

  Future<void> openWearApp() =>
      _run(ref.read(alarmChannelProvider).openWearApp);

  Future<void> testAlarm() => _run(ref.read(alarmChannelProvider).testAlarm);

  /// Settings screens are best effort: a failure to open one leaves state as is.
  Future<T?> _run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppFailure {
      return null;
    }
  }
}
