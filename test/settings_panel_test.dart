import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/models/hud_theme.dart';
import 'package:bike_hud/widgets/settings_panel.dart';

void main() {
  testWidgets('SettingsPanel renders and allows section switching without error',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool phoneConnected = false;
    String selectedAccent = 'blue';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsPanel(
            theme: HudTheme.dark,
            phoneConnected: phoneConnected,
            onPhoneConnectionChanged: (val) => phoneConnected = val,
            initialShowConnectivity: false,
            accentColor: selectedAccent,
            onAccentColorChanged: (accent) => selectedAccent = accent,
          ),
        ),
      ),
    );

    // Initial section should be Display
    expect(find.text('AeroHUD System Settings'), findsOneWidget);
    expect(find.text('Display'), findsWidgets);
    expect(find.text('Display & Appearance'), findsOneWidget);
    expect(find.text('Accent Color'), findsOneWidget);

    // Test functional accent color picker
    await tester.tap(find.text('Forest Green'));
    await tester.pumpAndSettle();
    expect(selectedAccent, equals('emerald'));

    // Switch to Ride Statistics & Alerts
    await tester.tap(find.text('Ride Statistics & Alerts'));
    await tester.pumpAndSettle();
    expect(find.text('Ride Statistics & Alerts'), findsWidgets);
    expect(find.text('Ride Statistics'), findsOneWidget);
    expect(find.text('Send Data to Phone'), findsOneWidget);
    expect(find.text('Ride #5'), findsOneWidget);
    expect(find.text('Overspeed Warning Alert'), findsOneWidget);

    // Tap Send Data to Phone
    await tester.tap(find.text('Send Data to Phone'));
    await tester.pump();
    expect(find.text('Syncing...'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Switch to Bluetooth
    await tester.tap(find.text('Bluetooth'));
    await tester.pumpAndSettle();
    expect(find.text('Bluetooth Pairing'), findsOneWidget);

    // Switch to System
    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(find.text('System & Diagnostics'), findsOneWidget);
    expect(find.text('Hardware Profile'), findsOneWidget);
    expect(find.text('GNSS / GPS Receiver'), findsOneWidget);
    expect(find.text('Firmware Update'), findsOneWidget);
  });

  testWidgets('SettingsPanel with initialShowConnectivity starts on connectivity section',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsPanel(
            theme: HudTheme.dark,
            phoneConnected: true,
            onPhoneConnectionChanged: (_) {},
            initialShowConnectivity: true,
          ),
        ),
      ),
    );

    expect(find.text('Bluetooth Pairing'), findsOneWidget);
  });
}
