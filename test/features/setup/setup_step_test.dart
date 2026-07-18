import 'package:flutter_test/flutter_test.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';
import 'package:lucid/features/alarm/domain/phone_readiness.dart';
import 'package:lucid/features/alarm/domain/watch_state.dart';
import 'package:lucid/features/setup/domain/setup_step.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';

void main() {
  const settings = AlarmSettings(
    enabled: true,
    wakeByMinute: 420,
    windowMinutes: 30,
    days: {1, 2, 3, 4, 5},
  );
  const readyStatus = WatchAppStatus(
    notifications: true,
    fullScreen: true,
    heartRate: false,
    armedWindowEnd: null,
    tracking: false,
    appVersion: '1.0.0',
  );

  AlarmOverview overview({
    bool phoneReady = true,
    bool connected = true,
    bool installed = true,
    WatchAppStatus? status = readyStatus,
  }) => AlarmOverview(
    settings: settings,
    nextWindow: null,
    phone: PhoneReadiness(
      notifications: phoneReady,
      exactAlarms: phoneReady,
      fullScreen: phoneReady,
      batteryUnrestricted: false,
    ),
    watch: WatchState(
      connected: connected,
      installed: installed,
      name: 'Galaxy Watch6',
      status: status,
    ),
  );

  test('everything required in place leaves nothing to do', () {
    expect(SetupStep.requiredLeft(overview(), null), 0);
  });

  test('recommended steps never count as required', () {
    expect(SetupStep.battery.isDone(overview(), null), isFalse);
    expect(SetupStep.samsung.isDone(overview(), SamsungStatus.ready), isTrue);
    expect(
      SetupStep.requiredLeft(overview(), SamsungStatus.developerModeNeeded),
      0,
    );
  });

  test('a fresh phone without a watch has all required steps open', () {
    final fresh = overview(
      phoneReady: false,
      connected: false,
      installed: false,
      status: null,
    );
    expect(SetupStep.requiredLeft(fresh, null), 6);
  });

  test('an installed watch app that has not reported yet needs finishing', () {
    final waiting = overview(status: null);
    expect(SetupStep.watchApp.isDone(waiting, null), isTrue);
    expect(SetupStep.watchFinish.isDone(waiting, null), isFalse);
  });
}
