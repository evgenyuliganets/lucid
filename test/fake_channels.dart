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

/// One Samsung night (23:00-07:05) and the watch night that woke at 06:35.
final samsungNightReply = <Object?>[
  {
    'start': DateTime(2026, 11, 16, 23).millisecondsSinceEpoch,
    'end': DateTime(2026, 11, 17, 7, 5).millisecondsSinceEpoch,
    'score': 81,
    'sessions': [
      {
        'start': DateTime(2026, 11, 16, 23).millisecondsSinceEpoch,
        'end': DateTime(2026, 11, 17, 7, 5).millisecondsSinceEpoch,
        'stages': [
          {
            'start': DateTime(2026, 11, 16, 23).millisecondsSinceEpoch,
            'end': DateTime(2026, 11, 17, 3).millisecondsSinceEpoch,
            'stage': 'deep',
          },
          {
            'start': DateTime(2026, 11, 17, 3).millisecondsSinceEpoch,
            'end': DateTime(2026, 11, 17, 7, 5).millisecondsSinceEpoch,
            'stage': 'light',
          },
        ],
      },
    ],
  },
  // Not closed yet: skipped, must not hide the other night.
  {'start': 1, 'end': null, 'score': null, 'sessions': <Object?>[]},
];

final watchNightReply = <Object?>[
  {
    'windowStart': DateTime(2026, 11, 17, 6, 30).millisecondsSinceEpoch,
    'windowEnd': DateTime(2026, 11, 17, 7).millisecondsSinceEpoch,
    'trackingStart': DateTime(2026, 11, 17, 6).millisecondsSinceEpoch,
    'wokeAt': DateTime(2026, 11, 17, 6, 35).millisecondsSinceEpoch,
    'reason': 'LIGHT_SLEEP',
    'dismissedAt': DateTime(2026, 11, 17, 6, 36).millisecondsSinceEpoch,
    'epochs': <Object?>[],
  },
];

/// Answers both native channels with [alarmState] and, when [withNights],
/// a connected Samsung Health with one night. Returns the calls received.
List<MethodCall> fakeChannels(
  Map<String, Object?> alarmState, {
  bool withNights = false,
}) {
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
      'status' => withNights ? 'ready' : 'developerModeNeeded',
      'watchNights' => withNights ? watchNightReply : <Object?>[],
      'readSleep' => samsungNightReply,
      _ => null,
    };
  });
  return calls;
}
