import 'package:lucid/app/lucid_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads the demo catalog', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LucidApp()));
    await tester.pumpAndSettle();

    expect(find.text('Starter product'), findsOneWidget);
    expect(find.text('Pro product'), findsOneWidget);
  });
}
