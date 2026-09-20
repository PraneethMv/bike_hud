import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/models/hud_theme.dart';
import 'package:bike_hud/models/navigation_state.dart';
import 'package:bike_hud/widgets/dashboard_panel.dart';

void main() {
  testWidgets('DashboardPanel shows Start Ride Capture when inactive and triggers onStartRide',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool started = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardPanel(
            speed: 45,
            latitude: 17.3850,
            longitude: 78.4867,
            heading: 180,
            tripDistanceKm: 12.4,
            navigationState: const NavigationState(),
            theme: HudTheme.dark,
            isRideActive: false,
            onStartRide: () => started = true,
          ),
        ),
      ),
    );

    expect(find.text('Start Ride Capture'), findsOneWidget);
    expect(find.text('Current Trip'), findsNothing);

    await tester.tap(find.text('Start Ride Capture'));
    await tester.pump();
    expect(started, isTrue);
  });

  testWidgets('DashboardPanel shows Current Trip and End Ride Capture when active',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool ended = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DashboardPanel(
            speed: 52,
            latitude: 17.3850,
            longitude: 78.4867,
            heading: 180,
            tripDistanceKm: 12.4,
            navigationState: const NavigationState(),
            theme: HudTheme.dark,
            isRideActive: true,
            rideDurationSeconds: 125, // 02:05
            rideDistanceKm: 5.7,
            rideAvgSpeed: 48,
            rideMaxSpeed: 72,
            onEndRide: () => ended = true,
          ),
        ),
      ),
    );

    expect(find.text('Current Trip'), findsOneWidget);
    expect(find.text('End Ride Capture'), findsOneWidget);
    expect(find.text('5.7 km'), findsOneWidget);
    expect(find.text('02:05'), findsOneWidget);
    expect(find.text('48 km/h'), findsOneWidget);
    expect(find.text('72 km/h'), findsOneWidget);

    await tester.tap(find.text('End Ride Capture'));
    await tester.pump();
    expect(ended, isTrue);
  });
}
