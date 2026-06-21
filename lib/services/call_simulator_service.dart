import '../models/call_state.dart';

class CallSimulatorService {
  CallState initialState() {
    return const CallState();
  }

  CallState simulateIncomingCall() {
    return const CallState(
      status: CallStatus.incoming,
      callerName: 'Praneeth',
      callerNumber: '+91 98765 43210',
    );
  }

  CallState acceptCall(CallState state) {
    if (!state.isIncoming) {
      return state;
    }

    return state.copyWith(status: CallStatus.active);
  }

  CallState rejectCall(CallState state) {
    if (!state.isIncoming && !state.isActive) {
      return state;
    }

    return const CallState();
  }

  CallState endCall(CallState state) {
    if (!state.isActive) {
      return state;
    }

    return const CallState();
  }
}
