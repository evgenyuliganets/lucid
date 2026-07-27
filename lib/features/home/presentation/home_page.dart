import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/presentation/alarm_controller.dart';
import 'package:lucid/features/alarm/presentation/edit_alarm_sheet.dart';
import 'package:lucid/features/alarm/presentation/wake_time_card.dart';
import 'package:lucid/features/alarm/presentation/watch_card.dart';
import 'package:lucid/features/setup/presentation/setup_banner.dart';
import 'package:lucid/features/setup/presentation/setup_page.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';
import 'package:lucid/features/sleep/presentation/night_card.dart';
import 'package:lucid/features/sleep/presentation/sleep_controller.dart';
import 'package:lucid/features/sleep/presentation/sleep_page.dart';
import 'package:lucid/l10n/l10n.dart';

/// The first screen: setup reminder, the alarm, the watch and last night.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alarm = ref.watch(alarmControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.sleepTooltip,
            icon: const Icon(Icons.bedtime_outlined),
            onPressed: () => _push(context, const SleepPage()),
          ),
          IconButton(
            tooltip: l10n.setupTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _push(context, const SetupPage()),
          ),
        ],
      ),
      body: switch (alarm) {
        AsyncValue(:final value?) => _HomeBody(alarm: value),
        AsyncValue(hasError: true) => _LoadError(
          onRetry: ref.read(alarmControllerProvider.notifier).refresh,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  static void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.alarm});

  final AlarmOverview alarm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(alarmControllerProvider.notifier);
    return RefreshIndicator(
      onRefresh: () => Future.wait([
        controller.refresh(),
        ref.read(sleepControllerProvider.notifier).refresh(),
      ]),
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const SetupBanner(),
          const SizedBox(height: AppSpacing.sm),
          WakeTimeCard(
            settings: alarm.settings,
            nextWindow: alarm.nextWindow,
            onEnabledChanged: (enabled) async {
              final messenger = ScaffoldMessenger.of(context);
              final text = context.l10n.saveFailed;
              if (await controller.setEnabled(enabled) != null) {
                messenger.showSnackBar(SnackBar(content: Text(text)));
              }
            },
            onEdit: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (sheetContext) => EditAlarmSheet(
                initial: alarm.settings,
                onSave: (settings) async {
                  final failure = await controller.save(settings);
                  if (failure == null && sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                  return failure == null;
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          WatchCard(
            watch: alarm.watch,
            onSetup: () => HomePage._push(context, const SetupPage()),
            onTestPhone: controller.testAlarm,
          ),
          const SizedBox(height: AppSpacing.md),
          const _LastNight(),
        ],
      ),
    );
  }
}

class _LastNight extends ConsumerWidget {
  const _LastNight();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final night = ref.watch(
      sleepControllerProvider.select(
        (sleep) => sleep.value?.nights.firstOrNull,
      ),
    );
    final samsungReady = ref.watch(
      sleepControllerProvider.select(
        (sleep) => sleep.value?.samsung == SamsungStatus.ready,
      ),
    );
    if (night == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NightCard(
          night: night,
          now: DateTime.now(),
          samsungReady: samsungReady,
          title: l10n.sleepLastNight,
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: () => HomePage._push(context, const SleepPage()),
            child: Text(l10n.sleepSeeAll),
          ),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.loadFailed, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
