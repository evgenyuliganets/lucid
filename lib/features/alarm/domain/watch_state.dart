/// The paired watch as the phone sees it.
///
/// [status] is the last report from Lucid's watch app; null until the watch
/// app has run once.
class WatchState {
  const WatchState({
    required this.connected,
    required this.installed,
    required this.name,
    required this.status,
  });

  final bool connected;
  final bool installed;
  final String? name;
  final WatchAppStatus? status;

  bool get ready =>
      installed && (status?.notifications ?? false) && status!.fullScreen;

  @override
  bool operator ==(Object other) =>
      other is WatchState &&
      other.connected == connected &&
      other.installed == installed &&
      other.name == name &&
      other.status == status;

  @override
  int get hashCode => Object.hash(connected, installed, name, status);
}

/// What Lucid's watch app last reported about itself.
class WatchAppStatus {
  const WatchAppStatus({
    required this.notifications,
    required this.fullScreen,
    required this.heartRate,
    required this.armedWindowEnd,
    required this.tracking,
    required this.appVersion,
  });

  final bool notifications;
  final bool fullScreen;
  final bool heartRate;
  final DateTime? armedWindowEnd;
  final bool tracking;
  final String appVersion;

  @override
  bool operator ==(Object other) =>
      other is WatchAppStatus &&
      other.notifications == notifications &&
      other.fullScreen == fullScreen &&
      other.heartRate == heartRate &&
      other.armedWindowEnd == armedWindowEnd &&
      other.tracking == tracking &&
      other.appVersion == appVersion;

  @override
  int get hashCode => Object.hash(
    notifications,
    fullScreen,
    heartRate,
    armedWindowEnd,
    tracking,
    appVersion,
  );
}
