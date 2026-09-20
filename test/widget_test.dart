import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/models/call_state.dart';
import 'package:bike_hud/models/hud_theme.dart';
import 'package:bike_hud/widgets/incoming_call_overlay.dart';
import 'package:bike_hud/widgets/top_status_bar.dart';

void main() {
  testWidgets('IncomingCallBanner renders caller info and action buttons',
      (WidgetTester tester) async {
    const incomingCall = CallState(
      status: CallStatus.incoming,
      callerName: 'Alex Smith',
      callerNumber: '+1 555-0199',
    );

    bool accepted = false;
    bool rejected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              IncomingCallBanner(
                callState: incomingCall,
                theme: HudTheme.dark,
                onAccept: () => accepted = true,
                onReject: () => rejected = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Alex Smith'), findsOneWidget);
    expect(find.text('+1 555-0199'), findsOneWidget);
    expect(find.text('Decline'), findsOneWidget);
    expect(find.text('Answer'), findsOneWidget);

    await tester.tap(find.text('Answer'));
    expect(accepted, isTrue);

    await tester.tap(find.text('Decline'));
    expect(rejected, isTrue);
  });

  testWidgets('TopStatusBar renders active call pill with duration timer',
      (WidgetTester tester) async {
    const activeCall = CallState(
      status: CallStatus.active,
      callerName: 'Alex Smith',
      callerNumber: '+1 555-0199',
      durationSeconds: 83,
    );

    bool ended = false;

    tester.view.physicalSize = const Size(1024, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TopStatusBar(
            phoneConnected: true,
            gpsConnected: true,
            theme: HudTheme.dark,
            themeMode: ThemeMode.dark,
            onThemeChanged: (_) {},
            timeString: '15:45',
            callState: activeCall,
            onEndCall: () => ended = true,
          ),
        ),
      ),
    );

    expect(find.text('Alex Smith'), findsOneWidget);
    expect(find.text('01:23'), findsOneWidget);

    // Tap the hang up button
    final hangUpFinder = find.byIcon(Icons.call_end_rounded);
    expect(hangUpFinder, findsOneWidget);
    await tester.tap(hangUpFinder);
    expect(ended, isTrue);
  });
}
