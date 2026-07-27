import 'package:flutter/material.dart';
import 'package:lucid/core/formatting/time_format.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/sleep/domain/night.dart';
import 'package:lucid/features/sleep/domain/sleep_record.dart';
import 'package:lucid/features/sleep/domain/sleep_stage.dart';
import 'package:lucid/features/sleep/domain/watch_night.dart';
import 'package:lucid/features/sleep/presentation/hypnogram.dart';
import 'package:lucid/l10n/l10n.dart';

/// One night: date, length and score, the hypnogram, time per stage, when
/// Lucid woke the user and whether Samsung's stages agree.
class NightCard extends StatelessWidget {
  const NightCard({
    super.key,
    required this.night,
    required this.now,
    required this.samsungReady,
    this.title,
  });

  final Night night;
  final DateTime now;

  /// Whether Samsung Health is connected, so missing stages may still come.
  final bool samsungReady;

  /// Shown instead of the date, e.g. "Last night".
  final String? title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final muted = context.appColors.textMuted;
    final record = night.record;
    final watch = night.watch;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? context.dayMonth(night.wakeDay),
              style: textTheme.titleMedium,
            ),
            if (record != null) ...[
              Text(
                [
                  _duration(l10n, record.asleep),
                  if (record.score != null) l10n.sleepScore(record.score!),
                ].join(' · '),
                style: textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: AppSpacing.md),
              Hypnogram(
                record: record,
                windowStart: watch?.windowStart,
                windowEnd: watch?.windowEnd,
                wokeAt: watch?.wokeAt,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StageLegend(record: record),
            ],
            if (watch != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_wakeText(context, watch), style: textTheme.bodyLarge),
            ],
            if (_checkText(l10n, night.check(now, samsungReady: samsungReady))
                case final check?) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(check, style: textTheme.bodyMedium?.copyWith(color: muted)),
            ],
          ],
        ),
      ),
    );
  }

  static String _duration(AppLocalizations l10n, Duration duration) =>
      l10n.sleepDuration(duration.inHours, duration.inMinutes % 60);

  String _wakeText(BuildContext context, WatchNight watch) {
    final l10n = context.l10n;
    final wokeAt = watch.wokeAt;
    if (wokeAt == null) return l10n.wokeAtPhone(context.clock(watch.windowEnd));
    return switch (watch.reason) {
      WakeReason.lightSleep => l10n.wokeAtLight(context.clock(wokeAt)),
      WakeReason.deadline || null => l10n.wokeAtDeadline(context.clock(wokeAt)),
    };
  }

  static String? _checkText(AppLocalizations l10n, WakeCheck check) =>
      switch (check) {
        WakeCheck.light => l10n.checkLight,
        WakeCheck.rem => l10n.checkRem,
        WakeCheck.deep => l10n.checkDeep,
        WakeCheck.awake => l10n.checkAwake,
        WakeCheck.pending => l10n.checkPending,
        WakeCheck.none => null,
      };
}

class _StageLegend extends StatelessWidget {
  const _StageLegend({required this.record});

  final SleepRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final items = [
      (SleepStage.awake, l10n.stageAwake, colors.stageAwake),
      (SleepStage.rem, l10n.stageRem, colors.stageRem),
      (SleepStage.light, l10n.stageLight, colors.stageLight),
      (SleepStage.deep, l10n.stageDeep, colors.stageDeep),
    ];
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: [
        for (final (stage, label, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox.square(dimension: 10),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                l10n.stageMinutes(label, record.timeIn(stage).inMinutes),
                style: textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
