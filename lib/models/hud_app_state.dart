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

  final MusicState musicState;
  final HudScreen currentScreen;
  final CallState callState;
  final NavigationState navigationState;

  const HudAppState({
    this.speed = 0,
    this.latitude = 17.3850,
    this.longitude = 78.4867,
    this.heading = 0,
    this.tripDistanceKm = 0,
    this.gpsConnected = false,
    this.phoneConnected = false,
    this.themeMode = ThemeMode.dark,
    required this.musicState,
    this.currentScreen = HudScreen.dashboard,
    this.callState = const CallState(),
    this.navigationState = const NavigationState(),
  });

  HudTheme get theme =>
      themeMode == ThemeMode.light ? HudTheme.light : HudTheme.dark;

  HudAppState copyWith({
    int? speed,
    double? latitude,
    double? longitude,
    double? heading,
    double? tripDistanceKm,
    bool? gpsConnected,
    bool? phoneConnected,
    ThemeMode? themeMode,
    CallState? callState,
    MusicState? musicState,
    HudScreen? currentScreen,
    NavigationState? navigationState,
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
      musicState: musicState ?? this.musicState,
      currentScreen: currentScreen ?? this.currentScreen,
      callState: callState ?? this.callState,
      navigationState: navigationState ?? this.navigationState,
    );
  }
}