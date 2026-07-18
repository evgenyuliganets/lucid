import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/features/alarm/data/alarm_channel.dart';
import 'package:lucid/features/alarm/data/alarm_repository.dart';

final alarmChannelProvider = Provider<AlarmChannel>((ref) => AlarmChannel());

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  return AlarmRepository(ref.watch(alarmChannelProvider));
});
