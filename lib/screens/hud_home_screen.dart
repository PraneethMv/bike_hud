import 'dart:async';
import 'package:flutter/material.dart';

import '../services/call_simulator_service.dart';
import '../services/gps_simulator_service.dart';
import '../services/handlebar_button_service.dart';
import '../services/music_service.dart';
import '../services/navigation_simulator_service.dart';
import '../services/bluetooth_service.dart';

import '../models/hud_app_state.dart';
import '../models/hud_screen.dart';

import '../widgets/top_status_bar.dart';
import '../widgets/main_panel.dart';
import '../widgets/music_card.dart';
import '../widgets/incoming_call_overlay.dart';
import '../widgets/nav_dock.dart';

class HudHomeScreen extends StatefulWidget {
  const HudHomeScreen({super.key});

  @override
  State<HudHomeScreen> createState() => _HudHomeScreenState();
}

class _HudHomeScreenState extends State<HudHomeScreen> {
  final FocusNode _focusNode = FocusNode();
  final CallSimulatorService _callSimulatorService = CallSimulatorService();
  final GpsSimulatorService _gpsSimulatorService = GpsSimulatorService();
  final HandlebarButtonService _handlebarButtonService =
      HandlebarButtonService();
  final MusicService _musicService = MusicService();
  final NavigationSimulatorService _navigationSimulatorService =
      NavigationSimulatorService();
  final BluetoothService _bluetoothService = BluetoothService();

  late HudAppState hudState;
  Timer? _musicSyncTimer;
  Timer? _clockTimer;
  Timer? _callDurationTimer;
  Timer? _rideCaptureTimer;
  final List<int> _rideSpeedSamples = [];
  String _timeString = "14:32";
  bool _openConnectivitySettings = false;

  @override
  void initState() {
    super.initState();

    hudState = HudAppState(
      musicState: _musicService.initialState(),
      callState: _callSimulatorService.initialState(),
      navigationState: _navigationSimulatorService.initialState(),
      themeMode: ThemeMode.dark,
      phoneConnected: false,
    );

    _gpsSimulatorService.start(
      onData: (data) {
        setState(() {
          hudState = hudState.copyWith(
            speed: data.speed,
            latitude: data.latitude,
            longitude: data.longitude,
            heading: data.heading,
            tripDistanceKm: data.tripDistanceKm,
            gpsConnected: data.gpsConnected,
          );
        });
      },
    );

    _navigationSimulatorService.start(
      onData: (state) {
        setState(() {
          hudState = hudState.copyWith(navigationState: state);
        });
      },
    );

    // Sync clock time
    _updateTime();
    _clockTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _updateTime();
    });

    // Poll media info and Bluetooth status from native OS every second
    _musicSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final syncedState = await _musicService.syncWithSystem(hudState.musicState);
      final isBtConnected = await _bluetoothService.isBluetoothConnected();
      if (mounted) {
        setState(() {
          hudState = hudState.copyWith(
            musicState: syncedState,
            phoneConnected: isBtConnected || hudState.phoneConnected,
          );
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _focusNode.requestFocus();
      
      // Request Android Notification Access for MediaSessionManager
      final hasAccess = await _musicService.hasNotificationAccess();
      if (!hasAccess) {
        await _musicService.requestNotificationAccess();
      }
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final String formatted =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    if (formatted != _timeString) {
      setState(() {
        _timeString = formatted;
      });
    }
  }

  void _startCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (hudState.callState.isActive) {
        setState(() {
          hudState = hudState.copyWith(
            callState: hudState.callState.copyWith(
              durationSeconds: hudState.callState.durationSeconds + 1,
            ),
          );
        });
      } else {
        _stopCallDurationTimer();
      }
    });
  }

  void _stopCallDurationTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = null;
  }

  void _startRideCapture() {
    _rideCaptureTimer?.cancel();
    _rideSpeedSamples.clear();
    setState(() {
      hudState = hudState.copyWith(
        isRideActive: true,
        rideDurationSeconds: 0,
        rideDistanceKm: 0.0,
        rideAvgSpeed: 0,
        rideMaxSpeed: 0,
      );
    });

    _rideCaptureTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !hudState.isRideActive) return;

      final currentSpeed = hudState.speed;
      _rideSpeedSamples.add(currentSpeed);

      final newDuration = hudState.rideDurationSeconds + 1;
      final double distInc = currentSpeed > 0 ? (currentSpeed / 3600.0) : 0.005;
      final newDist = hudState.rideDistanceKm + distInc;
      final newMax = currentSpeed > hudState.rideMaxSpeed ? currentSpeed : hudState.rideMaxSpeed;
      final avgSpeed = _rideSpeedSamples.isEmpty
          ? currentSpeed
          : (_rideSpeedSamples.reduce((a, b) => a + b) / _rideSpeedSamples.length).round();

      setState(() {
        hudState = hudState.copyWith(
          rideDurationSeconds: newDuration,
          rideDistanceKm: newDist,
          rideMaxSpeed: newMax,
          rideAvgSpeed: avgSpeed > 0 ? avgSpeed : currentSpeed,
        );
      });
    });
  }

  void _endRideCapture() {
    _rideCaptureTimer?.cancel();
    _rideCaptureTimer = null;

    final now = DateTime.now();
    final String formattedDate = 'Today, ${_formatRideTime(now)}';
    final String durationStr = _formatRideDuration(hudState.rideDurationSeconds);
    final double distFinal = double.parse(hudState.rideDistanceKm.toStringAsFixed(1));
    final int topFinal = hudState.rideMaxSpeed > 0 ? hudState.rideMaxSpeed : hudState.speed;
    final int avgFinal = hudState.rideAvgSpeed > 0 ? hudState.rideAvgSpeed : (topFinal * 0.65).round();

    final newRide = {
      'title': 'Ride #${hudState.recentRides.length + 1}',
      'date': formattedDate,
      'duration': durationStr,
      'distanceKm': distFinal > 0 ? distFinal : 0.8,
      'avgSpeedKm': avgFinal > 0 ? avgFinal : 32,
      'topSpeedKm': topFinal > 0 ? topFinal : 45,
    };

    setState(() {
      hudState = hudState.copyWith(
        isRideActive: false,
        recentRides: [newRide, ...hudState.recentRides],
      );
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ride #${hudState.recentRides.length} saved! Added to Ride Statistics in Settings.',
          style: const TextStyle(fontFamily: 'Space Grotesk'),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: hudState.theme.primaryContainer,
      ),
    );
  }

  String _formatRideDuration(int totalSeconds) {
    if (totalSeconds < 60) {
      return '$totalSeconds sec';
    }
    final mins = totalSeconds ~/ 60;
    final hours = mins ~/ 60;
    final remMins = mins % 60;
    if (hours > 0) {
      return '${hours}h ${remMins}m';
    }
    return '$mins min';
  }

  String _formatRideTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $amPm';
  }

  @override
  void dispose() {
    _gpsSimulatorService.stop();
    _navigationSimulatorService.stop();
    _musicSyncTimer?.cancel();
    _clockTimer?.cancel();
    _callDurationTimer?.cancel();
    _rideCaptureTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    final action = _handlebarButtonService.actionFromKeyEvent(event);

    if (action == null) {
      return;
    }

    _performHandlebarAction(action);
  }

  void _performHandlebarAction(HandlebarAction action) async {
    switch (action) {
      case HandlebarAction.playPause:
        if (!hudState.phoneConnected) break;
        final newState = await _musicService.togglePlayPause(hudState.musicState);
        setState(() {
          hudState = hudState.copyWith(musicState: newState);
        });
        break;

      case HandlebarAction.previousTrack:
        if (!hudState.phoneConnected) break;
        final newState = await _musicService.previousTrack(hudState.musicState);
        setState(() {
          hudState = hudState.copyWith(musicState: newState);
        });
        break;

      case HandlebarAction.nextTrack:
        if (!hudState.phoneConnected) break;
        final newState = await _musicService.nextTrack(hudState.musicState);
        setState(() {
          hudState = hudState.copyWith(musicState: newState);
        });
        break;

      case HandlebarAction.volumeUp:
        if (!hudState.phoneConnected) break;
        setState(() {
          hudState = hudState.copyWith(
            musicState: _musicService.volumeUp(hudState.musicState),
          );
        });
        break;

      case HandlebarAction.volumeDown:
        if (!hudState.phoneConnected) break;
        setState(() {
          hudState = hudState.copyWith(
            musicState: _musicService.volumeDown(hudState.musicState),
          );
        });
        break;

      case HandlebarAction.acceptCall:
        if (hudState.callState.isIncoming) {
          setState(() {
            hudState = hudState.copyWith(
              callState: _callSimulatorService.acceptCall(hudState.callState),
            );
          });
          _startCallDurationTimer();
        }
        break;

      case HandlebarAction.rejectCall:
        _stopCallDurationTimer();
        setState(() {
          hudState = hudState.copyWith(
            callState: _callSimulatorService.rejectCall(hudState.callState),
          );
        });
        break;

      case HandlebarAction.simulateIncomingCall:
        _stopCallDurationTimer();
        setState(() {
          hudState = hudState.copyWith(
            callState: _callSimulatorService.simulateIncomingCall(),
          );
        });
        break;

      case HandlebarAction.openHome:
        setState(() {
          _openConnectivitySettings = false;
          hudState = hudState.copyWith(currentScreen: HudScreen.dashboard);
        });
        break;

      case HandlebarAction.openNavigation:
        setState(() {
          _openConnectivitySettings = false;
          hudState = hudState.copyWith(currentScreen: HudScreen.navigation);
        });
        break;

      case HandlebarAction.openDocuments:
        setState(() {
          _openConnectivitySettings = false;
          hudState = hudState.copyWith(currentScreen: HudScreen.documents);
        });
        break;

      case HandlebarAction.openSettings:
        setState(() {
          _openConnectivitySettings = false;
          hudState = hudState.copyWith(currentScreen: HudScreen.settings);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = hudState.musicState.currentTrack;
    final theme = hudState.theme;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: theme.bg,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 64),
                child: Column(
                  children: [
                    TopStatusBar(
                      phoneConnected: hudState.phoneConnected,
                      gpsConnected: hudState.gpsConnected,
                      theme: theme,
                      themeMode: hudState.themeMode,
                      onThemeChanged: (mode) {
                        setState(() {
                          hudState = hudState.copyWith(themeMode: mode);
                        });
                      },
                      timeString: _timeString,
                      callState: hudState.callState,
                      currentSpeed: hudState.speed.toDouble(),
                      speedLimit: 60,
                      onEndCall: () {
                        _stopCallDurationTimer();
                        setState(() {
                          hudState = hudState.copyWith(
                            callState: _callSimulatorService.endCall(hudState.callState),
                          );
                        });
                      },
                      showMiniMusic: hudState.phoneConnected &&
                          hudState.currentScreen != HudScreen.dashboard,
                      musicTitle: currentTrack.title,
                      musicArtist: currentTrack.artist,
                      isPlaying: hudState.musicState.isPlaying,
                      onMusicTap: () {
                        setState(() {
                          hudState = hudState.copyWith(currentScreen: HudScreen.dashboard);
                        });
                      },
                      onPhoneTap: () {
                        setState(() {
                          _openConnectivitySettings = true;
                          hudState = hudState.copyWith(currentScreen: HudScreen.settings);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: hudState.currentScreen == HudScreen.dashboard ? 3 : 1,
                            child: MainPanel(
                              currentScreen: hudState.currentScreen,
                              speed: hudState.speed,
                              latitude: hudState.latitude,
                              longitude: hudState.longitude,
                              heading: hudState.heading,
                              tripDistanceKm: hudState.tripDistanceKm,
                              navigationState: hudState.navigationState,
                              theme: theme,
                              themeMode: hudState.themeMode,
                              onThemeModeChanged: (mode) {
                                setState(() {
                                  hudState = hudState.copyWith(themeMode: mode);
                                });
                              },
                              accentColor: hudState.accentColor,
                              onAccentColorChanged: (accent) {
                                setState(() {
                                  hudState = hudState.copyWith(accentColor: accent);
                                });
                              },
                              phoneConnected: hudState.phoneConnected,
                              initialShowConnectivity: _openConnectivitySettings,
                              onPhoneConnectionChanged: (connected) {
                                setState(() {
                                  hudState = hudState.copyWith(phoneConnected: connected);
                                });
                              },
                              onNavTap: () {
                                setState(() {
                                  hudState = hudState.copyWith(currentScreen: HudScreen.navigation);
                                });
                              },
                              isRideActive: hudState.isRideActive,
                              rideDurationSeconds: hudState.rideDurationSeconds,
                              rideDistanceKm: hudState.rideDistanceKm,
                              rideAvgSpeed: hudState.rideAvgSpeed,
                              rideMaxSpeed: hudState.rideMaxSpeed,
                              onStartRide: _startRideCapture,
                              onEndRide: _endRideCapture,
                              recentRides: hudState.recentRides,
                            ),
                          ),
                          if (hudState.currentScreen == HudScreen.dashboard) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: MusicCard(
                                phoneConnected: hudState.phoneConnected,
                                onConnectTap: () {
                                  setState(() {
                                    _openConnectivitySettings = true;
                                    hudState = hudState.copyWith(currentScreen: HudScreen.settings);
                                  });
                                },
                                title: currentTrack.title,
                                artist: currentTrack.artist,
                                isPlaying: hudState.musicState.isPlaying,
                                volume: hudState.musicState.volume,
                                onPlayPause: () async {
                                  final newState = await _musicService.togglePlayPause(hudState.musicState);
                                  setState(() {
                                    hudState = hudState.copyWith(musicState: newState);
                                  });
                                },
                                onNext: () async {
                                  final newState = await _musicService.nextTrack(hudState.musicState);
                                  setState(() {
                                    hudState = hudState.copyWith(musicState: newState);
                                  });
                                },
                                onPrevious: () async {
                                  final newState = await _musicService.previousTrack(hudState.musicState);
                                  setState(() {
                                    hudState = hudState.copyWith(musicState: newState);
                                  });
                                },
                                onVolumeUp: () {
                                  setState(() {
                                    hudState = hudState.copyWith(
                                      musicState: _musicService.volumeUp(hudState.musicState),
                                    );
                                  });
                                },
                                onVolumeDown: () {
                                  setState(() {
                                    hudState = hudState.copyWith(
                                      musicState: _musicService.volumeDown(hudState.musicState),
                                    );
                                  });
                                },
                                theme: theme,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Floating Bottom Dock
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: NavDock(
                    currentScreen: hudState.currentScreen,
                    onScreenSelected: (screen) {
                      setState(() {
                        _openConnectivitySettings = false;
                        hudState = hudState.copyWith(currentScreen: screen);
                      });
                    },
                    theme: theme,
                  ),
                ),
              ),
              if (hudState.callState.isIncoming)
                IncomingCallBanner(
                  callState: hudState.callState,
                  theme: theme,
                  onAccept: () {
                    setState(() {
                      hudState = hudState.copyWith(
                        callState: _callSimulatorService.acceptCall(
                          hudState.callState,
                        ),
                      );
                    });
                    _startCallDurationTimer();
                  },
                  onReject: () {
                    _stopCallDurationTimer();
                    setState(() {
                      hudState = hudState.copyWith(
                        callState: _callSimulatorService.rejectCall(
                          hudState.callState,
                        ),
                      );
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
