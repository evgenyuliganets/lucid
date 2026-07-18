import 'package:flutter/material.dart';
import 'package:lucid/core/formatting/time_format.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/sleep/domain/sleep_record.dart';
import 'package:lucid/features/sleep/domain/sleep_stage.dart';
import 'package:lucid/l10n/l10n.dart';

/// Samsung's stages of one night as a hypnogram (awake on top, deep at the
/// bottom), with Lucid's smart window shaded and its wake moment marked.
class Hypnogram extends StatelessWidget {
  const Hypnogram({
    super.key,
    required this.record,
    this.windowStart,
    this.windowEnd,
    this.wokeAt,
  });

  final SleepRecord record;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final DateTime? wokeAt;

  static const _height = 120.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final from = [record.start, ?windowStart].reduce(_earlier);
    final to = [record.end, ?wokeAt, ?windowEnd].reduce(_later);
    final l10n = context.l10n;
    return Semantics(
      label:
          '${l10n.stageAwake}, ${l10n.stageRem}, ${l10n.stageLight}, ${l10n.stageDeep}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: _height,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _HypnogramPainter(
                  stages: record.stages,
                  from: from,
                  to: to,
                  windowStart: windowStart,
                  windowEnd: windowEnd,
                  wokeAt: wokeAt,
                  stageColors: {
                    SleepStage.awake: colors.stageAwake,
                    SleepStage.rem: colors.stageRem,
                    SleepStage.light: colors.stageLight,
                    SleepStage.deep: colors.stageDeep,
                  },
                  windowColor: scheme.primary.withValues(alpha: 0.12),
                  markerColor: scheme.primary,
                  gridColor: scheme.outlineVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.clock(from), style: textTheme.labelSmall),
              Text(context.clock(to), style: textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  static DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;

  static DateTime _later(DateTime a, DateTime b) => a.isAfter(b) ? a : b;
}

class _HypnogramPainter extends CustomPainter {
  _HypnogramPainter({
    required this.stages,
    required this.from,
    required this.to,
    required this.windowStart,
    required this.windowEnd,
    required this.wokeAt,
    required this.stageColors,
    required this.windowColor,
    required this.markerColor,
    required this.gridColor,
  });

  final List<StageSpan> stages;
  final DateTime from;
  final DateTime to;
  final DateTime? windowStart;
  final DateTime? windowEnd;
  final DateTime? wokeAt;
  final Map<SleepStage, Color> stageColors;
  final Color windowColor;
  final Color markerColor;
  final Color gridColor;

  static const _rows = [
    SleepStage.awake,
    SleepStage.rem,
    SleepStage.light,
    SleepStage.deep,
  ];

  final _fill = Paint();
  final _line = Paint()..strokeWidth = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final total = to.difference(from).inMilliseconds;
    if (total <= 0) return;
    double x(DateTime time) =>
        size.width * time.difference(from).inMilliseconds / total;
    final rowHeight = size.height / _rows.length;

    _line.color = gridColor;
    for (var row = 1; row < _rows.length; row++) {
      canvas.drawLine(
        Offset(0, row * rowHeight),
        Offset(size.width, row * rowHeight),
        _line..strokeWidth = 0.5,
      );
    }

    final windowStart = this.windowStart;
    final windowEnd = this.windowEnd;
    if (windowStart != null && windowEnd != null) {
      _fill.color = windowColor;
      canvas.drawRect(
        Rect.fromLTRB(x(windowStart), 0, x(windowEnd), size.height),
        _fill,
      );
    }

    for (final span in stages) {
      final row = _rows.indexOf(span.stage);
      if (row < 0) continue;
      _fill.color = stageColors[span.stage]!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            x(span.start),
            row * rowHeight + 2,
            x(span.end).clamp(x(span.start) + 1, size.width),
            (row + 1) * rowHeight - 2,
          ),
          const Radius.circular(2),
        ),
        _fill,
      );
    }

    final wokeAt = this.wokeAt;
    if (wokeAt != null) {
      _line
        ..color = markerColor
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(x(wokeAt), 0),
        Offset(x(wokeAt), size.height),
        _line,
      );
    }
  }

  @override
  bool shouldRepaint(_HypnogramPainter old) =>
      old.stages != stages ||
      old.from != from ||
      old.to != to ||
      old.windowStart != windowStart ||
      old.windowEnd != windowEnd ||
      old.wokeAt != wokeAt ||
      old.markerColor != markerColor ||
      old.stageColors[SleepStage.deep] != stageColors[SleepStage.deep];
}
