import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/screens/safety_disclaimer_screen.dart';

void main() {
  group('SafetyDisclaimerScreen Tests', () {
    testWidgets('renders safety title, exact disclaimer text, and I Understand button',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: SafetyDisclaimerScreen(),
        ),
      );

      expect(find.text('RIDER SAFETY NOTICE'), findsOneWidget);
      expect(
        find.text(
          'Safe use of this device is the rider’s responsibility. Only interact with the device when it is safe to do so, and never while maneuvering or actively controlling the vehicle. Stay alert, remain aware of your surroundings, follow all applicable traffic laws, and always wear a helmet.',
        ),
        findsOneWidget,
      );
      expect(find.text('I Understand'), findsOneWidget);
      expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    });

    testWidgets('tapping I Understand triggers onAccepted callback',
        (WidgetTester tester) async {
      bool accepted = false;

      tester.view.physicalSize = const Size(1024, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: SafetyDisclaimerScreen(
            onAccepted: () => accepted = true,
          ),
        ),
      );

      expect(accepted, isFalse);

      await tester.tap(find.text('I Understand'));
      await tester.pump();

      expect(accepted, isTrue);
    });
  });
}

