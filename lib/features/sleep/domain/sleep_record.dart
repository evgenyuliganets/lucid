import 'package:lucid/features/sleep/domain/sleep_stage.dart';

/// One stage interval of a Samsung Health night.
class StageSpan {
  const StageSpan({
    required this.start,
    required this.end,
    required this.stage,
  });

  final DateTime start;
  final DateTime end;
  final SleepStage stage;

  Duration get duration => end.difference(start);

  @override
  bool operator ==(Object other) =>
      other is StageSpan &&
      other.start == start &&
      other.end == end &&
      other.stage == stage;

  @override
  int get hashCode => Object.hash(start, end, stage);
}

/// One night from Samsung Health; [stages] of all its sessions, in order.
class SleepRecord {
  const SleepRecord({
    required this.start,
    required this.end,
    required this.score,
    required this.stages,
  });

  final DateTime start;
  final DateTime end;
  final int? score;
  final List<StageSpan> stages;

  Duration get asleep => stages
      .where((span) => span.stage != SleepStage.awake)
      .fold(Duration.zero, (sum, span) => sum + span.duration);

  Duration timeIn(SleepStage stage) => stages
      .where((span) => span.stage == stage)
      .fold(Duration.zero, (sum, span) => sum + span.duration);

  /// The stage at [time]; null outside every stage interval.
  SleepStage? stageAt(DateTime time) {
    for (final span in stages) {
      if (!time.isBefore(span.start) && time.isBefore(span.end)) {
        return span.stage;
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is SleepRecord &&
      other.start == start &&
      other.end == end &&
      other.score == score &&
      _listEquals(other.stages, stages);

  @override
  int get hashCode => Object.hash(start, end, score, Object.hashAll(stages));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
