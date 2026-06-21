import 'dart:async';

import '../models/navigation_state.dart';

class NavigationSimulatorService {
  static const List<String> _instructions = [
    'Turn right in 450 m',
    'Continue straight for 1.2 km',
    'Take the next left',
    'At the roundabout, take the second exit',
    'Destination in 3.4 km',
  ];

  Timer? _timer;
  int _instructionIndex = 0;
  double _distanceToNextTurnMeters = 450;
  double _distanceToDestinationKm = 3.4;
  int _etaMinutes = 12;

  NavigationState initialState() {
    return NavigationState(
      nextInstruction: _instructions[_instructionIndex],
      distanceToNextTurnMeters: _distanceToNextTurnMeters,
      distanceToDestinationKm: _distanceToDestinationKm,
      etaMinutes: _etaMinutes,
    );
  }

  void start({required void Function(NavigationState state) onData}) {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      _distanceToNextTurnMeters -= 45;
      _distanceToDestinationKm = (_distanceToDestinationKm - 0.08)
          .clamp(0, 99)
          .toDouble();

      if (_distanceToNextTurnMeters <= 0) {
        _instructionIndex = (_instructionIndex + 1) % _instructions.length;
        _distanceToNextTurnMeters = 450 + (_instructionIndex * 180);
      }

      _etaMinutes = (_distanceToDestinationKm * 3.5).ceil().clamp(1, 99);

      onData(
        NavigationState(
          destinationName: 'Home',
          nextInstruction: _instructions[_instructionIndex],
          distanceToNextTurnMeters: _distanceToNextTurnMeters,
          distanceToDestinationKm: _distanceToDestinationKm,
          etaMinutes: _etaMinutes,
        ),
      );
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
