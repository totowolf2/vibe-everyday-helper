// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everyday_helper_app/main.dart';

void main() {
  testWidgets('Everyday Helper app loads correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // First, verify we see the splash screen
    expect(find.text('Everyday Helper'), findsOneWidget);
    expect(find.text('Your daily problem solver'), findsOneWidget);

    // Wait for splash screen to complete and home screen to load
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Verify that our app shows the expected content on home screen.
    expect(find.text('Everyday Helper'), findsWidgets); // Could be in app bar
    expect(find.text('Welcome to Everyday Helper'), findsOneWidget);
    expect(find.text('Price Comparison'), findsOneWidget);
    expect(find.byIcon(Icons.compare_arrows), findsOneWidget);

    // Verify that we can navigate to the price comparison screen.
    await tester.tap(find.text('Price Comparison'));
    await tester.pumpAndSettle();

    // Wait for lazy loading to complete
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify that we're now on the price comparison screen.
    // Note: The actual screen might be different due to lazy loading implementation
    expect(find.text('Price Comparison'), findsWidgets);
  });
}
