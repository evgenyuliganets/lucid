import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/features/sleep/data/sleep_channel.dart';
import 'package:lucid/features/sleep/data/sleep_repository.dart';

final sleepChannelProvider = Provider<SleepChannel>((ref) => SleepChannel());

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return SleepRepository(ref.watch(sleepChannelProvider));
});
