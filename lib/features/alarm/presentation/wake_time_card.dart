import 'package:flutter/material.dart';
import 'package:lucid/core/formatting/time_format.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';
import 'package:lucid/features/alarm/domain/wake_window.dart';
import 'package:lucid/l10n/l10n.dart';

/// The alarm at a glance: latest wake time, the smart window, the days and
/// the next ring, with the on/off switch. Tapping it opens the editor.
class WakeTimeCard extends StatelessWidget {
  const WakeTimeCard({
    super.key,
    required this.settings,
    required this.nextWindow,
    required this.onEdit,
    required this.onEnabledChanged,
  });

  final AlarmSettings settings;
  final WakeWindow? nextWindow;
  final VoidCallback onEdit;
  final ValueChanged<bool> onEnabledChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final muted = context.appColors.textMuted;
    final enabled = settings.enabled;
    return Card(
      color: context.appColors.surfaceAccent,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.minuteOfDay(settings.wakeByMinute),
                      style: textTheme.displayMedium?.copyWith(
                        color: enabled ? null : muted,
                      ),
                    ),
                  ),
                  Semantics(
                    label: l10n.alarmEnabledLabel,
                    child: Switch(value: enabled, onChanged: onEnabledChanged),
                  ),
                ],
              ),
              Text(
                enabled
                    ? l10n.alarmWakeBetween(
                        context.minuteOfDay(settings.windowStartMinute),
                        context.minuteOfDay(settings.wakeByMinute),
                      )
                    : l10n.alarmOff,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _daysText(context),
                style: textTheme.bodyMedium?.copyWith(color: muted),
              ),
              if (enabled && nextWindow != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _nextText(context, nextWindow!.end),
                  style: textTheme.bodyMedium?.copyWith(color: muted),
                ),
              ],
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l10n.alarmEdit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _daysText(BuildContext context) {
    final l10n = context.l10n;
    if (settings.days.isEmpty) return l10n.alarmOnce;
    if (settings.days.length == 7) return l10n.alarmEveryDay;
    final days = settings.days.toList()..sort();
    return days.map(context.weekdayShort).join(', ');
  }

  String _nextText(BuildContext context, DateTime end) {
    final l10n = context.l10n;
    final now = DateTime.now();
    // Calendar days in UTC, so a daylight-saving night still counts as one day.
    final today = DateTime.utc(now.year, now.month, now.day);
    final day = DateTime.utc(end.year, end.month, end.day);
    final label = switch (day.difference(today).inDays) {
      0 => l10n.alarmNextToday,
      1 => l10n.alarmNextTomorrow,
      _ => context.dayMonth(end),
    };
    return '$label · ${context.clock(end)}';
  }
}
