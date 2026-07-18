/// Whether Lucid can read Samsung Health's sleep, and what blocks it.
enum SamsungStatus {
  ready,
  permissionNeeded,
  developerModeNeeded,
  notInstalled,
  updateNeeded,
  disabled,
  notInitialized,
  unavailable;

  static SamsungStatus parse(String? value) => SamsungStatus.values.firstWhere(
    (status) => status.name == value,
    orElse: () => SamsungStatus.unavailable,
  );
}
