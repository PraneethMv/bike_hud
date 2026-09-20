import 'package:flutter/material.dart';
import '../models/navigation_state.dart';
import '../models/hud_theme.dart';
import 'hud_card.dart';
import 'small_metric.dart';

class NavigationPanel extends StatelessWidget {
  final NavigationState navigationState;
  final HudTheme theme;

  const NavigationPanel({
    super.key,
    required this.navigationState,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return HudCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NAVIGATION',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: theme.text,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 30),
          Icon(Icons.turn_right, size: 80, color: theme.accent),
          const SizedBox(height: 16),
          Text(
            navigationState.nextInstruction,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: theme.text,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Destination: ${navigationState.destinationName}',
            style: TextStyle(
              fontSize: 20,
              color: theme.textDim,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SmallMetric(
                label: 'Next turn',
                value: '${navigationState.distanceToNextTurnMeters.toStringAsFixed(0)} m',
                theme: theme,
              ),
              const SizedBox(width: 12),
              SmallMetric(
                label: 'Remaining',
                value: '${navigationState.distanceToDestinationKm.toStringAsFixed(1)} km',
                theme: theme,
              ),
              const SizedBox(width: 12),
              SmallMetric(
                label: 'ETA',
                value: '${navigationState.etaMinutes} min',
                theme: theme,
              ),
            ],
          ),
          const Spacer(),
          Text(
            'Map screen will come later. For alpha, this is a simulated route.',
            style: TextStyle(
              color: theme.textFaint,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }
}
