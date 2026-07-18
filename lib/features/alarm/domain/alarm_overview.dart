import 'package:lucid/features/alarm/domain/alarm_settings.dart';
import 'package:lucid/features/alarm/domain/phone_readiness.dart';
import 'package:lucid/features/alarm/domain/wake_window.dart';
import 'package:lucid/features/alarm/domain/watch_state.dart';

/// Everything the alarm screens show, read in one call from the phone.
class AlarmOverview {
  const AlarmOverview({
    required this.settings,
    required this.nextWindow,
    required this.phone,
    required this.watch,
  });

  final AlarmSettings settings;

  /// Null when the alarm is off.
  final WakeWindow? nextWindow;
  final PhoneReadiness phone;
  final WatchState watch;

  @override
  bool operator ==(Object other) =>
      other is AlarmOverview &&
      other.settings == settings &&
      other.nextWindow == nextWindow &&
      other.phone == phone &&
      other.watch == watch;

  @override
  int get hashCode => Object.hash(settings, nextWindow, phone, watch);
}
