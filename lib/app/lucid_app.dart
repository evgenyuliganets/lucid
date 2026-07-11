import 'package:lucid/design_system/app_theme.dart';
import 'package:lucid/features/catalog/presentation/catalog_page.dart';
import 'package:flutter/material.dart';

class LucidApp extends StatelessWidget {
  const LucidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucid',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      home: const CatalogPage(),
    );
  }
}
