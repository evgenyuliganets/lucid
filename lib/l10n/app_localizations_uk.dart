// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Lucid';

  @override
  String get retry => 'Спробувати ще';

  @override
  String get loadFailed => 'Lucid не зміг прочитати свій стан.';

  @override
  String get setupTooltip => 'Налаштування';

  @override
  String get sleepTooltip => 'Сон';

  @override
  String alarmWakeBetween(String start, String end) {
    return 'Підйом між $start і $end';
  }

  @override
  String get alarmOff => 'Будильник вимкнено';

  @override
  String get alarmNextToday => 'Сьогодні';

  @override
  String get alarmNextTomorrow => 'Завтра';

  @override
  String get alarmOnce => 'Один раз';

  @override
  String get alarmEveryDay => 'Щодня';

  @override
  String get alarmEdit => 'Змінити';

  @override
  String get alarmEnabledLabel => 'Будильник';

  @override
  String get alarmHowItWorks =>
      'Годинник слухає ваш сон у вікні й м\'яко вібрує в неспокійний, легкий момент. Якщо такого моменту не буде, він розбудить вас у найпізніший час — разом із телефоном.';

  @override
  String get alarmPhoneOnly =>
      'Без годинника телефон задзвонить у найпізніший час.';

  @override
  String get editTitle => 'Будильник';

  @override
  String get editLatestTime => 'Найпізніший час підйому';

  @override
  String get editWindow => 'Розумне вікно';

  @override
  String get editWindowHint =>
      'Настільки раніше Lucid може розбудити вас у легкому сні.';

  @override
  String editWindowMinutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String editWindowHours(String hours) {
    return '$hours год';
  }

  @override
  String get editRepeat => 'Повтор';

  @override
  String get editRepeatHint => 'Без днів — задзвонить один раз.';

  @override
  String get editSave => 'Зберегти';

  @override
  String get setupBannerTitle => 'Завершіть налаштування';

  @override
  String setupBannerLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Залишилося $count кроку',
      many: 'Залишилося $count кроків',
      few: 'Залишилося $count кроки',
      one: 'Залишився $count крок',
    );
    return '$_temp0';
  }

  @override
  String get setupTitle => 'Налаштування';

  @override
  String get setupIntro =>
      'Lucid потрібно кілька дозволів на телефоні та невеликий застосунок на Galaxy Watch. Пройдіть кроки один раз.';

  @override
  String get setupPhoneSection => 'На цьому телефоні';

  @override
  String get setupWatchSection => 'На годиннику';

  @override
  String get setupOptionalSection => 'Рекомендовано';

  @override
  String get setupDone => 'Готово';

  @override
  String get setupAllDone => 'Усе готово. Lucid чекає на ніч.';

  @override
  String get stepNotificationsTitle => 'Сповіщення будильника';

  @override
  String get stepNotificationsBody =>
      'Будильник показується як сповіщення. Без цього телефон не задзвонить.';

  @override
  String get stepExactTitle => 'Будильники й нагадування';

  @override
  String get stepExactBody =>
      'Lucid дзвонитиме точно вчасно, навіть коли телефон у спокої.';

  @override
  String get stepFullScreenTitle => 'Будильник поверх блокування';

  @override
  String get stepFullScreenBody =>
      'Екран будильника відкриється, навіть коли телефон заблоковано.';

  @override
  String get stepBatteryTitle => 'Робота вночі';

  @override
  String get stepBatteryBody =>
      'Android не призупинятиме Lucid уночі, і він чутиме годинник.';

  @override
  String get stepOpenSettings => 'Відкрити налаштування';

  @override
  String get stepAllow => 'Дозволити';

  @override
  String get stepWatchPairTitle => 'Підключіть Galaxy Watch';

  @override
  String get stepWatchPairBody =>
      'Lucid знаходить легкий сон за допомогою Galaxy Watch (Watch4 або новіший). Підключіть годинник до цього телефона в Galaxy Wearable і тримайте Bluetooth увімкненим.';

  @override
  String get stepWatchPairAction => 'Відкрити Galaxy Wearable';

  @override
  String get stepWatchInstallTitle => 'Встановіть Lucid на годинник';

  @override
  String get stepWatchInstallBody =>
      'На годинник Lucid теж ставиться з Google Play. Натисніть кнопку: на годиннику відкриється Play Store, там торкніться «Встановити».';

  @override
  String get stepWatchInstallShow => 'Відкрити на годиннику';

  @override
  String get stepWatchInstallComputer => 'Встановити з комп’ютера';

  @override
  String get watchInstallFailed =>
      'Годинник не відповів. На годиннику відкрийте Play Store → Застосунки на телефоні → Lucid → Встановити.';

  @override
  String get stepWatchFinishTitle => 'Завершіть на годиннику';

  @override
  String get stepWatchFinishBody =>
      'Відкрийте Lucid на годиннику й натисніть «Дозволити сповіщення» та «Дозволити екран будильника». Пульс — за бажанням.';

  @override
  String get stepWatchFinishWaiting =>
      'Чекаю на годинник… Відкрийте Lucid на годиннику один раз.';

  @override
  String get stepSamsungTitle => 'Фази сну з Samsung Health';

  @override
  String get stepSamsungBody =>
      'Зранку Lucid покаже ваші фази сну з Samsung Health і перевірить, чи розбудив вас у легкому сні.';

  @override
  String get stepSamsungConnect => 'Підключити';

  @override
  String get stepSamsungShow => 'Показати як';

  @override
  String get installTitle => 'Встановлення Lucid на годинник';

  @override
  String get installIntro =>
      'Потрібні комп\'ютер з Android platform tools (adb), файл застосунку для годинника lucid-watch.apk (він іде разом із застосунком для телефона) і годинник у тій самій Wi-Fi мережі, що й комп\'ютер. adb можна завантажити з developer.android.com/tools/releases/platform-tools.';

  @override
  String get installStep1Title => 'Увімкніть режим розробника на годиннику';

  @override
  String get installStep1Body =>
      'На годиннику відкрийте Налаштування → Про годинник → Відомості про ПЗ і 5 разів торкніться «Версія ПЗ», доки не з\'явиться «Режим розробника ввімкнено».';

  @override
  String get installStep2Title => 'Увімкніть бездротове налагодження';

  @override
  String get installStep2Body =>
      'Відкрийте Налаштування → Параметри розробника. Увімкніть «Налагодження ADB» і «Бездротове налагодження», потім торкніться «Бездротове налагодження» → «Створити пару з пристроєм». Годинник покаже IP-адресу, порт і код.';

  @override
  String get installStep3Title => 'Створіть пару й підключіться з комп\'ютера';

  @override
  String get installStep3Body =>
      'Введіть адресу й код створення пари, які показує годинник, потім підключіться до адреси під «Бездротове налагодження» (її порт інший, ніж для пари). Замініть числа з прикладу на ті, що на вашому годиннику:';

  @override
  String get installStep4Title => 'Встановіть застосунок';

  @override
  String get installStep4Body =>
      'Якщо телефон підключено до комп\'ютера кабелем, спершу від\'єднайте його. Потім у папці з lucid-watch.apk виконайте:';

  @override
  String get installStep5Title => 'Відкрийте Lucid на годиннику';

  @override
  String get installStep5Body =>
      'Знайдіть Lucid у списку застосунків годинника, відкрийте й дозвольте сповіщення та екран будильника. Режим розробника потім можна вимкнути.';

  @override
  String get installCopied => 'Скопійовано';

  @override
  String get installCopyTooltip => 'Скопіювати команду';

  @override
  String get samsungGuideTitle => 'Підключення Samsung Health';

  @override
  String get samsungGuideIntro =>
      'Samsung дає застосункам читати фази сну лише після одноразового перемикача в Samsung Health. Lucid лише читає й нічого не змінює.';

  @override
  String get samsungGuideStep1 =>
      'Відкрийте Samsung Health → меню ☰ (або профіль) → Налаштування → Про Samsung Health.';

  @override
  String get samsungGuideStep2 =>
      'Торкніться рядка з версією 10 разів. З\'явиться нове меню «Developer mode».';

  @override
  String get samsungGuideStep3 =>
      'Відкрийте «Developer mode» і увімкніть «Developer Mode for Data Read».';

  @override
  String get samsungGuideStep4 =>
      'Поверніться в Lucid, натисніть «Підключити» й дозвольте Сон.';

  @override
  String get samsungStatusReady => 'Підключено';

  @override
  String get samsungStatusPermission =>
      'Натисніть «Підключити» й дозвольте Сон.';

  @override
  String get samsungStatusDeveloperMode =>
      'Спершу увімкніть у Samsung Health режим розробника для читання даних.';

  @override
  String get samsungStatusNotInstalled => 'Samsung Health не встановлено.';

  @override
  String get samsungStatusUpdate =>
      'Оновіть Samsung Health у Galaxy Store або Play Маркеті.';

  @override
  String get samsungStatusDisabled =>
      'Samsung Health вимкнено на цьому телефоні.';

  @override
  String get samsungStatusNotInitialized =>
      'Відкрийте Samsung Health один раз і завершіть його налаштування.';

  @override
  String get samsungStatusUnavailable => 'Samsung Health зараз недоступний.';

  @override
  String get watchNotPaired => 'Годинник не підключено';

  @override
  String get watchNoApp => 'Lucid не встановлено на годиннику';

  @override
  String watchNotConnected(String name) {
    return '$name зараз не на зв\'язку';
  }

  @override
  String get watchUnknownName => 'Ваш годинник';

  @override
  String get watchNeedsSetup =>
      'Відкрийте Lucid на годиннику, щоб завершити налаштування';

  @override
  String watchTracking(String name) {
    return '$name слухає ваш сон';
  }

  @override
  String watchArmed(String name, String time) {
    return '$name розбудить до $time';
  }

  @override
  String watchConnected(String name) {
    return '$name на зв\'язку';
  }

  @override
  String get watchHeartRateOn => 'Пульс увімкнено';

  @override
  String get watchTestPhone => 'Перевірити будильник телефона';

  @override
  String get sleepTitle => 'Сон';

  @override
  String get sleepEmpty =>
      'Ночей ще немає. Після першої ночі з годинником вона з\'явиться тут.';

  @override
  String get sleepLastNight => 'Минула ніч';

  @override
  String get sleepSeeAll => 'Усі ночі';

  @override
  String sleepScore(int score) {
    return 'Оцінка $score';
  }

  @override
  String sleepDuration(int hours, int minutes) {
    return '$hours год $minutes хв';
  }

  @override
  String get stageAwake => 'Неспання';

  @override
  String get stageRem => 'REM';

  @override
  String get stageLight => 'Легкий';

  @override
  String get stageDeep => 'Глибокий';

  @override
  String wokeAtLight(String time) {
    return 'Lucid розбудив вас о $time — у легкому сні';
  }

  @override
  String wokeAtDeadline(String time) {
    return 'Легкого моменту не було; Lucid розбудив вас о $time';
  }

  @override
  String get checkLight => 'Samsung підтверджує: у цей момент був легкий сон.';

  @override
  String get checkRem => 'Samsung підтверджує: у цей момент був REM-сон.';

  @override
  String get checkDeep => 'Samsung бачив у цей момент глибокий сон.';

  @override
  String get checkAwake => 'За фазами Samsung ви вже не спали.';

  @override
  String get checkPending =>
      'Фази Samsung зазвичай з\'являються за годину чи більше після пробудження.';

  @override
  String get samsungNotConnected =>
      'Підключіть Samsung Health у Налаштуваннях, щоб бачити фази сну.';

  @override
  String get samsungReadFailed => 'Не вдалося прочитати Samsung Health.';

  @override
  String get saveFailed =>
      'Lucid не зміг зберегти будильник. Спробуйте ще раз.';

  @override
  String get wearAppMissing =>
      'Galaxy Wearable не встановлено. Завантажте його з Galaxy Store або Play Маркету.';

  @override
  String wokeAtPhone(String time) {
    return 'Годинник не задзвонив; телефон задзвонив о $time';
  }

  @override
  String stageMinutes(String stage, int minutes) {
    return '$stage $minutes хв';
  }

  @override
  String hypnogramLabel(String start, String end) {
    return 'Фази сну з $start до $end';
  }
}
