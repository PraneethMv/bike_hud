import 'package:flutter/material.dart';
import '../models/hud_screen.dart';
import '../models/navigation_state.dart';
import '../models/hud_theme.dart';
import 'dashboard_panel.dart';
import 'navigation_panel.dart';
import 'documents_panel.dart';
import 'settings_panel.dart';

class MainPanel extends StatelessWidget {
  final HudScreen currentScreen;
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;
  final NavigationState navigationState;
  final HudTheme theme;
  final bool phoneConnected;
  final ValueChanged<bool> onPhoneConnectionChanged;
  final VoidCallback? onNavTap;

  const MainPanel({
    super.key,
    required this.currentScreen,
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.tripDistanceKm,
    required this.navigationState,
    required this.theme,
    required this.phoneConnected,
    required this.onPhoneConnectionChanged,
    this.onNavTap,
    this.initialShowConnectivity = false,
    this.themeMode = ThemeMode.dark,
    this.onThemeModeChanged,
    this.accentColor = 'blue',
    this.onAccentColorChanged,
    this.isRideActive = false,
    this.rideDurationSeconds = 0,
    this.rideDistanceKm = 0.0,
    this.rideAvgSpeed = 0,
    this.rideMaxSpeed = 0,
    this.onStartRide,
    this.onEndRide,
    this.recentRides,
  });

  final bool initialShowConnectivity;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;
  final String accentColor;
  final ValueChanged<String>? onAccentColorChanged;
  final bool isRideActive;
  final int rideDurationSeconds;
  final double rideDistanceKm;
  final int rideAvgSpeed;
  final int rideMaxSpeed;
  final VoidCallback? onStartRide;
  final VoidCallback? onEndRide;
  final List<Map<String, dynamic>>? recentRides;

  @override
  Widget build(BuildContext context) {
    switch (currentScreen) {
      case HudScreen.dashboard:
        return DashboardPanel(
          speed: speed,
          latitude: latitude,
          longitude: longitude,
          heading: heading,
          tripDistanceKm: tripDistanceKm,
          navigationState: navigationState,
          theme: theme,
          onNavTap: onNavTap,
          isRideActive: isRideActive,
          rideDurationSeconds: rideDurationSeconds,
          rideDistanceKm: rideDistanceKm,
          rideAvgSpeed: rideAvgSpeed,
          rideMaxSpeed: rideMaxSpeed,
          onStartRide: onStartRide,
          onEndRide: onEndRide,
        );
      case HudScreen.navigation:
        return NavigationPanel(
          navigationState: navigationState,
          theme: theme,
        );
      case HudScreen.documents:
        return DocumentsPanel(theme: theme);
      case HudScreen.settings:
        return SettingsPanel(
          theme: theme,
          phoneConnected: phoneConnected,
          onPhoneConnectionChanged: onPhoneConnectionChanged,
          initialShowConnectivity: initialShowConnectivity,
          themeMode: themeMode,
          onThemeModeChanged: onThemeModeChanged,
          accentColor: accentColor,
          onAccentColorChanged: onAccentColorChanged,
          recentRides: recentRides,
        );
    }
  }
}
