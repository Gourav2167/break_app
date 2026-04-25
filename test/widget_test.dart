import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:have_a_break/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: HaveABreakApp(),
      ),
    );

    // Verify that the app title or some initial text is present
    expect(find.text('be present.'), findsOneWidget);
  });
}
