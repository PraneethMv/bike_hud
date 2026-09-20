import 'package:flutter_test/flutter_test.dart';
import 'package:bike_hud/models/call_state.dart';
import 'package:bike_hud/services/call_simulator_service.dart';

void main() {
  group('CallState tests', () {
    test('Default CallState is idle with 0 duration', () {
      const state = CallState();
      expect(state.status, CallStatus.idle);
      expect(state.isIdle, isTrue);
      expect(state.isIncoming, isFalse);
      expect(state.isActive, isFalse);
      expect(state.durationSeconds, 0);
      expect(state.formattedDuration, '00:00');
    });

    test('Formatted duration formats mm:ss correctly', () {
      const s1 = CallState(durationSeconds: 5);
      expect(s1.formattedDuration, '00:05');

      const s2 = CallState(durationSeconds: 65);
      expect(s2.formattedDuration, '01:05');

      const s3 = CallState(durationSeconds: 754);
      expect(s3.formattedDuration, '12:34');
    });

    test('CallSimulatorService state transitions', () {
      final service = CallSimulatorService();
      var state = service.initialState();
      expect(state.isIdle, isTrue);

      // Simulate incoming
      state = service.simulateIncomingCall();
      expect(state.isIncoming, isTrue);
      expect(state.callerName, 'Praneeth');

      // Accept call
      state = service.acceptCall(state);
      expect(state.isActive, isTrue);
      expect(state.isIncoming, isFalse);

      // End call
      state = service.endCall(state);
      expect(state.isIdle, isTrue);
    });
  });
}

