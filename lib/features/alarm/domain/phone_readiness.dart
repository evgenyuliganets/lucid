/// Which of the phone's alarm permissions are in place.
class PhoneReadiness {
  const PhoneReadiness({
    required this.notifications,
    required this.exactAlarms,
    required this.fullScreen,
    required this.batteryUnrestricted,
  });

  final bool notifications;
  final bool exactAlarms;
  final bool fullScreen;
  final bool batteryUnrestricted;

  @override
  bool operator ==(Object other) =>
      other is PhoneReadiness &&
      other.notifications == notifications &&
      other.exactAlarms == exactAlarms &&
      other.fullScreen == fullScreen &&
      other.batteryUnrestricted == batteryUnrestricted;

  @override
  int get hashCode =>
      Object.hash(notifications, exactAlarms, fullScreen, batteryUnrestricted);
}
