import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_store_management/app.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const GroceryStoreApp());
    // Chờ cho app render
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
