/// One night's smart window; the alarm rings at [end] at the latest.
class WakeWindow {
  const WakeWindow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      other is WakeWindow && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}
