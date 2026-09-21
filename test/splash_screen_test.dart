import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/screens/splash_screen.dart';
import 'package:bike_hud/widgets/rev_hud_logo.dart';

void main() {
  group('RevHudLogo Tests', () {
    testWidgets('renders Rev and HUD text with vector canvas',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RevHudLogo(
              iconSize: 56,
              fontSize: 38,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byType(RichText), findsOneWidget);
    });
  });

  group('SplashScreen Tests', () {
    testWidgets('renders logo, welcome greeting, version number, and boot text',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            userName: 'Praneeth',
            duration: Duration(seconds: 2),
          ),
        ),
      );

      // Fast-forward initial fade in
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RevHudLogo), findsOneWidget);
      expect(find.text('Welcome, Praneeth'), findsOneWidget);
      expect(find.text('RevHUD - v0.1.0'), findsOneWidget);
      expect(find.text('Initializing...'), findsOneWidget);

      // Let animation finish
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('renders custom user name', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            userName: 'Vikram',
            duration: Duration(seconds: 2),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Welcome, Vikram'), findsOneWidget);

      // Clean up timer
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('tap on screen invokes onFinished callback',
        (WidgetTester tester) async {
      bool finished = false;

      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            userName: 'Praneeth',
            duration: const Duration(seconds: 5),
            onFinished: () => finished = true,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));
      expect(finished, isFalse);

      // Tap on the screen
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(finished, isTrue);

      // Let pending timer expire
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('auto-finishes after duration and calls onFinished',
        (WidgetTester tester) async {
      bool finished = false;

      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            userName: 'Praneeth',
            duration: const Duration(milliseconds: 500),
            onFinished: () => finished = true,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(finished, isFalse);

      // Advance past duration + buffer
      await tester.pump(const Duration(milliseconds: 800));
      expect(finished, isTrue);
    });
  });
}

