class NavigationState {
  final bool isNavigating;
  final String destinationName;
  final String nextInstruction;
  final double distanceToNextTurnMeters;
  final double distanceToDestinationKm;
  final int etaMinutes;

  const NavigationState({
    this.isNavigating = true,
    this.destinationName = 'Home',
    this.nextInstruction = 'Turn right in 450 m',
    this.distanceToNextTurnMeters = 450,
    this.distanceToDestinationKm = 3.4,
    this.etaMinutes = 12,
  });

  NavigationState copyWith({
    bool? isNavigating,
    String? destinationName,
    String? nextInstruction,
    double? distanceToNextTurnMeters,
    double? distanceToDestinationKm,
    int? etaMinutes,
  }) {
    return NavigationState(
      isNavigating: isNavigating ?? this.isNavigating,
      destinationName: destinationName ?? this.destinationName,
      nextInstruction: nextInstruction ?? this.nextInstruction,
      distanceToNextTurnMeters:
          distanceToNextTurnMeters ?? this.distanceToNextTurnMeters,
      distanceToDestinationKm:
          distanceToDestinationKm ?? this.distanceToDestinationKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }
}
