enum CallStatus { idle, incoming, active }

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
