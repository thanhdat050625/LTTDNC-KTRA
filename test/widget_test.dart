import 'package:flutter_test/flutter_test.dart';
import 'package:lttdnc_ktra/main.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Firebase Initialized Successfully!'), findsOneWidget);
  });
}
