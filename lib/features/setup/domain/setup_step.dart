import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';

/// Everything the user sets up once, in the order the setup screen shows.
enum SetupStep {
  notifications(required: true),
  exactAlarms(required: true),
  fullScreen(required: true),
  watchPaired(required: true),
  watchApp(required: true),
  watchFinish(required: true),
  battery(required: false),
  samsung(required: false);

  const SetupStep({required this.required});

  /// Required steps block a working alarm; the rest are recommended.
  final bool required;

  bool isDone(AlarmOverview alarm, SamsungStatus? samsung) => switch (this) {
    SetupStep.notifications => alarm.phone.notifications,
    SetupStep.exactAlarms => alarm.phone.exactAlarms,
    SetupStep.fullScreen => alarm.phone.fullScreen,
    SetupStep.watchPaired => alarm.watch.connected || alarm.watch.installed,
    SetupStep.watchApp => alarm.watch.installed,
    SetupStep.watchFinish => alarm.watch.ready,
    SetupStep.battery => alarm.phone.batteryUnrestricted,
    SetupStep.samsung => samsung == SamsungStatus.ready,
  };

  /// Required steps still open; what the home banner counts.
  static int requiredLeft(AlarmOverview alarm, SamsungStatus? samsung) =>
      SetupStep.values
          .where((step) => step.required && !step.isDone(alarm, samsung))
          .length;
}
