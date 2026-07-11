import 'package:lucid/app/lucid_app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment, persistence, crash reporting, and analytics here.
  runApp(const ProviderScope(child: LucidApp()));
}
