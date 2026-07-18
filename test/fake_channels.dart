import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A `lucid/alarm` getState reply as the native side builds it.
Map<String, Object?> alarmStateReply({
  bool phoneReady = true,
  bool watchInstalled = true,
  bool watchReady = true,
}) => {
  'settings': {
    'enabled': true,
    'wakeByMinute': 420,
    'windowMinutes': 30,
    'days': [1, 2, 3, 4, 5],
  },
  'nextWindow': {
    'start': DateTime(2026, 11, 17, 6, 30).millisecondsSinceEpoch,
    'end': DateTime(2026, 11, 17, 7).millisecondsSinceEpoch,
  },
  'phone': {
    'notifications': phoneReady,
    'exactAlarms': phoneReady,
    'fullScreen': phoneReady,
    'batteryUnrestricted': false,
  },
  'watch': {
    'connected': true,
    'installed': watchInstalled,
    'name': 'Galaxy Watch6',
    'statusAt': 1,
    'status': watchReady
        ? {
            'notifications': true,
            'fullScreen': true,
            'heartRate': false,
            'armedWindowEnd': DateTime(2026, 11, 17, 7).millisecondsSinceEpoch,
            'tracking': false,
            'appVersion': '1.0.0',
          }
        : null,
  },
};

/// Answers both native channels with [alarmState] and an empty night list.
/// Returns the calls received, for assertions.
List<MethodCall> fakeChannels(Map<String, Object?> alarmState) {
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(const MethodChannel('lucid/alarm'), (
    call,
  ) async {
    calls.add(call);
    return switch (call.method) {
      'getState' || 'saveSettings' => alarmState,
      _ => null,
    };
  });
  messenger.setMockMethodCallHandler(const MethodChannel('lucid/sleep'), (
    call,
  ) async {
    calls.add(call);
    return switch (call.method) {
      'status' => 'developerModeNeeded',
      'watchNights' => <Object?>[],
      _ => null,
    };
  });
  return calls;
}
