import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/features/alarm/presentation/alarm_controller.dart';
import 'package:lucid/features/setup/domain/setup_step.dart';
import 'package:lucid/features/setup/presentation/setup_page.dart';
import 'package:lucid/features/sleep/presentation/sleep_controller.dart';
import 'package:lucid/l10n/l10n.dart';

/// "Finish setup: N steps left", shown on the home screen until every
/// required step is done; opens [SetupPage].
class SetupBanner extends ConsumerWidget {
  const SetupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarm = ref.watch(alarmControllerProvider).value;
    final samsung = ref.watch(
      sleepControllerProvider.select((sleep) => sleep.value?.samsung),
    );
    if (alarm == null) return const SizedBox.shrink();
    final left = SetupStep.requiredLeft(alarm, samsung);
    if (left == 0) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      color: colors.tertiaryContainer,
      child: ListTile(
        leading: Icon(Icons.checklist, color: colors.onTertiaryContainer),
        title: Text(
          context.l10n.setupBannerTitle,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onTertiaryContainer,
          ),
        ),
        subtitle: Text(
          context.l10n.setupBannerLeft(left),
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onTertiaryContainer,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.onTertiaryContainer),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SetupPage())),
      ),
    );
  }
}
