# Bike HUD Flutter Alpha — Codex Handoff

## Project Summary

The project is a custom **Android Auto / Ather Stack-inspired smart bike HUD**, built as a Flutter desktop alpha before buying or integrating hardware.

The goal is to first create a PC-testable dashboard app with simulated inputs and services, then later connect it to real bike hardware such as touchscreen, GPS module, ESP32 handlebar buttons, and phone connectivity.

Primary target for now:

- Flutter desktop app running on Windows
- Custom smart bike dashboard UI
- Simulated GPS speedometer
- Simulated music controls
- Simulated incoming/active call flow
- Keyboard keys acting as future handlebar buttons
- Mock navigation/documents/settings screens

Hardware is intentionally deferred until the software alpha is stable.

---

## Current Development Approach

The app is being built in phases:

1. Build working UI on PC.
2. Add simulator services.
3. Convert raw keyboard inputs into hardware-like actions.
4. Move state into clean models.
5. Gradually move logic out of `main.dart` into services.
6. Later connect actual GPS, ESP32 buttons, phone companion app, and touchscreen hardware.

The current app should still run with:

```bash
flutter run -d windows
```

---

## Confirmed Working So Far

The user has confirmed that the initial Flutter desktop HUD app ran successfully.

The user has also confirmed that the GPS simulator refactor and app state refactor worked.

The following modules were introduced in the conversation and should be treated as the current expected architecture, but Codex should verify the project compiles after all changes:

- `GpsSimulatorService`
- `HandlebarButtonService`
- `HudAppState`
- `MusicSimulatorService`
- `CallSimulatorService`

---

## Current Expected Folder Structure

```text
lib/
 ├─ main.dart
 ├─ models/
 │   ├─ call_state.dart
 │   ├─ hud_app_state.dart
 │   ├─ hud_screen.dart
 │   ├─ music_state.dart
 │   └─ music_track.dart
 ├─ services/
 │   ├─ call_simulator_service.dart
 │   ├─ gps_simulator_service.dart
 │   ├─ handlebar_button_service.dart
 │   └─ music_simulator_service.dart
 ├─ screens/
 └─ widgets/
```

The `screens/` and `widgets/` folders currently exist for future refactoring. Most UI may still be inside `main.dart`.

---

## Implemented / Planned Models

### `lib/models/hud_screen.dart`

```dart
enum HudScreen {
  dashboard,
  navigation,
  documents,
  settings,
}
```

---

### `lib/models/music_track.dart`

```dart
class MusicTrack {
  final String title;
  final String artist;

  const MusicTrack({
    required this.title,
    required this.artist,
  });
}
```

---

### `lib/models/music_state.dart`

```dart
import 'music_track.dart';

class MusicState {
  final List<MusicTrack> tracks;
  final int currentTrackIndex;
  final bool isPlaying;
  final int volume;

  const MusicState({
    required this.tracks,
    this.currentTrackIndex = 0,
    this.isPlaying = false,
    this.volume = 50,
  });

  MusicTrack get currentTrack => tracks[currentTrackIndex];

  MusicState copyWith({
    List<MusicTrack>? tracks,
    int? currentTrackIndex,
    bool? isPlaying,
    int? volume,
  }) {
    return MusicState(
      tracks: tracks ?? this.tracks,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}
```

---

### `lib/models/call_state.dart`

```dart
enum CallStatus {
  idle,
  incoming,
  active,
}

class CallState {
  final CallStatus status;
  final String callerName;
  final String callerNumber;

  const CallState({
    this.status = CallStatus.idle,
    this.callerName = '',
    this.callerNumber = '',
  });

  bool get isIncoming => status == CallStatus.incoming;
  bool get isActive => status == CallStatus.active;
  bool get isIdle => status == CallStatus.idle;

  CallState copyWith({
    CallStatus? status,
    String? callerName,
    String? callerNumber,
  }) {
    return CallState(
      status: status ?? this.status,
      callerName: callerName ?? this.callerName,
      callerNumber: callerNumber ?? this.callerNumber,
    );
  }
}
```

---

### `lib/models/hud_app_state.dart`

Expected latest version:

```dart
import 'call_state.dart';
import 'hud_screen.dart';
import 'music_state.dart';

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
    );
  }
}
```

---

## Implemented / Planned Services

### `lib/services/gps_simulator_service.dart`

Purpose:

- Simulates GPS speed.
- Simulates latitude and longitude changes.
- Simulates heading.
- Simulates trip distance.
- Emits data every second.

Expected behavior:

- Speed increments every second.
- Speed resets after reaching a high value.
- Trip distance increases.
- GPS status is `true`.

---

### `lib/services/handlebar_button_service.dart`

Purpose:

Convert desktop keyboard events into future bike handlebar actions.

Expected enum:

```dart
enum HandlebarAction {
  playPause,
  previousTrack,
  nextTrack,
  volumeUp,
  volumeDown,
  acceptCall,
  rejectCall,
  simulateIncomingCall,
  openHome,
  openNavigation,
  openDocuments,
  openSettings,
}
```

Expected keyboard mapping:

| Key | Action |
|---|---|
| `Space` | Play / pause |
| `Left arrow` | Previous track |
| `Right arrow` | Next track |
| `Up arrow` | Volume up |
| `Down arrow` | Volume down |
| `Enter` | Accept call |
| `Esc` | Reject incoming call / end active call |
| `C` | Simulate incoming call |
| `H` | Home dashboard |
| `N` | Navigation |
| `D` | Documents |
| `S` | Settings |

---

### `lib/services/music_simulator_service.dart`

Purpose:

Move music behavior out of `main.dart`.

Expected features:

- Initial music state
- Play/pause toggle
- Next track
- Previous track
- Volume up
- Volume down

Default tracks currently suggested:

```dart
static const List<MusicTrack> defaultTracks = [
  MusicTrack(title: 'Blinding Lights', artist: 'The Weeknd'),
  MusicTrack(title: 'Tokyo Drift', artist: 'Teriyaki Boyz'),
  MusicTrack(title: 'Starboy', artist: 'The Weeknd'),
  MusicTrack(title: 'After Dark', artist: 'Mr.Kitty'),
];
```

---

### `lib/services/call_simulator_service.dart`

Purpose:

Move call behavior out of `main.dart`.

Expected features:

- Initial idle call state
- Simulate incoming call
- Accept incoming call
- Reject incoming call
- End active call

Expected sample simulated caller:

```dart
callerName: 'Praneeth'
callerNumber: '+91 98765 43210'
```

---

## Current UI Behavior

The main HUD screen currently includes:

- Top status bar
  - App title
  - Phone connected chip
  - GPS connected chip
  - Time chip
- Main dashboard panel
  - Large speed display
  - Trip distance
  - Heading
  - GPS coordinates
- Right-side music card
  - Current song
  - Artist
  - Play/pause status
  - Volume percentage
- Keyboard controls help card
- Navigation placeholder screen
- Documents placeholder screen
- Settings placeholder screen
- Incoming call / active call overlay

---

## Expected Screens

### Dashboard Screen

Shows:

- Current speed
- Trip distance
- Heading
- GPS coordinates

### Navigation Screen

Currently a mock screen.

Expected placeholder text:

- `Turn right in 450 m`
- `Destination: Home`

### Documents Screen

Currently a mock screen.

Expected document entries:

- Registration Certificate
- Driving Licence
- Insurance
- PUC Certificate

Future requirement:

- Store documents securely.
- Encrypt files.
- Lock access behind PIN/biometric flow.

### Settings Screen

Currently a mock screen.

Expected settings:

- Theme: Dark
- Units: km/h
- Button Mode: Media + Calls
- Navigation Provider: Mock

---

## Main.dart Responsibilities Right Now

`main.dart` may still contain most UI widgets and screen classes.

Current responsibility split:

- `main.dart`
  - App startup
  - Main stateful screen
  - Keyboard listener
  - Calls services
  - Renders UI
- `models/`
  - App state and typed data
- `services/`
  - GPS simulation
  - Keyboard-to-handlebar action mapping
  - Music simulation
  - Call simulation

Codex should not immediately over-refactor unless asked. First ensure the app compiles and behaves correctly.

---

## Validation Checklist for Codex

Run:

```bash
flutter analyze
flutter run -d windows
```

Then verify:

| Test | Expected Result |
|---|---|
| App launches | Dark bike HUD appears |
| Speed changes | Speed updates every second |
| Trip changes | Trip distance increases |
| GPS data changes | Coordinates and heading update |
| `Space` | Toggles play/pause |
| `Right arrow` | Next track |
| `Left arrow` | Previous track |
| `Up arrow` | Volume increases |
| `Down arrow` | Volume decreases |
| `C` | Incoming call overlay appears |
| `Enter` | Incoming call becomes active |
| `Esc` during incoming call | Rejects call |
| `Esc` during active call | Ends call |
| `N` | Opens navigation screen |
| `D` | Opens documents screen |
| `S` | Opens settings screen |
| `H` | Returns to home dashboard |

---

## Known / Likely Compile Issues to Watch For

Codex should check for these common issues after the recent refactors:

1. Duplicate `HudScreen` enum still present in `main.dart`.
2. Old state variables still referenced, such as:
   - `incomingCall`
   - `isPlaying`
   - `volume`
   - `currentTrackIndex`
   - `tracks`
3. Old music map access still present:

```dart
currentTrack['title']
```

Should now be:

```dart
currentTrack.title
```

4. Missing import for:

```dart
import 'models/call_state.dart';
```

5. `HudAppState` now requires `musicState`, so this will fail:

```dart
HudAppState hudState = const HudAppState();
```

Expected instead:

```dart
late HudAppState hudState;
```

And initialize in `initState()`:

```dart
hudState = HudAppState(
  musicState: _musicSimulatorService.initialState(),
  callState: _callSimulatorService.initialState(),
);
```

---

## Immediate Next Engineering Task

The next feature after call simulation should be a **Navigation Simulator Service**.

Suggested files:

```text
lib/models/navigation_state.dart
lib/services/navigation_simulator_service.dart
```

Suggested navigation state fields:

```dart
class NavigationState {
  final bool isNavigating;
  final String destinationName;
  final String nextInstruction;
  final double distanceToNextTurnMeters;
  final double distanceToDestinationKm;
  final int etaMinutes;
}
```

Suggested simulated instructions:

```text
Turn right in 450 m
Continue straight for 1.2 km
Take the next left
At the roundabout, take the second exit
Destination in 3.4 km
```

The navigation screen should stop being static and should read from `NavigationState`.

---

## Recommended Near-Term Refactor After Navigation

After navigation simulation works, split UI out of `main.dart`.

Suggested structure:

```text
lib/
 ├─ main.dart
 ├─ screens/
 │   └─ hud_home_screen.dart
 ├─ widgets/
 │   ├─ hud_card.dart
 │   ├─ top_status_bar.dart
 │   ├─ dashboard_panel.dart
 │   ├─ music_card.dart
 │   ├─ controls_help_card.dart
 │   ├─ incoming_call_overlay.dart
 │   ├─ navigation_panel.dart
 │   ├─ documents_panel.dart
 │   └─ settings_panel.dart
```

Do this only after the current service-based behavior is verified.

---

## Product Direction

This is intentionally not an Android Auto clone right now.

The current direction is:

```text
Phone = intelligence, internet, music, calls, maps
HUD = display, controls, GPS speed, ride UI, documents
ESP32 later = physical buttons and bike-side input
```

The alpha is a PC simulator for a future bike-native dashboard.

---

## Future Hardware Integration Plan

Not required yet, but the expected future hardware direction is:

- 5–7 inch touchscreen
- Raspberry Pi / Android SBC / old Android tablet as temporary screen
- ESP32 for buttons
- USB/UART GPS module
- 12V bike battery to 5V regulated power
- Waterproof enclosure
- Handlebar mount
- Later: phone companion app

Do not start hardware integration until the desktop alpha is stable.

---

## Codex Instruction

First priority:

1. Inspect the current Flutter project.
2. Compare actual files against this handoff.
3. Fix any compile errors caused by the recent refactors.
4. Preserve all currently working behavior.
5. Run `flutter analyze` and fix basic issues.
6. Run `flutter run -d windows` or ensure Windows target remains valid.

Second priority:

Implement `NavigationSimulatorService` and `NavigationState` without over-refactoring UI yet.

Third priority:

After navigation works, split large UI widgets from `main.dart` into `screens/` and `widgets/`.
