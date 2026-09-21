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

    double currentOdo = 14820.0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SettingsPanel(
                theme: HudTheme.dark,
                phoneConnected: phoneConnected,
                onPhoneConnectionChanged: (val) => phoneConnected = val,
                initialShowConnectivity: false,
                accentColor: selectedAccent,
                onAccentColorChanged: (accent) => selectedAccent = accent,
                fuelTankCapacityLiters: 13.5,
                currentOdoKm: currentOdo,
                onOdoUpdated: (val) => setState(() => currentOdo = val),
              );
            },
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

    // Switch to Vehicle Information
    await tester.tap(find.text('Vehicle Information'));
    await tester.pumpAndSettle();
    expect(find.text('Vehicle Information & Safety Alerts'), findsOneWidget);
    expect(find.text('Full Tank Capacity'), findsOneWidget);
    expect(find.text('13.5 L'), findsOneWidget);
    expect(find.text('Vehicle ODO Override'), findsOneWidget);
    expect(find.text('14820.0 km'), findsOneWidget);
    expect(find.text('Overspeed Warning Alert'), findsOneWidget);

    // Test ODO Override sync dialog and update
    await tester.tap(find.text('Sync ODO from Phone'));
    await tester.pumpAndSettle();
    expect(find.text('SYNC CLUSTER ODOMETER'), findsOneWidget);
    await tester.tap(find.text('SYNC & OVERRIDE'));
    await tester.pumpAndSettle();
    expect(currentOdo, equals(15240.0));
    expect(find.text('15240.0 km'), findsOneWidget);

    // Test Undo Override
    expect(find.byIcon(Icons.undo_rounded), findsWidgets);
    await tester.tap(find.byIcon(Icons.undo_rounded));
    await tester.pumpAndSettle();
    expect(currentOdo, equals(14820.0));
    expect(find.text('14820.0 km'), findsOneWidget);

    // Switch to Vehicle Documents
    await tester.tap(find.text('Vehicle Documents'));
    await tester.pumpAndSettle();
    expect(find.text('Vehicle Wallet & DigiLocker'), findsOneWidget);
    expect(find.text('Registration Certificate (RC)'), findsWidgets);
    expect(find.text('KA 01 TR 2026'), findsWidgets);

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

  testWidgets('ODO override Undo button times out after 5 seconds and does not throw on unmounted',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    double currentOdo = 14820.0;
    bool showSettings = true;
    StateSetter? stateSetter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              stateSetter = setState;
              if (!showSettings) {
                return const Center(child: Text('Other Screen'));
              }
              return SettingsPanel(
                theme: HudTheme.dark,
                phoneConnected: true,
                onPhoneConnectionChanged: (_) {},
                currentOdoKm: currentOdo,
                onOdoUpdated: (val) => setState(() => currentOdo = val),
              );
            },
          ),
        ),
      ),
    );

    // Switch to Vehicle Information
    await tester.tap(find.text('Vehicle Information'));
    await tester.pumpAndSettle();

    // Trigger sync
    await tester.tap(find.text('Sync ODO from Phone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SYNC & OVERRIDE'));
    await tester.pump();

    // Undo should be available immediately
    expect(find.byIcon(Icons.undo_rounded), findsWidgets);
    expect(currentOdo, equals(15240.0));

    // Advance 5 seconds - Undo button on card should time out and disappear
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(find.byIcon(Icons.undo_rounded), findsNothing);

    // Sync again
    await tester.tap(find.text('Sync ODO from Phone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SYNC & OVERRIDE'));
    await tester.pump();

    // Now simulate user switching screens while SnackBar is still active
    stateSetter?.call(() {
      showSettings = false;
    });
    await tester.pump();
    expect(find.text('Other Screen'), findsOneWidget);

    // Tap UNDO on SnackBar from outside SettingsPanel
    await tester.tap(find.text('UNDO'));
    await tester.pump();
    // Verify it safely reverts without throwing setState after dispose
    expect(currentOdo, equals(15240.0));
    await tester.pumpAndSettle();
  });
}
