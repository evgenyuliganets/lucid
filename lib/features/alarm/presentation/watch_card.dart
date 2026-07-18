import 'package:flutter/material.dart';
import 'package:lucid/core/formatting/time_format.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/alarm/domain/watch_state.dart';
import 'package:lucid/l10n/l10n.dart';

/// What the watch is doing: missing, needs setup, ready for the next window
/// or listening now. [onSetup] opens setup when something is missing.
class WatchCard extends StatelessWidget {
  const WatchCard({
    super.key,
    required this.watch,
    required this.onSetup,
    required this.onTestPhone,
  });

  final WatchState watch;
  final VoidCallback onSetup;
  final VoidCallback onTestPhone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final name = watch.name ?? l10n.watchUnknownName;
    final status = watch.status;
    final armedEnd = status?.armedWindowEnd;
    final (icon, text, ok) = switch (watch) {
      WatchState(connected: false, installed: false) => (
        Icons.watch_off_outlined,
        l10n.watchNotPaired,
        false,
      ),
      WatchState(installed: false) => (
        Icons.watch_outlined,
        l10n.watchNoApp,
        false,
      ),
      WatchState(ready: false) => (
        Icons.watch_outlined,
        l10n.watchNeedsSetup,
        false,
      ),
      WatchState(connected: false) => (
        Icons.bluetooth_disabled,
        l10n.watchNotConnected(name),
        false,
      ),
      _ when status?.tracking ?? false => (
        Icons.bedtime,
        l10n.watchTracking(name),
        true,
      ),
      _ when armedEnd != null => (
        Icons.watch,
        l10n.watchArmed(name, context.clock(armedEnd)),
        true,
      ),
      _ => (Icons.watch, l10n.watchConnected(name), true),
    };
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: ok ? context.appColors.success : colors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(text, style: textTheme.titleMedium)),
              ],
            ),
            if (status?.heartRate ?? false) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.watchHeartRateOn,
                style: textTheme.bodySmall?.copyWith(
                  color: context.appColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              ok ? l10n.alarmHowItWorks : l10n.alarmPhoneOnly,
              style: textTheme.bodyMedium?.copyWith(
                color: context.appColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                if (!ok)
                  FilledButton.tonal(
                    onPressed: onSetup,
                    child: Text(l10n.setupTitle),
                  ),
                OutlinedButton(
                  onPressed: onTestPhone,
                  child: Text(l10n.watchTestPhone),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
