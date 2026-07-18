import 'package:flutter/material.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/setup/presentation/command_box.dart';
import 'package:lucid/l10n/l10n.dart';

/// Step-by-step guide for installing Lucid on a Galaxy Watch from a computer:
/// developer mode, wireless debugging, adb pairing and install.
class WatchInstallPage extends StatelessWidget {
  const WatchInstallPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.installTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              l10n.installIntro,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            _GuideStep(
              number: 1,
              title: l10n.installStep1Title,
              body: l10n.installStep1Body,
            ),
            _GuideStep(
              number: 2,
              title: l10n.installStep2Title,
              body: l10n.installStep2Body,
            ),
            _GuideStep(
              number: 3,
              title: l10n.installStep3Title,
              body: l10n.installStep3Body,
              commands: const [
                'adb pair <watch-ip>:<pairing-port>',
                'adb connect <watch-ip>:<debug-port>',
              ],
            ),
            _GuideStep(
              number: 4,
              title: l10n.installStep4Title,
              body: l10n.installStep4Body,
              commands: const ['adb install -r lucid-watch.apk'],
            ),
            _GuideStep(
              number: 5,
              title: l10n.installStep5Title,
              body: l10n.installStep5Body,
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideStep extends StatelessWidget {
  const _GuideStep({
    required this.number,
    required this.title,
    required this.body,
    this.commands = const [],
  });

  final int number;
  final String title;
  final String body;
  final List<String> commands;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 14, child: Text('$number')),
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
                for (final command in commands) ...[
                  const SizedBox(height: AppSpacing.sm),
                  CommandBox(command: command),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
