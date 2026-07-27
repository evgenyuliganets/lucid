import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid/features/home/presentation/home_page.dart';
import 'package:lucid/features/setup/presentation/setup_page.dart';
import 'package:lucid/features/setup/presentation/watch_install_page.dart';
import 'package:lucid/features/sleep/presentation/sleep_page.dart';

import '../fake_channels.dart';
import '../pump_app.dart';

/// Every screen at 360x640 and text scale 1.3, in both languages, without
/// layout overflows.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pages = <String, Widget>{
    'home': HomePage(),
    'setup': SetupPage(),
    'install': WatchInstallPage(),
    'sleep': SleepPage(),
  };

  for (final locale in const [Locale('en'), Locale('uk')]) {
    for (final MapEntry(key: name, value: page) in pages.entries) {
      testWidgets('$name fits a small phone in ${locale.languageCode}', (
        tester,
      ) async {
        fakeChannels(
          alarmStateReply(phoneReady: false, watchReady: false),
          withNights: true,
        );
        await pumpPage(tester, page, locale: locale);
        await scrollToEnd(tester);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('sleep shows the night and the light-sleep check', (
    tester,
  ) async {
    fakeChannels(alarmStateReply(), withNights: true);
    await pumpPage(tester, const SleepPage(), textScale: 1);

    expect(find.textContaining('Lucid woke you at'), findsOneWidget);
    expect(
      find.text('Samsung agrees: light sleep at that moment.'),
      findsOneWidget,
    );
    expect(find.text('Score 81'), findsNothing);
    expect(find.textContaining('Score 81'), findsOneWidget);
  });

  testWidgets('setup sends developer mode only to the guide', (tester) async {
    fakeChannels(alarmStateReply());
    await pumpPage(tester, const SetupPage(), textScale: 1);
    await scrollToEnd(tester);

    expect(find.text('Show how'), findsOneWidget);
    await tester.ensureVisible(find.text('Show how'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show how'));
    await tester.pumpAndSettle();
    expect(find.text('Connect Samsung Health'), findsOneWidget);
  });
}
