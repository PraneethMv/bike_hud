import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/navigation_state.dart';
import '../models/hud_theme.dart';
import 'hud_card.dart';

class DashboardPanel extends StatelessWidget {
  final int speed;
  final double latitude;
  final double longitude;
  final double heading;
  final double tripDistanceKm;
  final NavigationState navigationState;
  final HudTheme theme;
  final VoidCallback? onNavTap;
  final int speedLimit;
  final bool isRideActive;
  final int rideDurationSeconds;
  final double rideDistanceKm;
  final int rideAvgSpeed;
  final int rideMaxSpeed;
  final VoidCallback? onStartRide;
  final VoidCallback? onEndRide;

  const DashboardPanel({
    super.key,
    required this.speed,
    required this.longitude,
    required this.latitude,
    required this.heading,
    required this.tripDistanceKm,
    required this.navigationState,
    required this.theme,
    this.onNavTap,
    this.speedLimit = 60,
    this.isRideActive = false,
    this.rideDurationSeconds = 0,
    this.rideDistanceKm = 0.0,
    this.rideAvgSpeed = 0,
    this.rideMaxSpeed = 0,
    this.onStartRide,
    this.onEndRide,
  });

  String _getCardinal(double deg) {
    const cardinals = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((deg + 22.5) % 360 ~/ 45);
    return cardinals[idx % 8];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. LEFT CARD: TURN-BY-TURN NAVIGATION PREVIEW (Width: 245px)
        SizedBox(
          width: 245,
          child: _buildNavigationCard(context),
        ),
        const SizedBox(width: 14),

        // 2. CENTER CARD: STANDALONE GPS SPEEDOMETER CLUSTER
        Expanded(
          child: _buildSpeedometerCard(context),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(BuildContext context) {
    final now = DateTime.now();
    final etaTime = now.add(Duration(minutes: navigationState.etaMinutes));
    final String formattedEta =
        "${etaTime.hour.toString().padLeft(2, '0')}:${etaTime.minute.toString().padLeft(2, '0')}";

    return Tooltip(
      message: 'Tap for Full Navigation Screen',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onNavTap,
          borderRadius: BorderRadius.circular(28),
          child: HudCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Google Maps & Android Auto badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: theme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.navigation_rounded,
                              size: 15,
                              color: theme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Google Maps',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: theme.onSurface,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                                Text(
                                  'Android Auto',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: theme.outline,
                                    fontFamily: 'Space Grotesk',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.statusGpsOk.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: theme.statusGpsOk.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: theme.statusGpsOk,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: theme.statusGpsOk,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Big Maneuver Icon & Distance
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: theme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.outlineVariant.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.turn_right_rounded,
                          size: 34,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${navigationState.distanceToNextTurnMeters.toStringAsFixed(0)} m',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Turn right onto',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        '${navigationState.destinationName} Rd',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                ),

                // Then preview pill
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'THEN: ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.outline,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Continue ${(navigationState.distanceToDestinationKm * 0.8).toStringAsFixed(1)} km',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: theme.onSurfaceVariant,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Footer: ETA & Full Map CTA
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: theme.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ETA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: theme.outline,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                            Text(
                              '$formattedEta (${navigationState.etaMinutes}m)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.onSurface,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryContainer.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: theme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Full Map',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: theme.primary,
                                fontFamily: 'Space Grotesk',
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 14,
                              color: theme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedometerCard(BuildContext context) {
    final cardinal = _getCardinal(heading);
    final bool isOverspeed = speed > speedLimit;

    return HudCard(
      theme: theme,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Compass, Altitude, Odometer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Compass & Altitude
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 13,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${heading.round()}° ',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.onSurface,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        Text(
                          cardinal,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: theme.primary,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.terrain_rounded,
                          size: 13,
                          color: theme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '920 m ASL',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: theme.onSurfaceVariant,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Odometer & Trip
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ODOMETER',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.outline,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        '${(18402 + tripDistanceKm).toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Center Arc Speedometer
          Expanded(
            child: Center(
              child: SizedBox(
                width: 250,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(250, 200),
                      painter: M3SpeedometerPainter(
                        speed: speed.toDouble(),
                        maxSpeed: 120,
                        speedLimit: speedLimit.toDouble(),
                        theme: theme,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 14),
                        Text(
                          '$speed',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            color: theme.onSurface,
                            fontFamily: 'Space Grotesk',
                            letterSpacing: -2.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'KM / H',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: theme.outline,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOverspeed ? theme.errorContainer : theme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isOverspeed
                                  ? theme.error.withValues(alpha: 0.4)
                                  : theme.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isOverspeed ? 'LIMIT $speedLimit' : 'GPS SPEED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isOverspeed ? theme.onErrorContainer : theme.onSurfaceVariant,
                              fontFamily: 'Space Grotesk',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Telemetry Area: "Start Ride Capture" or "Current Trip" + "End Ride Capture"
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.outlineVariant.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: !isRideActive
                ? SizedBox(
                    height: 38,
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: onStartRide,
                        icon: Icon(Icons.play_circle_fill_rounded, size: 18, color: theme.onPrimary),
                        label: const Text(
                          'Start Ride Capture',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: theme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header: "Current Trip" with live recording dot & "End Ride Capture" button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Current Trip',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: onEndRide,
                            icon: const Icon(Icons.stop_circle_rounded, size: 14),
                            label: const Text(
                              'End Ride Capture',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Space Grotesk'),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.errorContainer,
                              foregroundColor: theme.error,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              elevation: 0,
                              minimumSize: const Size(0, 26),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          _buildTelemetryPill('TRIP', '${rideDistanceKm.toStringAsFixed(1)} km'),
                          const SizedBox(width: 6),
                          _buildTelemetryPill('TIME', _formatStopwatch(rideDurationSeconds)),
                          const SizedBox(width: 6),
                          _buildTelemetryPill('AVG SPEED', '$rideAvgSpeed km/h'),
                          const SizedBox(width: 6),
                          _buildTelemetryPill('MAX SPEED', '$rideMaxSpeed km/h'),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _formatStopwatch(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    if (totalSeconds >= 3600) {
      final h = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    return '$m:$s';
  }

  Widget _buildTelemetryPill(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: theme.surfaceContainerHigh.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                color: theme.outline,
                fontFamily: 'Space Grotesk',
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class M3SpeedometerPainter extends CustomPainter {
  final double speed;
  final double maxSpeed;
  final double speedLimit;
  final HudTheme theme;

  M3SpeedometerPainter({
    required this.speed,
    required this.maxSpeed,
    required this.speedLimit,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final radius = math.min(size.width, size.height) * 0.44;

    const startAngleDeg = 145.0;
    const totalSweepDeg = 250.0;
    const startAngle = startAngleDeg * math.pi / 180;
    const sweepAngle = totalSweepDeg * math.pi / 180;

    final clampedSpeed = speed.clamp(0.0, maxSpeed);
    final progressSweep = (clampedSpeed / maxSpeed) * sweepAngle;
    final bool isOverspeed = speed > speedLimit;

    // Background track arc
    final trackPaint = Paint()
      ..color = theme.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Active speed progress arc
    if (clampedSpeed > 0) {
      final activePaint = Paint()
        ..color = isOverspeed ? theme.error : theme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        progressSweep,
        false,
        activePaint,
      );
    }

    // Tick marks and labels: 0, 20, 40, 60, 80, 100, 120
    const ticks = [0, 20, 40, 60, 80, 100, 120];
    for (final val in ticks) {
      final angle = (startAngleDeg + (val / maxSpeed) * totalSweepDeg) * math.pi / 180;
      final isMajor = val % 40 == 0;
      final rInner = radius + 7;
      final rOuter = radius + (isMajor ? 13 : 10);

      final p1 = Offset(center.dx + rInner * math.cos(angle), center.dy + rInner * math.sin(angle));
      final p2 = Offset(center.dx + rOuter * math.cos(angle), center.dy + rOuter * math.sin(angle));

      final tickPaint = Paint()
        ..color = isMajor ? theme.outline : theme.outlineVariant
        ..strokeWidth = isMajor ? 2.0 : 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, tickPaint);

      if (isMajor) {
        final rText = radius + 22;
        final pText = Offset(center.dx + rText * math.cos(angle), center.dy + rText * math.sin(angle));

        final tp = TextPainter(
          text: TextSpan(
            text: '$val',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w600,
              color: theme.outline,
              fontFamily: 'Space Grotesk',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(canvas, Offset(pText.dx - tp.width / 2, pText.dy - tp.height / 2));
      }
    }

    // Speed Limit marker line on the arc
    final limitAngle = (startAngleDeg + (speedLimit / maxSpeed) * totalSweepDeg) * math.pi / 180;
    final pLimitInner = Offset(center.dx + (radius - 8) * math.cos(limitAngle), center.dy + (radius - 8) * math.sin(limitAngle));
    final pLimitOuter = Offset(center.dx + (radius + 8) * math.cos(limitAngle), center.dy + (radius + 8) * math.sin(limitAngle));

    final limitPaint = Paint()
      ..color = theme.error
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(pLimitInner, pLimitOuter, limitPaint);
  }

  @override
  bool shouldRepaint(covariant M3SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed ||
        oldDelegate.speedLimit != speedLimit ||
        oldDelegate.theme != theme;
  }
}
