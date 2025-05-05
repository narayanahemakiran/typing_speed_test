import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:typing_speed_test/main.dart'; // Ensure the correct import path

void main() {
  testWidgets('Typing Test App loads correctly', (WidgetTester tester) async {
    // Use TypingTestApp instead of MyApp
    await tester.pumpWidget(const TypingTestApp());

    // Verify UI elements
    expect(find.text('Level: Easy'), findsOneWidget);
    expect(find.text('Watch Guide for Easy'), findsOneWidget);
  });
}