import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/alarm/data/alarm_channel.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';

/// The alarm, the phone's permission screens and the watch, as [Result]s.
class AlarmRepository {
  const AlarmRepository(this._channel);

  final AlarmChannel _channel;

  Future<Result<AlarmOverview>> load() => _guard(_channel.getState);

  Future<Result<AlarmOverview>> save(AlarmSettings settings) =>
      _guard(() => _channel.saveSettings(settings));

  /// The new state when the system prompt answered; null when Settings opened.
  Future<Result<AlarmOverview?>> requestNotifications() =>
      _guard(_channel.requestNotifications);

  Future<Result<void>> openExactAlarmSettings() =>
      _guard(_channel.openExactAlarmSettings);

  Future<Result<void>> openFullScreenSettings() =>
      _guard(_channel.openFullScreenSettings);

  Future<Result<void>> requestBatteryUnrestricted() =>
      _guard(_channel.requestBatteryUnrestricted);

  Future<Result<void>> openPrivacyPolicy() =>
      _guard(_channel.openPrivacyPolicy);

  /// False when Galaxy Wearable is not installed.
  Future<Result<bool>> openWearApp() => _guard(_channel.openWearApp);

  /// False when no watch took the request.
  Future<Result<bool>> installOnWatch() => _guard(_channel.installOnWatch);

  Future<Result<void>> testAlarm() => _guard(_channel.testAlarm);

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on AppFailure catch (failure) {
      return FailureResult(failure);
    }
  }
}
