import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/sleep/data/sleep_channel.dart';
import 'package:lucid/features/sleep/domain/night.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';
import 'package:lucid/features/sleep/domain/sleep_overview.dart';
import 'package:lucid/features/sleep/domain/sleep_record.dart';

/// Past nights from both sources. A Samsung failure does not hide the
/// watch's nights; it is reported in [SleepOverview.samsungReadFailed].
class SleepRepository {
  const SleepRepository(this._channel);

  static const _history = Duration(days: 14);

  final SleepChannel _channel;

  Future<Result<SleepOverview>> load(DateTime now) async {
    try {
      final watchNights = await _channel.watchNights();
      var samsung = await _channel.samsungStatus();
      var records = const <SleepRecord>[];
      var readFailed = false;
      if (samsung == SamsungStatus.ready) {
        try {
          records = await _channel.readSamsung(now.subtract(_history), now);
        } on AppFailure catch (failure) {
          readFailed = true;
          samsung = SamsungStatus.parse(failure.code);
        }
      }
      return Success(
        SleepOverview(
          samsung: samsung,
          nights: mergeNights(records, watchNights),
          samsungReadFailed: readFailed,
        ),
      );
    } on AppFailure catch (failure) {
      return FailureResult(failure);
    }
  }

  Future<Result<SamsungStatus>> connectSamsung() async {
    try {
      return Success(await _channel.connectSamsung());
    } on AppFailure catch (failure) {
      return FailureResult(failure);
    }
  }
}
