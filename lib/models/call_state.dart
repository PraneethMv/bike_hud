enum CallStatus {
  idle,
  incoming,
  active,
}

class CallState {
  final CallStatus status;
  final String callerName;
  final String callerNumber;
  final int durationSeconds;

  const CallState({
    this.status = CallStatus.idle,
    this.callerName = '',
    this.callerNumber = '',
    this.durationSeconds = 0,
  });

  bool get isIncoming => status == CallStatus.incoming;
  bool get isActive => status == CallStatus.active;
  bool get isIdle => status == CallStatus.idle;

  String get formattedDuration {
    final min = durationSeconds ~/ 60;
    final sec = durationSeconds % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  CallState copyWith({
    CallStatus? status,
    String? callerName,
    String? callerNumber,
    int? durationSeconds,
  }) {
    return CallState(
      status: status ?? this.status,
      callerName: callerName ?? this.callerName,
      callerNumber: callerNumber ?? this.callerNumber,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}