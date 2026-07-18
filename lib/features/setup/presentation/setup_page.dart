import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/design_system/app_spacing.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/alarm/domain/alarm_overview.dart';
import 'package:lucid/features/alarm/presentation/alarm_controller.dart';
import 'package:lucid/features/setup/domain/setup_step.dart';
import 'package:lucid/features/setup/presentation/samsung_guide_sheet.dart';
import 'package:lucid/features/setup/presentation/setup_step_card.dart';
import 'package:lucid/features/setup/presentation/watch_install_page.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';
import 'package:lucid/features/sleep/presentation/sleep_controller.dart';
import 'package:lucid/l10n/l10n.dart';

/// Every one-time step in order: phone permissions, the watch app, then the
/// recommended extras. Each open step says why and offers the fix.
class SetupPage extends ConsumerWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarm = ref.watch(alarmControllerProvider);
    final samsung = ref.watch(
      sleepControllerProvider.select((sleep) => sleep.value?.samsung),
    );
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.setupTitle)),
      body: switch (alarm) {
        AsyncValue(:final value?) => _SetupList(alarm: value, samsung: samsung),
        AsyncValue(hasError: true) => Center(
          child: FilledButton(
            onPressed: ref.read(alarmControllerProvider.notifier).refresh,
            child: Text(context.l10n.retry),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _SetupList extends ConsumerWidget {
  const _SetupList({required this.alarm, required this.samsung});

  final AlarmOverview alarm;
  final SamsungStatus? samsung;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(alarmControllerProvider.notifier);
    bool done(SetupStep step) => step.isDone(alarm, samsung);
    final allDone = SetupStep.requiredLeft(alarm, samsung) == 0;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (allDone)
            Card(
              color: context.appColors.surfaceAccent,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  l10n.setupAllDone,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            )
          else
            Text(l10n.setupIntro, style: Theme.of(context).textTheme.bodyLarge),
          _SectionTitle(l10n.setupPhoneSection),
          SetupStepCard(
            number: 1,
            title: l10n.stepNotificationsTitle,
            body: l10n.stepNotificationsBody,
            done: done(SetupStep.notifications),
            actionLabel: l10n.stepAllow,
            onAction: controller.requestNotifications,
          ),
          const SizedBox(height: AppSpacing.sm),
          SetupStepCard(
            number: 2,
            title: l10n.stepExactTitle,
            body: l10n.stepExactBody,
            done: done(SetupStep.exactAlarms),
            actionLabel: l10n.stepOpenSettings,
            onAction: controller.openExactAlarmSettings,
          ),
          const SizedBox(height: AppSpacing.sm),
          SetupStepCard(
            number: 3,
            title: l10n.stepFullScreenTitle,
            body: l10n.stepFullScreenBody,
            done: done(SetupStep.fullScreen),
            actionLabel: l10n.stepOpenSettings,
            onAction: controller.openFullScreenSettings,
          ),
          _SectionTitle(l10n.setupWatchSection),
          SetupStepCard(
            number: 4,
            title: l10n.stepWatchPairTitle,
            body: l10n.stepWatchPairBody,
            done: done(SetupStep.watchPaired),
            actionLabel: l10n.stepWatchPairAction,
            onAction: controller.openWearApp,
          ),
          const SizedBox(height: AppSpacing.sm),
          SetupStepCard(
            number: 5,
            title: l10n.stepWatchInstallTitle,
            body: l10n.stepWatchInstallBody,
            done: done(SetupStep.watchApp),
            actionLabel: l10n.stepWatchInstallShow,
            onAction: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const WatchInstallPage()),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SetupStepCard(
            number: 6,
            title: l10n.stepWatchFinishTitle,
            body: l10n.stepWatchFinishBody,
            done: done(SetupStep.watchFinish),
            note: alarm.watch.installed ? l10n.stepWatchFinishWaiting : null,
          ),
          _SectionTitle(l10n.setupOptionalSection),
          SetupStepCard(
            number: 7,
            title: l10n.stepBatteryTitle,
            body: l10n.stepBatteryBody,
            done: done(SetupStep.battery),
            actionLabel: l10n.stepAllow,
            onAction: controller.requestBatteryUnrestricted,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SamsungStep(status: samsung, done: done(SetupStep.samsung)),
        ],
      ),
    );
  }
}

class _SamsungStep extends ConsumerWidget {
  const _SamsungStep({required this.status, required this.done});

  final SamsungStatus? status;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final connect = ref.read(sleepControllerProvider.notifier).connectSamsung;
    final status = this.status;
    final permissionOnly = status == SamsungStatus.permissionNeeded;
    return SetupStepCard(
      number: 8,
      title: l10n.stepSamsungTitle,
      body: l10n.stepSamsungBody,
      done: done,
      note: status == null ? null : samsungStatusText(l10n, status),
      actionLabel: permissionOnly
          ? l10n.stepSamsungConnect
          : l10n.stepSamsungShow,
      onAction: permissionOnly
          ? connect
          : () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => SamsungGuideSheet(onConnect: connect),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// What the user should do about a Samsung Health [status].
String samsungStatusText(AppLocalizations l10n, SamsungStatus status) =>
    switch (status) {
      SamsungStatus.ready => l10n.samsungStatusReady,
      SamsungStatus.permissionNeeded => l10n.samsungStatusPermission,
      SamsungStatus.developerModeNeeded => l10n.samsungStatusDeveloperMode,
      SamsungStatus.notInstalled => l10n.samsungStatusNotInstalled,
      SamsungStatus.updateNeeded => l10n.samsungStatusUpdate,
      SamsungStatus.disabled => l10n.samsungStatusDisabled,
      SamsungStatus.notInitialized => l10n.samsungStatusNotInitialized,
      SamsungStatus.unavailable => l10n.samsungStatusUnavailable,
    };
