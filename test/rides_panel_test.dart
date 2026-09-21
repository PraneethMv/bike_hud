import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/widgets/rides_panel.dart';
import 'package:bike_hud/models/hud_theme.dart';

void main() {
  group('RidesPanel Tests', () {
    testWidgets('renders split-screen menu and switches between Statistics and Mileage',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RidesPanel(
              theme: HudTheme.dark,
              currentOdoKm: 14820.0,
            ),
          ),
        ),
      );

      // Verify Left Menu
      expect(find.text('Rides Hub & Telemetry'), findsOneWidget);
      expect(find.text('Ride Statistics'), findsWidgets);
      expect(find.text('Mileage Tracking'), findsOneWidget);

      // Verify Initial Section (Ride Statistics)
      expect(find.text('TOTAL DISTANCE'), findsOneWidget);
      expect(find.text('RIDE TIME'), findsOneWidget);
      expect(find.text('ALL-TIME TOP'), findsOneWidget);
      expect(find.text('TOTAL RIDES'), findsOneWidget);
      expect(find.text('RECENT COMPLETED TRIPS'), findsOneWidget);

      // Switch to Mileage Tracking
      await tester.tap(find.text('Mileage Tracking'));
      await tester.pumpAndSettle();

      // Verify Mileage Section
      expect(find.text('Mileage & Fuel Log'), findsOneWidget);
      expect(find.text('AVG FUEL ECONOMY'), findsOneWidget);
      expect(find.text('TOTAL FUEL LOGGED'), findsOneWidget);
      expect(find.text('Record Refuel Entry'), findsOneWidget);
      expect(find.text('CONSECUTIVE REFUEL RECORDS'), findsOneWidget);
      expect(find.text('ODO: 14820 km'), findsWidgets);
    });

    testWidgets('records a new refuel entry and updates consecutive records',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      double? recordedLiters;
      double? recordedLastOdo;
      double? recordedCurrentOdo;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RidesPanel(
              theme: HudTheme.dark,
              currentOdoKm: 14820.0,
              onRecordRefuel: (liters, lastOdo, currentOdo) {
                recordedLiters = liters;
                recordedLastOdo = lastOdo;
                recordedCurrentOdo = currentOdo;
              },
            ),
          ),
        ),
      );

      // Switch to Mileage Tracking
      await tester.tap(find.text('Mileage Tracking'));
      await tester.pumpAndSettle();

      // Tap preset '+2 L'
      await tester.tap(find.text('+2 L'));
      await tester.pumpAndSettle();
      expect(find.text('13.5 L'), findsOneWidget);

      // Tap "Record Refuel"
      await tester.tap(find.text('Record Refuel'));
      await tester.pumpAndSettle();

      // Check callback
      expect(recordedLiters, equals(13.5));
      expect(recordedCurrentOdo, equals(14820.0));
      expect(recordedLastOdo, equals(14560.0));

      // Verify that LATEST badge is on the new refuel card
      expect(find.text('LATEST'), findsOneWidget);
    });

    testWidgets('tapping Send Data to Phone triggers sync',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RidesPanel(
              theme: HudTheme.dark,
              phoneConnected: true,
            ),
          ),
        ),
      );

      final sendButton = find.text('Send Data to Phone');
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('Syncing...'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      expect(
        find.text('Ride statistics successfully synced to phone via Bluetooth!'),
        findsOneWidget,
      );
    });
  });
}
