/// The one alarm Lucid has; the phone owns it and syncs it to the watch.
///
/// [wakeByMinute] is the latest wake time in minutes after midnight; the smart
/// window is the [windowMinutes] before it. [days] are ISO weekdays
/// (1 = Monday) of the wake time; empty means a one-time alarm.
class AlarmSettings {
  const AlarmSettings({
    required this.enabled,
    required this.wakeByMinute,
    required this.windowMinutes,
    required this.days,
  });

  static const windowChoices = [10, 20, 30, 45, 60];
  static const minutesPerDay = 24 * 60;
  static const maxWindowMinutes = 90;

  final bool enabled;
  final int wakeByMinute;
  final int windowMinutes;
  final Set<int> days;

  int get windowStartMinute => (wakeByMinute - windowMinutes) % minutesPerDay;

  bool get isOneTime => days.isEmpty;

  AlarmSettings copyWith({
    bool? enabled,
    int? wakeByMinute,
    int? windowMinutes,
    Set<int>? days,
  }) {
    return AlarmSettings(
      enabled: enabled ?? this.enabled,
      wakeByMinute: wakeByMinute ?? this.wakeByMinute,
      windowMinutes: windowMinutes ?? this.windowMinutes,
      days: days ?? this.days,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AlarmSettings &&
      other.enabled == enabled &&
      other.wakeByMinute == wakeByMinute &&
      other.windowMinutes == windowMinutes &&
      other.days.length == days.length &&
      other.days.containsAll(days);

  @override
  int get hashCode => Object.hash(
    enabled,
    wakeByMinute,
    windowMinutes,
    Object.hashAllUnordered(days),
  );
}
