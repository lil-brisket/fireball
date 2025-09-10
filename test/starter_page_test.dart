import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shinobi_rpg/screens/starter_page.dart';

void main() {
  group('StarterPage', () {
    testWidgets('should display title and menu options', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const StarterPage(),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify title is displayed
      expect(find.text('Shinobi Village'), findsOneWidget);
      
      // Verify menu options are displayed
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Battle'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('should display welcome message with player name', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const StarterPage(),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify welcome message is displayed
      expect(find.textContaining('Welcome back'), findsOneWidget);
    });

    testWidgets('should have proper button descriptions', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: const StarterPage(),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify button descriptions are displayed
      expect(find.text('View your character stats'), findsOneWidget);
      expect(find.text('Fight enemies and test your skills'), findsOneWidget);
      expect(find.text('Buy items and equipment'), findsOneWidget);
      expect(find.text('Configure game options'), findsOneWidget);
      expect(find.text('Return to the landing page'), findsOneWidget);
    });
  });
}
