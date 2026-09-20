import 'package:flutter/material.dart';

import 'hud_screen.dart';
import 'music_state.dart';
import 'call_state.dart';
import 'navigation_state.dart';
import 'hud_theme.dart';

class HudAppState {
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;
  final bool gpsConnected;
  final bool phoneConnected;
  final ThemeMode themeMode;
  final String accentColor;

  final MusicState musicState;
  final HudScreen currentScreen;
  final CallState callState;
  final NavigationState navigationState;

  // Live Ride Capture State
  final bool isRideActive;
  final int rideDurationSeconds;
  final double rideDistanceKm;
  final int rideAvgSpeed;
  final int rideMaxSpeed;
  final List<Map<String, dynamic>> recentRides;

  static const List<Map<String, dynamic>> defaultRecentRides = [
    {
      'title': 'Ride #5',
      'date': 'Today, 08:30 AM',
      'duration': '42 min',
      'distanceKm': 24.6,
      'avgSpeedKm': 35,
      'topSpeedKm': 78,
    },
    {
      'title': 'Ride #4',
      'date': 'Yesterday, 06:15 PM',
      'duration': '1h 15m',
      'distanceKm': 52.3,
      'avgSpeedKm': 42,
      'topSpeedKm': 92,
    },
    {
      'title': 'Ride #3',
      'date': '19 Sep, 07:45 AM',
      'duration': '28 min',
      'distanceKm': 16.8,
      'avgSpeedKm': 36,
      'topSpeedKm': 68,
    },
    {
      'title': 'Ride #2',
      'date': '18 Sep, 05:20 PM',
      'duration': '54 min',
      'distanceKm': 38.2,
      'avgSpeedKm': 42,
      'topSpeedKm': 86,
    },
    {
      'title': 'Ride #1',
      'date': '17 Sep, 09:10 AM',
      'duration': '1h 02m',
      'distanceKm': 45.0,
      'avgSpeedKm': 43,
      'topSpeedKm': 94,
    },
  ];

  const HudAppState({
    this.speed = 0,
    this.latitude = 17.3850,
    this.longitude = 78.4867,
    this.heading = 0,
    this.tripDistanceKm = 0,
    this.gpsConnected = false,
    this.phoneConnected = false,
    this.themeMode = ThemeMode.dark,
    this.accentColor = 'blue',
    required this.musicState,
    this.currentScreen = HudScreen.dashboard,
    this.callState = const CallState(),
    this.navigationState = const NavigationState(),
    this.isRideActive = false,
    this.rideDurationSeconds = 0,
    this.rideDistanceKm = 0.0,
    this.rideAvgSpeed = 0,
    this.rideMaxSpeed = 0,
    this.recentRides = defaultRecentRides,
  });

  HudTheme get theme {
    final base =
        themeMode == ThemeMode.light ? HudTheme.light : HudTheme.dark;
    return base.withAccent(accentColor, isDark: themeMode != ThemeMode.light);
  }

  HudAppState copyWith({
    int? speed,
    double? latitude,
    double? longitude,
    double? heading,
    double? tripDistanceKm,
    bool? gpsConnected,
    bool? phoneConnected,
    ThemeMode? themeMode,
    String? accentColor,
    CallState? callState,
    MusicState? musicState,
    HudScreen? currentScreen,
    NavigationState? navigationState,
    bool? isRideActive,
    int? rideDurationSeconds,
    double? rideDistanceKm,
    int? rideAvgSpeed,
    int? rideMaxSpeed,
    List<Map<String, dynamic>>? recentRides,
  }) {
    return HudAppState(
      speed: speed ?? this.speed,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      gpsConnected: gpsConnected ?? this.gpsConnected,
      phoneConnected: phoneConnected ?? this.phoneConnected,
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      musicState: musicState ?? this.musicState,
      currentScreen: currentScreen ?? this.currentScreen,
      callState: callState ?? this.callState,
      navigationState: navigationState ?? this.navigationState,
      isRideActive: isRideActive ?? this.isRideActive,
      rideDurationSeconds: rideDurationSeconds ?? this.rideDurationSeconds,
      rideDistanceKm: rideDistanceKm ?? this.rideDistanceKm,
      rideAvgSpeed: rideAvgSpeed ?? this.rideAvgSpeed,
      rideMaxSpeed: rideMaxSpeed ?? this.rideMaxSpeed,
      recentRides: recentRides ?? this.recentRides,
    );
  }
}