import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/l10n/l10n.dart';

/// The smallest supported phone at the largest text scale we check.
const smallPhone = Size(360, 640);

/// Pumps [page] with the app's theme and localisations on [size] at
/// [textScale], in [locale].
Future<void> pumpPage(
  WidgetTester tester,
  Widget page, {
  Locale locale = const Locale('en'),
  Size size = smallPhone,
  double textScale = 1.3,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildAppTheme(Brightness.light),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: page,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Scrolls the first scrollable to the end, so every lazy item is built.
Future<void> scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -5000));
  await tester.pumpAndSettle();
}
