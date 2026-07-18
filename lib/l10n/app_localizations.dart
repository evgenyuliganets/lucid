import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lucid'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Lucid could not read its state.'**
  String get loadFailed;

  /// No description provided for @setupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setupTooltip;

  /// No description provided for @sleepTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepTooltip;

  /// No description provided for @alarmWakeBetween.
  ///
  /// In en, this message translates to:
  /// **'Wake between {start} and {end}'**
  String alarmWakeBetween(String start, String end);

  /// No description provided for @alarmLatest.
  ///
  /// In en, this message translates to:
  /// **'at the latest'**
  String get alarmLatest;

  /// No description provided for @alarmOff.
  ///
  /// In en, this message translates to:
  /// **'Alarm is off'**
  String get alarmOff;

  /// No description provided for @alarmNextToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get alarmNextToday;

  /// No description provided for @alarmNextTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get alarmNextTomorrow;

  /// No description provided for @alarmOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get alarmOnce;

  /// No description provided for @alarmEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get alarmEveryDay;

  /// No description provided for @alarmEdit.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get alarmEdit;

  /// No description provided for @alarmEnabledLabel.
  ///
  /// In en, this message translates to:
  /// **'Alarm on'**
  String get alarmEnabledLabel;

  /// No description provided for @alarmHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'Your watch listens to your sleep during the window and gently vibrates at a restless, light moment. If no such moment comes, it wakes you at the latest time — and so does your phone.'**
  String get alarmHowItWorks;

  /// No description provided for @alarmPhoneOnly.
  ///
  /// In en, this message translates to:
  /// **'Without the watch, your phone rings at the latest time.'**
  String get alarmPhoneOnly;

  /// No description provided for @editTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get editTitle;

  /// No description provided for @editLatestTime.
  ///
  /// In en, this message translates to:
  /// **'Latest wake-up time'**
  String get editLatestTime;

  /// No description provided for @editWindow.
  ///
  /// In en, this message translates to:
  /// **'Smart window'**
  String get editWindow;

  /// No description provided for @editWindowHint.
  ///
  /// In en, this message translates to:
  /// **'Lucid may wake you this much earlier, at a light-sleep moment.'**
  String get editWindowHint;

  /// No description provided for @editWindowMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String editWindowMinutes(int minutes);

  /// No description provided for @editRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get editRepeat;

  /// No description provided for @editRepeatHint.
  ///
  /// In en, this message translates to:
  /// **'No days selected: rings once.'**
  String get editRepeatHint;

  /// No description provided for @editSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editSave;

  /// No description provided for @setupBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish setup'**
  String get setupBannerTitle;

  /// No description provided for @setupBannerLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step left} other{{count} steps left}}'**
  String setupBannerLeft(int count);

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setupTitle;

  /// No description provided for @setupIntro.
  ///
  /// In en, this message translates to:
  /// **'Lucid needs a few permissions on your phone and its small app on your Galaxy Watch. Go through the steps once.'**
  String get setupIntro;

  /// No description provided for @setupPhoneSection.
  ///
  /// In en, this message translates to:
  /// **'On this phone'**
  String get setupPhoneSection;

  /// No description provided for @setupWatchSection.
  ///
  /// In en, this message translates to:
  /// **'On your watch'**
  String get setupWatchSection;

  /// No description provided for @setupOptionalSection.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get setupOptionalSection;

  /// No description provided for @setupDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get setupDone;

  /// No description provided for @setupAllDone.
  ///
  /// In en, this message translates to:
  /// **'All set. Lucid is ready for tonight.'**
  String get setupAllDone;

  /// No description provided for @stepNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarm notifications'**
  String get stepNotificationsTitle;

  /// No description provided for @stepNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'The alarm appears as a notification. Without it the phone cannot ring.'**
  String get stepNotificationsBody;

  /// No description provided for @stepNotificationsAction.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get stepNotificationsAction;

  /// No description provided for @stepExactTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms & reminders'**
  String get stepExactTitle;

  /// No description provided for @stepExactBody.
  ///
  /// In en, this message translates to:
  /// **'Lets Lucid ring exactly on time, even when the phone is idle.'**
  String get stepExactBody;

  /// No description provided for @stepFullScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarm over the lock screen'**
  String get stepFullScreenTitle;

  /// No description provided for @stepFullScreenBody.
  ///
  /// In en, this message translates to:
  /// **'Lets the alarm screen open when the phone is locked.'**
  String get stepFullScreenBody;

  /// No description provided for @stepBatteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Run at night'**
  String get stepBatteryTitle;

  /// No description provided for @stepBatteryBody.
  ///
  /// In en, this message translates to:
  /// **'Stops Android from pausing Lucid at night, so it hears your watch.'**
  String get stepBatteryBody;

  /// No description provided for @stepOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get stepOpenSettings;

  /// No description provided for @stepAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get stepAllow;

  /// No description provided for @stepWatchPairTitle.
  ///
  /// In en, this message translates to:
  /// **'Pair a Galaxy Watch'**
  String get stepWatchPairTitle;

  /// No description provided for @stepWatchPairBody.
  ///
  /// In en, this message translates to:
  /// **'Lucid finds your light sleep with a Galaxy Watch (Watch4 or newer). Pair it with this phone in the Galaxy Wearable app and keep Bluetooth on.'**
  String get stepWatchPairBody;

  /// No description provided for @stepWatchPairAction.
  ///
  /// In en, this message translates to:
  /// **'Open Galaxy Wearable'**
  String get stepWatchPairAction;

  /// No description provided for @stepWatchInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Install Lucid on the watch'**
  String get stepWatchInstallTitle;

  /// No description provided for @stepWatchInstallBody.
  ///
  /// In en, this message translates to:
  /// **'Lucid is not in the watch\'s app store yet, so it is installed from a computer once. This takes about five minutes.'**
  String get stepWatchInstallBody;

  /// No description provided for @stepWatchInstallShow.
  ///
  /// In en, this message translates to:
  /// **'Show how'**
  String get stepWatchInstallShow;

  /// No description provided for @stepWatchFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish on the watch'**
  String get stepWatchFinishTitle;

  /// No description provided for @stepWatchFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Open Lucid on your watch and tap “Allow notifications” and “Allow alarm screen”. Heart rate is optional.'**
  String get stepWatchFinishBody;

  /// No description provided for @stepWatchFinishWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the watch… Open Lucid on the watch once.'**
  String get stepWatchFinishWaiting;

  /// No description provided for @stepSamsungTitle.
  ///
  /// In en, this message translates to:
  /// **'Samsung Health sleep stages'**
  String get stepSamsungTitle;

  /// No description provided for @stepSamsungBody.
  ///
  /// In en, this message translates to:
  /// **'In the morning Lucid shows your sleep stages from Samsung Health and checks whether it woke you in light sleep.'**
  String get stepSamsungBody;

  /// No description provided for @stepSamsungConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get stepSamsungConnect;

  /// No description provided for @stepSamsungShow.
  ///
  /// In en, this message translates to:
  /// **'Show how'**
  String get stepSamsungShow;

  /// No description provided for @installTitle.
  ///
  /// In en, this message translates to:
  /// **'Install Lucid on your watch'**
  String get installTitle;

  /// No description provided for @installIntro.
  ///
  /// In en, this message translates to:
  /// **'You need a computer with Android platform tools (adb), the file lucid-watch.apk, and the watch on the same Wi-Fi as the computer.'**
  String get installIntro;

  /// No description provided for @installStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Turn on developer mode on the watch'**
  String get installStep1Title;

  /// No description provided for @installStep1Body.
  ///
  /// In en, this message translates to:
  /// **'On the watch open Settings → About watch → Software information and tap “Software version” 5 times, until you see “Developer mode turned on”.'**
  String get installStep1Body;

  /// No description provided for @installStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Turn on wireless debugging'**
  String get installStep2Title;

  /// No description provided for @installStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Open Settings → Developer options. Turn on “ADB debugging” and “Wireless debugging”, then tap “Wireless debugging” → “Pair new device”. The watch shows an IP address, a port and a pairing code.'**
  String get installStep2Body;

  /// No description provided for @installStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Pair and connect from the computer'**
  String get installStep3Title;

  /// No description provided for @installStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Type the pairing address and code from the watch, then connect to the address shown under “Wireless debugging” (its port differs from the pairing port):'**
  String get installStep3Body;

  /// No description provided for @installStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Install the watch app'**
  String get installStep4Title;

  /// No description provided for @installStep4Body.
  ///
  /// In en, this message translates to:
  /// **'In the folder with lucid-watch.apk run:'**
  String get installStep4Body;

  /// No description provided for @installStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Open Lucid on the watch'**
  String get installStep5Title;

  /// No description provided for @installStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Find Lucid in the watch\'s app list, open it and allow notifications and the alarm screen. You can turn developer mode off afterwards.'**
  String get installStep5Body;

  /// No description provided for @installCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get installCopied;

  /// No description provided for @installCopyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy command'**
  String get installCopyTooltip;

  /// No description provided for @samsungGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Samsung Health'**
  String get samsungGuideTitle;

  /// No description provided for @samsungGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Samsung lets apps read sleep stages only after a one-time switch in Samsung Health. Lucid only reads; it never changes your data.'**
  String get samsungGuideIntro;

  /// No description provided for @samsungGuideStep1.
  ///
  /// In en, this message translates to:
  /// **'Open Samsung Health → ☰ menu (or your profile) → Settings → About Samsung Health.'**
  String get samsungGuideStep1;

  /// No description provided for @samsungGuideStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap the version line 10 times. A new menu “Developer mode” appears.'**
  String get samsungGuideStep2;

  /// No description provided for @samsungGuideStep3.
  ///
  /// In en, this message translates to:
  /// **'Open “Developer mode” and turn on “Developer Mode for Data Read”.'**
  String get samsungGuideStep3;

  /// No description provided for @samsungGuideStep4.
  ///
  /// In en, this message translates to:
  /// **'Come back to Lucid and tap “Connect”, then allow Sleep.'**
  String get samsungGuideStep4;

  /// No description provided for @samsungStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get samsungStatusReady;

  /// No description provided for @samsungStatusPermission.
  ///
  /// In en, this message translates to:
  /// **'Tap Connect and allow Sleep.'**
  String get samsungStatusPermission;

  /// No description provided for @samsungStatusDeveloperMode.
  ///
  /// In en, this message translates to:
  /// **'Turn on Samsung Health\'s developer mode for data read first.'**
  String get samsungStatusDeveloperMode;

  /// No description provided for @samsungStatusNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Samsung Health is not installed.'**
  String get samsungStatusNotInstalled;

  /// No description provided for @samsungStatusUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update Samsung Health in the Galaxy Store or Play Store.'**
  String get samsungStatusUpdate;

  /// No description provided for @samsungStatusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Samsung Health is turned off on this phone.'**
  String get samsungStatusDisabled;

  /// No description provided for @samsungStatusNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Open Samsung Health once and finish its setup.'**
  String get samsungStatusNotInitialized;

  /// No description provided for @samsungStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Samsung Health is not reachable right now.'**
  String get samsungStatusUnavailable;

  /// No description provided for @watchCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchCardTitle;

  /// No description provided for @watchNotPaired.
  ///
  /// In en, this message translates to:
  /// **'No watch connected'**
  String get watchNotPaired;

  /// No description provided for @watchNoApp.
  ///
  /// In en, this message translates to:
  /// **'Lucid is not installed on the watch'**
  String get watchNoApp;

  /// No description provided for @watchNotConnected.
  ///
  /// In en, this message translates to:
  /// **'{name} is not connected right now'**
  String watchNotConnected(String name);

  /// No description provided for @watchUnknownName.
  ///
  /// In en, this message translates to:
  /// **'Your watch'**
  String get watchUnknownName;

  /// No description provided for @watchNeedsSetup.
  ///
  /// In en, this message translates to:
  /// **'Open Lucid on the watch to finish setup'**
  String get watchNeedsSetup;

  /// No description provided for @watchTracking.
  ///
  /// In en, this message translates to:
  /// **'{name} is listening to your sleep'**
  String watchTracking(String name);

  /// No description provided for @watchArmed.
  ///
  /// In en, this message translates to:
  /// **'{name} is ready for {time}'**
  String watchArmed(String name, String time);

  /// No description provided for @watchConnected.
  ///
  /// In en, this message translates to:
  /// **'{name} is connected'**
  String watchConnected(String name);

  /// No description provided for @watchHeartRateOn.
  ///
  /// In en, this message translates to:
  /// **'Heart rate on'**
  String get watchHeartRateOn;

  /// No description provided for @watchTestPhone.
  ///
  /// In en, this message translates to:
  /// **'Test phone alarm'**
  String get watchTestPhone;

  /// No description provided for @sleepTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepTitle;

  /// No description provided for @sleepEmpty.
  ///
  /// In en, this message translates to:
  /// **'No nights yet. After your first night with the watch, it appears here.'**
  String get sleepEmpty;

  /// No description provided for @sleepLastNight.
  ///
  /// In en, this message translates to:
  /// **'Last night'**
  String get sleepLastNight;

  /// No description provided for @sleepSeeAll.
  ///
  /// In en, this message translates to:
  /// **'All nights'**
  String get sleepSeeAll;

  /// No description provided for @sleepScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String sleepScore(int score);

  /// No description provided for @sleepDuration.
  ///
  /// In en, this message translates to:
  /// **'{hours} h {minutes} min'**
  String sleepDuration(int hours, int minutes);

  /// No description provided for @stageAwake.
  ///
  /// In en, this message translates to:
  /// **'Awake'**
  String get stageAwake;

  /// No description provided for @stageRem.
  ///
  /// In en, this message translates to:
  /// **'REM'**
  String get stageRem;

  /// No description provided for @stageLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get stageLight;

  /// No description provided for @stageDeep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get stageDeep;

  /// No description provided for @wokeAtLight.
  ///
  /// In en, this message translates to:
  /// **'Lucid woke you at {time} — in light sleep'**
  String wokeAtLight(String time);

  /// No description provided for @wokeAtDeadline.
  ///
  /// In en, this message translates to:
  /// **'No light moment came; Lucid woke you at {time}'**
  String wokeAtDeadline(String time);

  /// No description provided for @wokeAtSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed at {time}'**
  String wokeAtSnoozed(String time);

  /// No description provided for @checkLight.
  ///
  /// In en, this message translates to:
  /// **'Samsung agrees: light sleep at that moment.'**
  String get checkLight;

  /// No description provided for @checkRem.
  ///
  /// In en, this message translates to:
  /// **'Samsung agrees: REM sleep at that moment.'**
  String get checkRem;

  /// No description provided for @checkDeep.
  ///
  /// In en, this message translates to:
  /// **'Samsung saw deep sleep at that moment.'**
  String get checkDeep;

  /// No description provided for @checkAwake.
  ///
  /// In en, this message translates to:
  /// **'You were already awake by Samsung\'s stages.'**
  String get checkAwake;

  /// No description provided for @checkPending.
  ///
  /// In en, this message translates to:
  /// **'Samsung\'s stages usually appear an hour or more after you wake.'**
  String get checkPending;

  /// No description provided for @samsungNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Connect Samsung Health in Setup to see your sleep stages.'**
  String get samsungNotConnected;

  /// No description provided for @samsungReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Samsung Health could not be read.'**
  String get samsungReadFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
