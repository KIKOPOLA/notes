import 'package:flutter_test/flutter_test.dart';

import 'package:notes/main.dart';

void main() {
  testWidgets('Notes app landing page test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that landing page is shown
    expect(find.text('NOTES'), findsWidgets);
    expect(find.text('Minimal. Powerful. Yours.'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
  });
}
