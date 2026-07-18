import 'package:lucid/features/sleep/domain/night.dart';
import 'package:lucid/features/sleep/domain/samsung_status.dart';

/// Past nights and whether Samsung Health could be read.
class SleepOverview {
  const SleepOverview({
    required this.samsung,
    required this.nights,
    required this.samsungReadFailed,
  });

  final SamsungStatus samsung;
  final List<Night> nights;
  final bool samsungReadFailed;

  @override
  bool operator ==(Object other) =>
      other is SleepOverview &&
      other.samsung == samsung &&
      other.samsungReadFailed == samsungReadFailed &&
      other.nights.length == nights.length &&
      Iterable.generate(
        nights.length,
      ).every((i) => other.nights[i] == nights[i]);

  @override
  int get hashCode =>
      Object.hash(samsung, samsungReadFailed, Object.hashAll(nights));
}
