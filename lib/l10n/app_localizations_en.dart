// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lucid';

  @override
  String get retry => 'Try again';

  @override
  String get loadFailed => 'Lucid could not read its state.';

  @override
  String get setupTooltip => 'Setup';

  @override
  String get sleepTooltip => 'Sleep';

  @override
  String alarmWakeBetween(String start, String end) {
    return 'Wake between $start and $end';
  }

  @override
  String get alarmOff => 'Alarm is off';

  @override
  String get alarmNextToday => 'Today';

  @override
  String get alarmNextTomorrow => 'Tomorrow';

  @override
  String get alarmOnce => 'Once';

  @override
  String get alarmEveryDay => 'Every day';

  @override
  String get alarmEdit => 'Change';

  @override
  String get alarmEnabledLabel => 'Alarm';

  @override
  String get alarmHowItWorks =>
      'Your watch listens to your sleep during the window and gently vibrates at a restless, light moment. If no such moment comes, it wakes you at the latest time — and so does your phone.';

  @override
  String get alarmPhoneOnly =>
      'Without the watch, your phone rings at the latest time.';

  @override
  String get editTitle => 'Alarm';

  @override
  String get editLatestTime => 'Latest wake-up time';

  @override
  String get editWindow => 'Smart window';

  @override
  String get editWindowHint =>
      'Lucid may wake you this much earlier, at a light-sleep moment.';

  @override
  String editWindowMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get editRepeat => 'Repeat';

  @override
  String get editRepeatHint => 'No days selected: rings once.';

  @override
  String get editSave => 'Save';

  @override
  String get setupBannerTitle => 'Finish setup';

  @override
  String setupBannerLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps left',
      one: '1 step left',
    );
    return '$_temp0';
  }

  @override
  String get setupTitle => 'Setup';

  @override
  String get setupIntro =>
      'Lucid needs a few permissions on your phone and its small app on your Galaxy Watch. Go through the steps once.';

  @override
  String get setupPhoneSection => 'On this phone';

  @override
  String get setupWatchSection => 'On your watch';

  @override
  String get setupOptionalSection => 'Recommended';

  @override
  String get setupDone => 'Done';

  @override
  String get setupAllDone => 'All set. Lucid is ready for tonight.';

  @override
  String get stepNotificationsTitle => 'Alarm notifications';

  @override
  String get stepNotificationsBody =>
      'The alarm appears as a notification. Without it the phone cannot ring.';

  @override
  String get stepExactTitle => 'Alarms & reminders';

  @override
  String get stepExactBody =>
      'Lets Lucid ring exactly on time, even when the phone is idle.';

  @override
  String get stepFullScreenTitle => 'Alarm over the lock screen';

  @override
  String get stepFullScreenBody =>
      'Lets the alarm screen open when the phone is locked.';

  @override
  String get stepBatteryTitle => 'Run at night';

  @override
  String get stepBatteryBody =>
      'Stops Android from pausing Lucid at night, so it hears your watch.';

  @override
  String get stepOpenSettings => 'Open settings';

  @override
  String get stepAllow => 'Allow';

  @override
  String get stepWatchPairTitle => 'Pair a Galaxy Watch';

  @override
  String get stepWatchPairBody =>
      'Lucid finds your light sleep with a Galaxy Watch (Watch4 or newer). Pair it with this phone in the Galaxy Wearable app and keep Bluetooth on.';

  @override
  String get stepWatchPairAction => 'Open Galaxy Wearable';

  @override
  String get stepWatchInstallTitle => 'Install Lucid on the watch';

  @override
  String get stepWatchInstallBody =>
      'Lucid is not in the watch\'s app store yet, so it is installed from a computer once. This takes about five minutes.';

  @override
  String get stepWatchInstallShow => 'Show how';

  @override
  String get stepWatchFinishTitle => 'Finish on the watch';

  @override
  String get stepWatchFinishBody =>
      'Open Lucid on your watch and tap “Allow notifications” and “Allow alarm screen”. Heart rate is optional.';

  @override
  String get stepWatchFinishWaiting =>
      'Waiting for the watch… Open Lucid on the watch once.';

  @override
  String get stepSamsungTitle => 'Samsung Health sleep stages';

  @override
  String get stepSamsungBody =>
      'In the morning Lucid shows your sleep stages from Samsung Health and checks whether it woke you in light sleep.';

  @override
  String get stepSamsungConnect => 'Connect';

  @override
  String get stepSamsungShow => 'Show how';

  @override
  String get installTitle => 'Install Lucid on your watch';

  @override
  String get installIntro =>
      'You need a computer with Android platform tools (adb), the watch app file lucid-watch.apk (it comes together with the phone app), and the watch on the same Wi-Fi as the computer. Get adb from developer.android.com/tools/releases/platform-tools.';

  @override
  String get installStep1Title => 'Turn on developer mode on the watch';

  @override
  String get installStep1Body =>
      'On the watch open Settings → About watch → Software information and tap “Software version” 5 times, until you see “Developer mode turned on”.';

  @override
  String get installStep2Title => 'Turn on wireless debugging';

  @override
  String get installStep2Body =>
      'Open Settings → Developer options. Turn on “ADB debugging” and “Wireless debugging”, then tap “Wireless debugging” → “Pair new device”. The watch shows an IP address, a port and a pairing code.';

  @override
  String get installStep3Title => 'Pair and connect from the computer';

  @override
  String get installStep3Body =>
      'Type the pairing address and code that the watch shows, then connect to the address shown under “Wireless debugging” (its port differs from the pairing port). Replace the example numbers with the ones on your watch:';

  @override
  String get installStep4Title => 'Install the watch app';

  @override
  String get installStep4Body =>
      'If your phone is connected to the computer by USB, unplug it first. Then, in the folder with lucid-watch.apk, run:';

  @override
  String get installStep5Title => 'Open Lucid on the watch';

  @override
  String get installStep5Body =>
      'Find Lucid in the watch\'s app list, open it and allow notifications and the alarm screen. You can turn developer mode off afterwards.';

  @override
  String get installCopied => 'Copied';

  @override
  String get installCopyTooltip => 'Copy command';

  @override
  String get samsungGuideTitle => 'Connect Samsung Health';

  @override
  String get samsungGuideIntro =>
      'Samsung lets apps read sleep stages only after a one-time switch in Samsung Health. Lucid only reads; it never changes your data.';

  @override
  String get samsungGuideStep1 =>
      'Open Samsung Health → ☰ menu (or your profile) → Settings → About Samsung Health.';

  @override
  String get samsungGuideStep2 =>
      'Tap the version line 10 times. A new menu “Developer mode” appears.';

  @override
  String get samsungGuideStep3 =>
      'Open “Developer mode” and turn on “Developer Mode for Data Read”.';

  @override
  String get samsungGuideStep4 =>
      'Come back to Lucid and tap “Connect”, then allow Sleep.';

  @override
  String get samsungStatusReady => 'Connected';

  @override
  String get samsungStatusPermission => 'Tap Connect and allow Sleep.';

  @override
  String get samsungStatusDeveloperMode =>
      'Turn on Samsung Health\'s developer mode for data read first.';

  @override
  String get samsungStatusNotInstalled => 'Samsung Health is not installed.';

  @override
  String get samsungStatusUpdate =>
      'Update Samsung Health in the Galaxy Store or Play Store.';

  @override
  String get samsungStatusDisabled =>
      'Samsung Health is turned off on this phone.';

  @override
  String get samsungStatusNotInitialized =>
      'Open Samsung Health once and finish its setup.';

  @override
  String get samsungStatusUnavailable =>
      'Samsung Health is not reachable right now.';

  @override
  String get watchNotPaired => 'No watch connected';

  @override
  String get watchNoApp => 'Lucid is not installed on the watch';

  @override
  String watchNotConnected(String name) {
    return '$name is not connected right now';
  }

  @override
  String get watchUnknownName => 'Your watch';

  @override
  String get watchNeedsSetup => 'Open Lucid on the watch to finish setup';

  @override
  String watchTracking(String name) {
    return '$name is listening to your sleep';
  }

  @override
  String watchArmed(String name, String time) {
    return '$name is ready for $time';
  }

  @override
  String watchConnected(String name) {
    return '$name is connected';
  }

  @override
  String get watchHeartRateOn => 'Heart rate on';

  @override
  String get watchTestPhone => 'Test phone alarm';

  @override
  String get sleepTitle => 'Sleep';

  @override
  String get sleepEmpty =>
      'No nights yet. After your first night with the watch, it appears here.';

  @override
  String get sleepLastNight => 'Last night';

  @override
  String get sleepSeeAll => 'All nights';

  @override
  String sleepScore(int score) {
    return 'Score $score';
  }

  @override
  String sleepDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get stageAwake => 'Awake';

  @override
  String get stageRem => 'REM';

  @override
  String get stageLight => 'Light';

  @override
  String get stageDeep => 'Deep';

  @override
  String wokeAtLight(String time) {
    return 'Lucid woke you at $time — in light sleep';
  }

  @override
  String wokeAtDeadline(String time) {
    return 'No light moment came; Lucid woke you at $time';
  }

  @override
  String get checkLight => 'Samsung agrees: light sleep at that moment.';

  @override
  String get checkRem => 'Samsung agrees: REM sleep at that moment.';

  @override
  String get checkDeep => 'Samsung saw deep sleep at that moment.';

  @override
  String get checkAwake => 'You were already awake by Samsung\'s stages.';

  @override
  String get checkPending =>
      'Samsung\'s stages usually appear an hour or more after you wake.';

  @override
  String get samsungNotConnected =>
      'Connect Samsung Health in Setup to see your sleep stages.';

  @override
  String get samsungReadFailed => 'Samsung Health could not be read.';

  @override
  String get saveFailed => 'Lucid could not save the alarm. Try again.';

  @override
  String get wearAppMissing =>
      'Galaxy Wearable is not installed. Get it from Galaxy Store or Play Store.';

  @override
  String wokeAtPhone(String time) {
    return 'The watch did not ring; the phone rang at $time';
  }

  @override
  String stageMinutes(String stage, int minutes) {
    return '$stage $minutes min';
  }

  @override
  String hypnogramLabel(String start, String end) {
    return 'Sleep stages from $start to $end';
  }
}
