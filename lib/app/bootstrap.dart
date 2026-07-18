import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucid/app/lucid_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No automatic retries: native channel failures reach the UI once.
  runApp(ProviderScope(retry: (_, _) => null, child: const LucidApp()));
}
