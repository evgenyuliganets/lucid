/// Samsung Health's sleep stages.
enum SleepStage {
  awake,
  rem,
  light,
  deep,
  undefined;

  static SleepStage parse(String value) => SleepStage.values.firstWhere(
    (stage) => stage.name == value,
    orElse: () => SleepStage.undefined,
  );
}
