import 'package:flutter/services.dart';
import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';
import 'package:lucid/features/sleep/domain/sleep_record.dart';
import 'package:lucid/features/sleep/domain/sleep_stage.dart';
import 'package:lucid/features/sleep/domain/watch_night.dart';

/// The native `lucid/sleep` channel: Samsung Health's sleep records and the
/// watch's night reports. Throws [AppFailure] on a platform error or a
/// malformed reply; a Samsung read failure carries the [SamsungStatus] name
/// as its code.
class SleepChannel {
  SleepChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('lucid/sleep');

  final MethodChannel _channel;

  Future<SamsungStatus> samsungStatus() async =>
      SamsungStatus.parse(_string(await _call('status')));

  /// Asks Samsung Health for sleep access (its own permission screen).
  Future<SamsungStatus> connectSamsung() async =>
      SamsungStatus.parse(_string(await _call('connect')));

  Future<List<SleepRecord>> readSamsung(DateTime from, DateTime to) async {
    final reply = await _call('readSleep', {
      'from': from.millisecondsSinceEpoch,
      'to': to.millisecondsSinceEpoch,
    });
    final records = _parse(reply, (item) {
      // A night Samsung has not closed yet has no end; it is skipped.
      if (item['end'] == null) return null;
      final sessions = (item['sessions'] as List).cast<Map>();
      return SleepRecord(
        start: _time(item['start']),
        end: _time(item['end']),
        score: item['score'] as int?,
        stages: [
          for (final session in sessions)
            for (final stage in (session['stages'] as List).cast<Map>())
              StageSpan(
                start: _time(stage['start']),
                end: _time(stage['end']),
                stage: SleepStage.parse(stage['stage'] as String),
              ),
        ]..sort((a, b) => a.start.compareTo(b.start)),
      );
    });
    return records.nonNulls.toList();
  }

  Future<List<WatchNight>> watchNights() async {
    final reply = await _call('watchNights');
    return _parse(reply, (item) {
      return WatchNight(
        windowStart: _time(item['windowStart']),
        windowEnd: _time(item['windowEnd']),
        trackingStart: _time(item['trackingStart']),
        wokeAt: item['wokeAt'] == null ? null : _time(item['wokeAt']),
        reason: WakeReason.parse(item['reason'] as String?),
        dismissedAt: item['dismissedAt'] == null
            ? null
            : _time(item['dismissedAt']),
      );
    });
  }

  Future<Object?> _call(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<Object?>(method, arguments);
    } on PlatformException catch (error) {
      throw AppFailure(
        'lucid/sleep $method failed',
        code: error.code,
        cause: error,
      );
    }
  }

  List<T> _parse<T>(Object? reply, T Function(Map item) parse) {
    try {
      return (reply! as List).cast<Map>().map(parse).toList();
    } on Object catch (error) {
      throw AppFailure('lucid/sleep reply is malformed', cause: error);
    }
  }

  String? _string(Object? reply) {
    if (reply is String?) return reply;
    throw AppFailure('lucid/sleep reply is malformed', cause: reply);
  }

  static DateTime _time(Object? millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis! as int);
}
