import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shinobi_rpg/screens/login_screen.dart';

void main() {
  group('LoginScreen Tests', () {
    testWidgets('should always show login form', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Wait for initial load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that login form is always shown
      expect(find.text('Enter Your Login Details'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Login to Game'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should have proper UI elements', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Wait for initial load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the app bar is present
      expect(find.text('Login'), findsOneWidget);
      
      // Verify that the welcome message is present
      expect(find.text('Welcome Back, Shinobi'), findsOneWidget);
      expect(find.text('Log in to continue your ninja journey'), findsOneWidget);
    });

    testWidgets('should show login form with proper validation', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Wait for initial load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that login form is shown
      expect(find.text('Enter Your Login Details'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Login to Game'), findsOneWidget);
      
      // Test form validation
      final loginButton = find.text('Login to Game');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify validation error appears
      expect(find.text('Please enter your username'), findsOneWidget);
    });

    testWidgets('should show proper UI structure', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Wait for initial load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify that the app bar is present
      expect(find.text('Login'), findsOneWidget);
      
      // Verify that the welcome message is present
      expect(find.text('Welcome Back, Shinobi'), findsOneWidget);
      expect(find.text('Log in to continue your ninja journey'), findsOneWidget);
      
      // Verify that login form is always shown
      expect(find.text('Enter Your Login Details'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
