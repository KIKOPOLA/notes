import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo widget renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppLogo(size: 80, borderRadius: 20),
        ),
      ),
    );

    expect(find.byType(AppLogo), findsOneWidget);
  });
}

