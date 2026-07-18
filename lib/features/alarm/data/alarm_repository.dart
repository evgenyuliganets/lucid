import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/alarm/data/alarm_channel.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';

/// The alarm and the phone/watch readiness, as [Result]s.
class AlarmRepository {
  const AlarmRepository(this._channel);

  final AlarmChannel _channel;

  Future<Result<AlarmOverview>> load() => _guard(_channel.getState);

  Future<Result<AlarmOverview>> save(AlarmSettings settings) =>
      _guard(() => _channel.saveSettings(settings));

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on AppFailure catch (failure) {
      return FailureResult(failure);
    }
  }
}
