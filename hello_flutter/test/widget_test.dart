import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BarAiApp());
    expect(find.text('BarAI'), findsOneWidget);
  });
}
