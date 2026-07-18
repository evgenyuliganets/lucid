import 'package:flutter/material.dart';
import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/home/presentation/home_page.dart';
import 'package:lucid/l10n/l10n.dart';

class LucidApp extends StatelessWidget {
  const LucidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
