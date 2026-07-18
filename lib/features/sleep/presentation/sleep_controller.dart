import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/sleep/domain/sleep_overview.dart';
import 'package:lucid/features/sleep/sleep_providers.dart';

final sleepControllerProvider =
    AsyncNotifierProvider<SleepController, SleepOverview>(SleepController.new);

/// Past nights; reloads when the app returns to the foreground, because
/// Samsung Health adds last night's stages some time after waking.
class SleepController extends AsyncNotifier<SleepOverview> {
  @override
  Future<SleepOverview> build() async {
    final lifecycle = AppLifecycleListener(onResume: refresh);
    ref.onDispose(lifecycle.dispose);
    return (await ref.read(sleepRepositoryProvider).load(DateTime.now()))
        .unwrap();
  }

  Future<void> refresh() async {
    final result = await ref.read(sleepRepositoryProvider).load(DateTime.now());
    if (!ref.mounted) return;
    state = switch (result) {
      Success(:final value) => AsyncData(value),
      FailureResult(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Opens Samsung Health's permission screen, then reloads.
  Future<void> connectSamsung() async {
    await ref.read(sleepRepositoryProvider).connectSamsung();
    if (ref.mounted) await refresh();
  }
}
