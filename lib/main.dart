import 'package:flutter/material.dart';

import 'services/call_simulator_service.dart';
import 'services/gps_simulator_service.dart';
import 'services/handlebar_button_service.dart';
import 'services/music_simulator_service.dart';
import 'services/navigation_simulator_service.dart';

import 'models/call_state.dart';
import 'models/hud_app_state.dart';
import 'models/hud_screen.dart';
import 'models/navigation_state.dart';

void main() {
  runApp(const BikeHudApp());
}

class BikeHudApp extends StatelessWidget {
  const BikeHudApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bike HUD Alpha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const HudHomeScreen(),
    );
  }
}

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
  final MusicSimulatorService _musicSimulatorService = MusicSimulatorService();
  final NavigationSimulatorService _navigationSimulatorService =
      NavigationSimulatorService();

  late HudAppState hudState;

  @override
  void initState() {
    super.initState();

    hudState = HudAppState(
      musicState: _musicSimulatorService.initialState(),
      callState: _callSimulatorService.initialState(),
      navigationState: _navigationSimulatorService.initialState(),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _gpsSimulatorService.stop();
    _navigationSimulatorService.stop();
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

  void _performHandlebarAction(HandlebarAction action) {
    setState(() {
      switch (action) {
        case HandlebarAction.playPause:
          hudState = hudState.copyWith(
            musicState: _musicSimulatorService.togglePlayPause(
              hudState.musicState,
            ),
          );
          break;

        case HandlebarAction.previousTrack:
          hudState = hudState.copyWith(
            musicState: _musicSimulatorService.previousTrack(
              hudState.musicState,
            ),
          );
          break;

        case HandlebarAction.nextTrack:
          hudState = hudState.copyWith(
            musicState: _musicSimulatorService.nextTrack(hudState.musicState),
          );
          break;

        case HandlebarAction.volumeUp:
          hudState = hudState.copyWith(
            musicState: _musicSimulatorService.volumeUp(hudState.musicState),
          );
          break;

        case HandlebarAction.volumeDown:
          hudState = hudState.copyWith(
            musicState: _musicSimulatorService.volumeDown(hudState.musicState),
          );
          break;

        case HandlebarAction.acceptCall:
          hudState = hudState.copyWith(
            callState: _callSimulatorService.acceptCall(hudState.callState),
          );
          break;

        case HandlebarAction.rejectCall:
          hudState = hudState.copyWith(
            callState: _callSimulatorService.rejectCall(hudState.callState),
          );
          break;

        case HandlebarAction.simulateIncomingCall:
          hudState = hudState.copyWith(
            callState: _callSimulatorService.simulateIncomingCall(),
          );
          break;

        case HandlebarAction.openHome:
          hudState = hudState.copyWith(currentScreen: HudScreen.dashboard);
          break;

        case HandlebarAction.openNavigation:
          hudState = hudState.copyWith(currentScreen: HudScreen.navigation);
          break;

        case HandlebarAction.openDocuments:
          hudState = hudState.copyWith(currentScreen: HudScreen.documents);
          break;

        case HandlebarAction.openSettings:
          hudState = hudState.copyWith(currentScreen: HudScreen.settings);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = hudState.musicState.currentTrack;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: const Color(0xFF070B10),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _TopStatusBar(
                      phoneConnected: true,
                      gpsConnected: hudState.gpsConnected,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _MainPanel(
                              currentScreen: hudState.currentScreen,
                              speed: hudState.speed,
                              latitude: hudState.latitude,
                              longitude: hudState.longitude,
                              heading: hudState.heading,
                              tripDistanceKm: hudState.tripDistanceKm,
                              navigationState: hudState.navigationState,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _MusicCard(
                                  title: currentTrack.title,
                                  artist: currentTrack.artist,
                                  isPlaying: hudState.musicState.isPlaying,
                                  volume: hudState.musicState.volume,
                                ),
                                const SizedBox(height: 16),
                                _ControlsHelpCard(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!hudState.callState.isIdle)
                _IncomingCallOverlay(
                  callState: hudState.callState,
                  onAccept: () {
                    setState(() {
                      hudState = hudState.copyWith(
                        callState: _callSimulatorService.acceptCall(
                          hudState.callState,
                        ),
                      );
                    });
                  },
                  onReject: () {
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

class _TopStatusBar extends StatelessWidget {
  final bool phoneConnected;
  final bool gpsConnected;

  const _TopStatusBar({
    required this.phoneConnected,
    required this.gpsConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Flexible(
          child: Text(
            'BIKE HUD ALPHA',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Row(
                children: [
                  _StatusChip(
                    label: phoneConnected ? 'PHONE OK' : 'PHONE OFF',
                    icon: Icons.phone_android,
                  ),
                  const SizedBox(width: 10),
                  _StatusChip(
                    label: gpsConnected ? 'GPS OK' : 'GPS LOST',
                    icon: Icons.gps_fixed,
                  ),
                  const SizedBox(width: 10),
                  const _StatusChip(label: '10:42', icon: Icons.access_time),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111A24),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF263548)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MainPanel extends StatelessWidget {
  final HudScreen currentScreen;
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;
  final NavigationState navigationState;

  const _MainPanel({
    required this.currentScreen,
    required this.speed,
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.tripDistanceKm,
    required this.navigationState,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentScreen) {
      case HudScreen.dashboard:
        return _DashboardPanel(
          speed: speed,
          latitude: latitude,
          longitude: longitude,
          heading: heading,
          tripDistanceKm: tripDistanceKm,
        );
      case HudScreen.navigation:
        return _NavigationPanel(navigationState: navigationState);
      case HudScreen.documents:
        return const _DocumentsPanel();
      case HudScreen.settings:
        return const _SettingsPanel();
    }
  }
}

class _DashboardPanel extends StatelessWidget {
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;

  const _DashboardPanel({
    required this.speed,
    required this.longitude,
    required this.latitude,
    required this.heading,
    required this.tripDistanceKm,
  });

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CURRENT SPEED',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$speed',
                  style: const TextStyle(
                    fontSize: 140,
                    fontWeight: FontWeight.w800,
                    height: 0.9,
                  ),
                ),
                const SizedBox(width: 12),
                const Padding(
                  padding: EdgeInsets.only(bottom: 18),
                  child: Text(
                    'km/h',
                    style: TextStyle(fontSize: 28, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _MiniInfoRow(
            tripDistanceKm: tripDistanceKm,
            latitude: latitude,
            longitude: longitude,
            heading: heading,
          ),
        ],
      ),
    );
  }
}

class _NavigationPanel extends StatelessWidget {
  final NavigationState navigationState;

  const _NavigationPanel({required this.navigationState});

  @override
  Widget build(BuildContext context) {
    return _HudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NAVIGATION',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          const Icon(Icons.turn_right, size: 100),
          const SizedBox(height: 20),
          Text(
            navigationState.nextInstruction,
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Destination: ${navigationState.destinationName}',
            style: const TextStyle(fontSize: 24, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _SmallMetric(
                label: 'Next turn',
                value:
                    '${navigationState.distanceToNextTurnMeters.toStringAsFixed(0)} m',
              ),
              const SizedBox(width: 12),
              _SmallMetric(
                label: 'Remaining',
                value:
                    '${navigationState.distanceToDestinationKm.toStringAsFixed(1)} km',
              ),
              const SizedBox(width: 12),
              _SmallMetric(
                label: 'ETA',
                value: '${navigationState.etaMinutes} min',
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Map screen will come later. For alpha, this is a simulated route.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _DocumentsPanel extends StatelessWidget {
  const _DocumentsPanel();

  @override
  Widget build(BuildContext context) {
    return const _HudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DOCUMENTS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 24),
          _DocumentTile(title: 'Registration Certificate', status: 'Stored'),
          _DocumentTile(title: 'Driving Licence', status: 'Stored'),
          _DocumentTile(title: 'Insurance', status: 'Not added'),
          _DocumentTile(title: 'PUC Certificate', status: 'Not added'),
          Spacer(),
          Text(
            'Later: encrypt these files and lock behind PIN/biometric access.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel();

  @override
  Widget build(BuildContext context) {
    return const _HudCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 24),
          _DocumentTile(title: 'Theme', status: 'Dark'),
          _DocumentTile(title: 'Units', status: 'km/h'),
          _DocumentTile(title: 'Button Mode', status: 'Media + Calls'),
          _DocumentTile(title: 'Navigation Provider', status: 'Mock'),
        ],
      ),
    );
  }
}

class _MiniInfoRow extends StatelessWidget {
  final double tripDistanceKm;
  final double heading;
  final double latitude;
  final double longitude;

  const _MiniInfoRow({
    required this.tripDistanceKm,
    required this.heading,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallMetric(
          label: 'Trip',
          value: '${tripDistanceKm.toStringAsFixed(2)} km',
        ),
        const SizedBox(width: 12),
        _SmallMetric(label: 'Heading', value: '${heading.toStringAsFixed(0)}°'),
        const SizedBox(width: 12),
        _SmallMetric(
          label: 'GPS',
          value:
              '${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}',
        ),
      ],
    );
  }
}

class _SmallMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SmallMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0C131C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF243244)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _MusicCard extends StatelessWidget {
  final String title;
  final String artist;
  final bool isPlaying;
  final int volume;

  const _MusicCard({
    required this.title,
    required this.artist,
    required this.isPlaying,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _HudCard(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MUSIC',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Icon(
                isPlaying ? Icons.pause_circle : Icons.play_circle,
                size: 64,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
              const SizedBox(height: 18),
              Text(
                isPlaying ? 'Playing' : 'Paused',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Text(
                'Volume: $volume%',
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlsHelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: _HudCard(
        child: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KEYBOARD CONTROLS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 16),
              Text('Space  → Play / Pause'),
              Text('← / →  → Previous / Next'),
              Text('↑ / ↓  → Volume Up / Down'),
              Text('C      → Simulate incoming call'),
              Text('Enter  → Accept call'),
              Text('Esc    → Reject call'),
              Text('N      → Navigation'),
              Text('D      → Documents'),
              Text('S      → Settings'),
              Text('H      → Home'),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingCallOverlay extends StatelessWidget {
  final CallState callState;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingCallOverlay({
    required this.callState,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: Center(
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF111A24),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF394B61)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.call, size: 72),
              const SizedBox(height: 20),
              Text(
                callState.isActive ? 'Active Call' : 'Incoming Call',
                style: const TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Text(
                callState.callerName,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (callState.callerNumber.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  callState.callerNumber,
                  style: const TextStyle(fontSize: 18, color: Colors.white54),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.call_end),
                      label: Text(callState.isActive ? 'End' : 'Reject'),
                    ),
                  ),
                  if (callState.isIncoming) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.call),
                        label: const Text('Accept'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final String title;
  final String status;

  const _DocumentTile({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C131C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF243244)),
      ),
      child: Row(
        children: [
          const Icon(Icons.description),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text(status, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }
}

class _HudCard extends StatelessWidget {
  final Widget child;

  const _HudCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF263548)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}
