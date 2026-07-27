import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/core/result/result.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';
import 'package:lucid/features/sleep/domain/sleep_overview.dart';
import 'package:lucid/features/sleep/sleep_providers.dart';

final sleepControllerProvider =
    AsyncNotifierProvider<SleepController, SleepOverview>(SleepController.new);

/// Past nights; reloads when the app returns to the foreground, because
/// Samsung Health adds last night's stages some time after waking.
class SleepController extends AsyncNotifier<SleepOverview> {
  static const _resumeReloadAfter = Duration(minutes: 5);

  DateTime _loadedAt = DateTime.now();
  bool _connecting = false;

  @override
  Future<SleepOverview> build() async {
    final lifecycle = AppLifecycleListener(onResume: _onResume);
    ref.onDispose(lifecycle.dispose);
    return (await ref.read(sleepRepositoryProvider).load(DateTime.now()))
        .unwrap();
  }

  // Resume also fires when the notification shade closes; Samsung is not
  // read again that often unless the user may have just connected it.
  void _onResume() {
    final stale = DateTime.now().difference(_loadedAt) > _resumeReloadAfter;
    if (stale || state.value?.samsung != SamsungStatus.ready) refresh();
  }

  Future<void> refresh() async {
    _loadedAt = DateTime.now();
    final result = await ref.read(sleepRepositoryProvider).load(DateTime.now());
    if (!ref.mounted) return;
    state = switch (result) {
      Success(:final value) => AsyncData(value),
      FailureResult(:final failure) => AsyncError(failure, StackTrace.current),
    };
  }

  /// Opens Samsung Health's permission screen, then reloads.
  Future<void> connectSamsung() async {
    if (_connecting) return;
    _connecting = true;
    try {
      await ref.read(sleepRepositoryProvider).connectSamsung();
    } finally {
      _connecting = false;
    }
    if (ref.mounted) await refresh();
  }
}
