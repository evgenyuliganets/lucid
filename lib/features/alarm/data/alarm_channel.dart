import 'package:flutter/services.dart';
import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';
import 'package:lucid/features/alarm/domain/phone_readiness.dart';
import 'package:lucid/features/alarm/domain/wake_window.dart';
import 'package:lucid/features/alarm/domain/watch_state.dart';

/// The native `lucid/alarm` channel: the alarm lives in native storage so it
/// can be re-armed after a reboot and changed by the watch without Flutter.
///
/// Every call throws [AppFailure] on a platform error or a malformed reply.
class AlarmChannel {
  AlarmChannel([MethodChannel? channel])
    : _channel = channel ?? const MethodChannel('lucid/alarm');

  final MethodChannel _channel;

  /// Fires when native state changed outside Flutter (watch status, a
  /// dismissal on the watch). Only one listener is supported.
  void onChanged(VoidCallback? listener) {
    _channel.setMethodCallHandler(
      listener == null
          ? null
          : (call) async {
              if (call.method == 'changed') listener();
            },
    );
  }

  Future<AlarmOverview> getState() async => _overview(await _call('getState'));

  Future<AlarmOverview> saveSettings(AlarmSettings settings) async {
    final days = settings.days.toList()..sort();
    return _overview(
      await _call('saveSettings', {
        'enabled': settings.enabled,
        'wakeByMinute': settings.wakeByMinute,
        'windowMinutes': settings.windowMinutes,
        'days': days,
      }),
    );
  }

  /// Shows the system prompt (or the app's notification settings when the
  /// prompt can no longer be shown) and returns the state after it.
  Future<AlarmOverview?> requestNotifications() async {
    final reply = await _call('requestNotifications');
    return reply is Map ? _overview(reply) : null;
  }

  Future<void> openExactAlarmSettings() => _call('openExactAlarmSettings');

  Future<void> openFullScreenSettings() => _call('openFullScreenSettings');

  Future<void> requestBatteryUnrestricted() =>
      _call('requestBatteryUnrestricted');

  Future<bool> openWearApp() async => await _call('openWearApp') == true;

  Future<void> testAlarm() => _call('testAlarm');

  Future<Object?> _call(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<Object?>(method, arguments);
    } on PlatformException catch (error) {
      throw AppFailure(
        'lucid/alarm $method failed',
        code: error.code,
        cause: error,
      );
    }
  }

  AlarmOverview _overview(Object? reply) {
    try {
      final map = reply! as Map;
      final settings = map['settings'] as Map;
      final window = map['nextWindow'] as Map?;
      final phone = map['phone'] as Map;
      final watch = map['watch'] as Map;
      final status = watch['status'] as Map?;
      return AlarmOverview(
        settings: AlarmSettings(
          enabled: settings['enabled'] as bool,
          wakeByMinute: settings['wakeByMinute'] as int,
          windowMinutes: settings['windowMinutes'] as int,
          days: (settings['days'] as List).cast<int>().toSet(),
        ),
        nextWindow: window == null
            ? null
            : WakeWindow(
                start: _time(window['start'] as int),
                end: _time(window['end'] as int),
              ),
        phone: PhoneReadiness(
          notifications: phone['notifications'] as bool,
          exactAlarms: phone['exactAlarms'] as bool,
          fullScreen: phone['fullScreen'] as bool,
          batteryUnrestricted: phone['batteryUnrestricted'] as bool,
        ),
        watch: WatchState(
          connected: watch['connected'] as bool,
          installed: watch['installed'] as bool,
          name: watch['name'] as String?,
          status: status == null
              ? null
              : WatchAppStatus(
                  notifications: status['notifications'] as bool,
                  fullScreen: status['fullScreen'] as bool,
                  heartRate: status['heartRate'] as bool,
                  armedWindowEnd: switch (status['armedWindowEnd']) {
                    final int end => _time(end),
                    _ => null,
                  },
                  tracking: status['tracking'] as bool,
                  appVersion: status['appVersion'] as String,
                ),
        ),
      );
    } on Object catch (error) {
      throw AppFailure('lucid/alarm reply is malformed', cause: error);
    }
  }

  static DateTime _time(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis);
}
