/// Why the watch rang.
enum WakeReason {
  lightSleep,
  deadline;

  static WakeReason? parse(String? value) => switch (value) {
    'LIGHT_SLEEP' => WakeReason.lightSleep,
    'DEADLINE' => WakeReason.deadline,
    _ => null,
  };
}

/// One night as Lucid's watch app saw it.
class WatchNight {
  const WatchNight({
    required this.windowStart,
    required this.windowEnd,
    required this.trackingStart,
    required this.wokeAt,
    required this.reason,
    required this.dismissedAt,
  });

  final DateTime windowStart;
  final DateTime windowEnd;
  final DateTime trackingStart;

  /// Null when the watch did not ring (the phone rang first).
  final DateTime? wokeAt;
  final WakeReason? reason;
  final DateTime? dismissedAt;

  @override
  bool operator ==(Object other) =>
      other is WatchNight &&
      other.windowStart == windowStart &&
      other.windowEnd == windowEnd &&
      other.trackingStart == trackingStart &&
      other.wokeAt == wokeAt &&
      other.reason == reason &&
      other.dismissedAt == dismissedAt;

  @override
  int get hashCode => Object.hash(
    windowStart,
    windowEnd,
    trackingStart,
    wokeAt,
    reason,
    dismissedAt,
  );
}
