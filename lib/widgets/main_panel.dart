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
  });

  final bool initialShowConnectivity;

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
        );
    }
  }
}
