import 'package:flutter/material.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/l10n/l10n.dart';

/// One setup step: a done mark or the step number, a title, why it is
/// needed and, while open, the action that fixes it.
///
/// [onAction] null hides the button; [note] is an extra line shown while the
/// step is open (for example what the app is waiting for).
class SetupStepCard extends StatelessWidget {
  const SetupStepCard({
    super.key,
    required this.number,
    required this.title,
    required this.body,
    required this.done,
    this.actionLabel,
    this.onAction,
    this.note,
  });

  final int number;
  final String title;
  final String body;
  final bool done;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final note = this.note;
    final actionLabel = this.actionLabel;
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepMark(number: number, done: done),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textMuted,
                    ),
                  ),
                  if (!done && note != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      note,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.primary,
                      ),
                    ),
                  ],
                  if (!done && actionLabel != null && onAction != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    FilledButton.tonal(
                      onPressed: onAction,
                      child: Text(actionLabel),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepMark extends StatelessWidget {
  const _StepMark({required this.number, required this.done});

  final int number;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: done ? context.l10n.setupDone : null,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: done
            ? context.appColors.success
            : colors.secondaryContainer,
        foregroundColor: done ? colors.surface : colors.onSecondaryContainer,
        child: done
            ? const Icon(Icons.check, size: 20)
            : Text('$number', style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
