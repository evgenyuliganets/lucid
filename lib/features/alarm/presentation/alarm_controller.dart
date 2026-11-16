import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/alarm/alarm_providers.dart';
import 'package:lucid/features/alarm/data/alarm_repository.dart';
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
  AlarmRepository get _repository => ref.read(alarmRepositoryProvider);

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
    final result = await _repository.load();
    if (!ref.mounted) return;
    state = switch (result) {
      Success(:final value) => AsyncData(value),
      FailureResult(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Saves, re-arms both devices and returns the failure, if any; on failure
  /// the shown alarm stays as it was.
  Future<AppFailure?> save(AlarmSettings settings) async {
    final result = await _repository.save(settings);
    if (!ref.mounted) return null;
    switch (result) {
      case Success(:final value):
        state = AsyncData(value);
        return null;
      case FailureResult(:final failure):
        return failure;
    }
  }

  Future<AppFailure?> setEnabled(bool enabled) async {
    final current = state.value?.settings;
    if (current == null || current.enabled == enabled) return null;
    return save(current.copyWith(enabled: enabled));
  }

  Future<void> requestNotifications() async {
    final result = await _repository.requestNotifications();
    if (!ref.mounted) return;
    if (result case Success(value: final overview?)) {
      state = AsyncData(overview);
    }
  }

  // Settings screens are best effort; the state reloads when the app resumes.
  Future<void> openExactAlarmSettings() => _repository.openExactAlarmSettings();

  Future<void> openFullScreenSettings() => _repository.openFullScreenSettings();

  Future<void> requestBatteryUnrestricted() =>
      _repository.requestBatteryUnrestricted();

  Future<void> testAlarm() => _repository.testAlarm();

  /// False when Galaxy Wearable is missing, so the UI can say where to get it.
  Future<bool> openWearApp() async => switch (await _repository.openWearApp()) {
    Success(:final value) => value,
    FailureResult() => false,
  };

  /// Opens the Play Store on the watch; false when the watch did not answer.
  Future<bool> installOnWatch() async =>
      switch (await _repository.installOnWatch()) {
        Success(:final value) => value,
        FailureResult() => false,
      };
}
