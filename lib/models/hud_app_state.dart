import 'call_state.dart';
import 'hud_screen.dart';
import 'music_state.dart';
import 'navigation_state.dart';

class HudAppState {
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;
  final bool gpsConnected;

  final HudScreen currentScreen;
  final MusicState musicState;
  final CallState callState;
  final NavigationState navigationState;

  const HudAppState({
    this.speed = 0,
    this.latitude = 17.3850,
    this.longitude = 78.4867,
    this.heading = 0,
    this.tripDistanceKm = 0,
    this.gpsConnected = false,
    this.currentScreen = HudScreen.dashboard,
    required this.musicState,
    this.callState = const CallState(),
    this.navigationState = const NavigationState(),
  });

  HudAppState copyWith({
    int? speed,
    double? latitude,
    double? longitude,
    double? heading,
    double? tripDistanceKm,
    bool? gpsConnected,
    HudScreen? currentScreen,
    MusicState? musicState,
    CallState? callState,
    NavigationState? navigationState,
  }) {
    return HudAppState(
      speed: speed ?? this.speed,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      tripDistanceKm: tripDistanceKm ?? this.tripDistanceKm,
      gpsConnected: gpsConnected ?? this.gpsConnected,
      currentScreen: currentScreen ?? this.currentScreen,
      musicState: musicState ?? this.musicState,
      callState: callState ?? this.callState,
      navigationState: navigationState ?? this.navigationState,
    );
  }
}
