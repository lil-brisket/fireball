import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shinobi_rpg/screens/landing_screen.dart';

void main() {
  group('LandingScreen Tests', () {
    testWidgets('should always show both Register and Sign In buttons', (WidgetTester tester) async {
      // Build the landing screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Wait for initial load and animations to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that both buttons are always visible
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Create a new ninja character'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Access your existing character'), findsOneWidget);
    });

    testWidgets('should show app title and ninja icon', (WidgetTester tester) async {
      // Build the landing screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Wait for initial load and animations to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the app title is visible
      expect(find.text('🥷 Shinobi RPG'), findsOneWidget);
      expect(find.text('A Naruto-inspired Text-Based MMORPG'), findsOneWidget);
      expect(find.text('Master the Art of Ninjutsu'), findsOneWidget);
      
      // Verify that the ninja icon is present
      expect(find.byIcon(Icons.sports_martial_arts), findsOneWidget);
    });

    testWidgets('should show game features in footer', (WidgetTester tester) async {
      // Build the landing screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Wait for initial load and animations to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that game features are visible
      expect(find.text('Game Features'), findsOneWidget);
      expect(find.text('Turn-Based Combat'), findsOneWidget);
      expect(find.text('Jutsu System'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
    });

    testWidgets('should have tappable buttons', (WidgetTester tester) async {
      // Build the landing screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Wait for initial load and animations to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find both buttons
      final registerButton = find.text('Register');
      final signInButton = find.text('Sign In');
      
      expect(registerButton, findsOneWidget);
      expect(signInButton, findsOneWidget);
      
      // Verify both buttons are tappable
      final buttons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton));
      expect(buttons.length, equals(2));
      for (final button in buttons) {
        expect(button.onPressed, isNotNull);
      }
    });

    testWidgets('should have proper button styling and layout', (WidgetTester tester) async {
      // Build the landing screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LandingScreen(),
        ),
      );

      // Wait for initial load and animations to start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify button icons are present
      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.login_rounded), findsOneWidget);
      
      // Verify arrow icons are present
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNWidgets(2));
    });
  });
}
