import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid/app/lucid_app.dart';
import 'package:lucid/features/alarm/data/alarm_channel.dart';
import 'package:lucid/features/alarm/domain/alarm_settings.dart';

import '../../fake_channels.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpApp(WidgetTester tester, {Locale? locale}) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.platformDispatcher.localesTestValue = [?locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(const ProviderScope(child: LucidApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('a ready setup shows the alarm and the armed watch', (
    tester,
  ) async {
    fakeChannels(alarmStateReply());
    await pumpApp(tester);

    expect(find.text('Finish setup'), findsNothing);
    expect(find.textContaining('Wake between'), findsOneWidget);
    expect(find.textContaining('is ready for'), findsOneWidget);
  });

  testWidgets('missing permissions show the setup banner with the count', (
    tester,
  ) async {
    fakeChannels(alarmStateReply(phoneReady: false, watchReady: false));
    await pumpApp(tester);

    expect(find.text('Finish setup'), findsOneWidget);
    expect(find.text('4 steps left'), findsOneWidget);

    await tester.tap(find.text('Finish setup'));
    await tester.pumpAndSettle();
    expect(find.text('Alarm notifications'), findsOneWidget);
  });

  testWidgets('the home screen fits a small phone in Ukrainian', (
    tester,
  ) async {
    fakeChannels(alarmStateReply(phoneReady: false, watchReady: false));
    await pumpApp(tester, locale: const Locale('uk'));

    expect(find.text('Завершіть налаштування'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the editor offers windows up to two hours', (tester) async {
    fakeChannels(alarmStateReply());
    await pumpApp(tester);
    await tester.tap(find.text('Change'));
    await tester.pumpAndSettle();

    expect(find.text('1.5 h'), findsOneWidget);
    expect(find.text('2 h'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
  });

  testWidgets('setup links the privacy policy', (tester) async {
    final calls = fakeChannels(alarmStateReply());
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Setup'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Privacy policy'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.ensureVisible(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy policy'));

    expect(calls.map((call) => call.method), contains('openPrivacyPolicy'));
  });

  test('saving sends exactly the four settings keys', () async {
    final calls = fakeChannels(alarmStateReply());
    await AlarmChannel().saveSettings(
      const AlarmSettings(
        enabled: true,
        wakeByMinute: 450,
        windowMinutes: 20,
        days: {5, 1},
      ),
    );
    expect(calls.single.method, 'saveSettings');
    expect(calls.single.arguments, {
      'enabled': true,
      'wakeByMinute': 450,
      'windowMinutes': 20,
      'days': [1, 5],
    });
  });
}
