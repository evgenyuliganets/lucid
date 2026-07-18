import 'package:flutter/material.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/l10n/l10n.dart';

/// How to switch on Samsung Health's developer mode for data read, with the
/// Connect button at the end.
class SamsungGuideSheet extends StatelessWidget {
  const SamsungGuideSheet({super.key, required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final steps = [
      l10n.samsungGuideStep1,
      l10n.samsungGuideStep2,
      l10n.samsungGuideStep3,
      l10n.samsungGuideStep4,
    ];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.samsungGuideTitle, style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.samsungGuideIntro,
              style: textTheme.bodyMedium?.copyWith(
                color: context.appColors.textMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final (index, step) in steps.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, child: Text('${index + 1}')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(step, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConnect();
                },
                child: Text(l10n.stepSamsungConnect),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
