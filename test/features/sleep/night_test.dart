import 'package:flutter_test/flutter_test.dart';
import 'package:lucid/features/sleep/domain/night.dart';
import 'package:lucid/features/sleep/domain/sleep_record.dart';
import 'package:lucid/features/sleep/domain/sleep_stage.dart';
import 'package:lucid/features/sleep/domain/watch_night.dart';

void main() {
  DateTime at(int day, int hour, [int minute = 0]) =>
      DateTime(2026, 11, day, hour, minute);

  final record = SleepRecord(
    start: at(16, 23),
    end: at(17, 7, 5),
    score: 81,
    stages: [
      StageSpan(start: at(16, 23), end: at(17, 3), stage: SleepStage.deep),
      StageSpan(start: at(17, 3), end: at(17, 6, 40), stage: SleepStage.light),
      StageSpan(
        start: at(17, 6, 40),
        end: at(17, 6, 55),
        stage: SleepStage.rem,
      ),
      StageSpan(
        start: at(17, 6, 55),
        end: at(17, 7, 5),
        stage: SleepStage.awake,
      ),
    ],
  );

  WatchNight watch({DateTime? wokeAt, int day = 17}) => WatchNight(
    windowStart: at(day, 6, 30),
    windowEnd: at(day, 7),
    trackingStart: at(day, 6),
    wokeAt: wokeAt,
    reason: WakeReason.lightSleep,
    dismissedAt: wokeAt,
  );

  test('pairs a watch night with the Samsung record around its wake', () {
    final nights = mergeNights([record], [watch(wokeAt: at(17, 6, 35))]);
    expect(nights, hasLength(1));
    expect(nights.single.record, record);
    expect(nights.single.watch?.wokeAt, at(17, 6, 35));
  });

  test('keeps unpaired nights from both sources, newest first', () {
    final older = watch(wokeAt: at(10, 6, 45), day: 10);
    final nights = mergeNights([record], [older]);
    expect(nights.map((night) => night.wakeDay), [at(17, 7, 5), at(10, 7)]);
    expect(nights.last.record, isNull);
  });

  test('wake check reads the stage just before the wake moment', () {
    expect(
      Night(
        record: record,
        watch: watch(wokeAt: at(17, 6, 35)),
      ).check(at(17, 9), samsungReady: true),
      WakeCheck.light,
    );
    expect(
      Night(
        record: record,
        watch: watch(wokeAt: at(17, 6, 50)),
      ).check(at(17, 9), samsungReady: true),
      WakeCheck.rem,
    );
    expect(
      Night(
        record: record,
        watch: watch(wokeAt: at(17, 2)),
      ).check(at(17, 9), samsungReady: true),
      WakeCheck.deep,
    );
  });

  test('missing Samsung data is pending on the same morning only', () {
    final night = Night(record: null, watch: watch(wokeAt: at(17, 6, 35)));
    expect(night.check(at(17, 8), samsungReady: true), WakeCheck.pending);
    expect(night.check(at(18, 8), samsungReady: true), WakeCheck.none);
    expect(night.check(at(17, 8), samsungReady: false), WakeCheck.none);
  });

  test('stage totals and time asleep', () {
    expect(record.timeIn(SleepStage.deep), const Duration(hours: 4));
    expect(record.asleep, const Duration(hours: 7, minutes: 55));
  });
}
