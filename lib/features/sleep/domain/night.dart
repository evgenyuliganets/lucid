import 'package:lucid/features/sleep/domain/sleep_record.dart';
import 'package:lucid/features/sleep/domain/sleep_stage.dart';
import 'package:lucid/features/sleep/domain/watch_night.dart';

/// How Lucid's wake moment compares with Samsung's stages for that night.
enum WakeCheck { light, rem, deep, awake, pending, none }

/// One night: Samsung's record, the watch's report, or both.
class Night {
  const Night({required this.record, required this.watch});

  final SleepRecord? record;
  final WatchNight? watch;

  DateTime get wakeDay => watch?.windowEnd ?? record!.end;

  /// [now] and [samsungReady] decide whether missing Samsung data may still
  /// arrive.
  WakeCheck check(DateTime now, {required bool samsungReady}) {
    final wokeAt = watch?.wokeAt;
    if (wokeAt == null) return WakeCheck.none;
    final record = this.record;
    if (record == null) {
      return samsungReady && now.difference(wokeAt) < const Duration(hours: 12)
          ? WakeCheck.pending
          : WakeCheck.none;
    }
    // Samsung often ends the record when the user gets up, a little after the
    // alarm; the moment just before waking is what counts.
    final stage = record.stageAt(wokeAt.subtract(const Duration(minutes: 1)));
    return switch (stage) {
      SleepStage.light => WakeCheck.light,
      SleepStage.rem => WakeCheck.rem,
      SleepStage.deep => WakeCheck.deep,
      SleepStage.awake => WakeCheck.awake,
      SleepStage.undefined || null => WakeCheck.none,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is Night && other.record == record && other.watch == watch;

  @override
  int get hashCode => Object.hash(record, watch);
}

/// Pairs each watch night with the Samsung record around its window end;
/// unpaired ones stay alone. Newest first.
List<Night> mergeNights(List<SleepRecord> records, List<WatchNight> watches) {
  final unpaired = records.toList();
  final nights = <Night>[];
  for (final watch in watches) {
    final anchor = watch.wokeAt ?? watch.windowEnd;
    final match = unpaired.where((record) {
      final from = record.start.subtract(const Duration(hours: 1));
      final to = record.end.add(const Duration(hours: 2));
      return anchor.isAfter(from) && anchor.isBefore(to);
    }).firstOrNull;
    if (match != null) unpaired.remove(match);
    nights.add(Night(record: match, watch: watch));
  }
  nights.addAll(unpaired.map((record) => Night(record: record, watch: null)));
  nights.sort((a, b) => b.wakeDay.compareTo(a.wakeDay));
  return nights;
}
