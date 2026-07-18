import 'package:flutter/material.dart';
import 'package:lucid/core/formatting/time_format.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';
import 'package:lucid/l10n/l10n.dart';

/// Edits a draft of the alarm; [onSave] receives it switched on. The caller
/// closes the sheet.
class EditAlarmSheet extends StatefulWidget {
  const EditAlarmSheet({
    super.key,
    required this.initial,
    required this.onSave,
  });

  final AlarmSettings initial;
  final Future<void> Function(AlarmSettings settings) onSave;

  @override
  State<EditAlarmSheet> createState() => _EditAlarmSheetState();
}

class _EditAlarmSheetState extends State<EditAlarmSheet> {
  late AlarmSettings _draft = widget.initial;
  bool _saving = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _draft.wakeByMinute ~/ 60,
        minute: _draft.wakeByMinute % 60,
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _draft = _draft.copyWith(wakeByMinute: picked.hour * 60 + picked.minute);
    });
  }

  void _toggleDay(int day) {
    final days = {..._draft.days};
    if (!days.remove(day)) days.add(day);
    setState(() => _draft = _draft.copyWith(days: days));
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(_draft.copyWith(enabled: true));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final muted = context.appColors.textMuted;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editTitle, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.editLatestTime, style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton(
              onPressed: _pickTime,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  context.minuteOfDay(_draft.wakeByMinute),
                  style: textTheme.headlineMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.editWindow, style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.editWindowHint,
              style: textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final minutes in AlarmSettings.windowChoices)
                  ChoiceChip(
                    label: Text(l10n.editWindowMinutes(minutes)),
                    selected: _draft.windowMinutes == minutes,
                    onSelected: (_) => setState(
                      () => _draft = _draft.copyWith(windowMinutes: minutes),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.alarmWakeBetween(
                context.minuteOfDay(_draft.windowStartMinute),
                context.minuteOfDay(_draft.wakeByMinute),
              ),
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.editRepeat, style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (var day = 1; day <= 7; day++)
                  FilterChip(
                    label: Text(context.weekdayShort(day)),
                    selected: _draft.days.contains(day),
                    onSelected: (_) => _toggleDay(day),
                  ),
              ],
            ),
            if (_draft.days.isEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.editRepeatHint,
                style: textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(l10n.editSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
