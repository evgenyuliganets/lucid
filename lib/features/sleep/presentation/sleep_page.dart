import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';
import 'package:lucid/features/sleep/domain/sleep_overview.dart';
import 'package:lucid/features/sleep/presentation/night_card.dart';
import 'package:lucid/features/sleep/presentation/sleep_controller.dart';
import 'package:lucid/l10n/l10n.dart';

/// The last two weeks of nights, newest first.
class SleepPage extends ConsumerWidget {
  const SleepPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleep = ref.watch(sleepControllerProvider);
    final controller = ref.read(sleepControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.sleepTitle)),
      body: switch (sleep) {
        AsyncValue(:final value?) => RefreshIndicator(
          onRefresh: controller.refresh,
          child: _NightList(overview: value),
        ),
        AsyncValue(hasError: true) => Center(
          child: FilledButton(
            onPressed: controller.refresh,
            child: Text(context.l10n.retry),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _NightList extends StatelessWidget {
  const _NightList({required this.overview});

  final SleepOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.appColors.textMuted;
    final notice = overview.samsungReadFailed
        ? l10n.samsungReadFailed
        : overview.samsung == SamsungStatus.ready
        ? null
        : l10n.samsungNotConnected;
    final now = DateTime.now();
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: overview.nights.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            overview.nights.isEmpty ? l10n.sleepEmpty : notice ?? '',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: muted),
          );
        }
        return NightCard(
          night: overview.nights[index - 1],
          now: now,
          samsungReady: overview.samsung == SamsungStatus.ready,
        );
      },
    );
  }
}
