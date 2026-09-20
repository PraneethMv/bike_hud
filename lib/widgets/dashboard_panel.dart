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
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation Card (Width: 236px)
        _buildNavigationCard(context),
        const SizedBox(width: 16),
        // Speedometer Hero (Flexible center)
        Expanded(
          child: _buildSpeedometerHero(context),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(BuildContext context) {
    final now = DateTime.now();
    final etaTime = now.add(Duration(minutes: navigationState.etaMinutes));
    final String formattedEta =
        "${etaTime.hour.toString().padLeft(2, '0')}:${etaTime.minute.toString().padLeft(2, '0')}";

    return SizedBox(
      width: 236,
      child: Tooltip(
        message: 'Open Navigation',
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
            Row(
              children: [
                _PulsingDot(color: theme.accent),
                const SizedBox(width: 8),
                Text(
                  'NAVIGATING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.textDim,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.turn_right,
                  size: 46,
                  color: theme.accent,
                ),
                const SizedBox(width: 14),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Space Grotesk',
                      color: theme.text,
                    ),
                    children: [
                      TextSpan(
                        text: navigationState.distanceToNextTurnMeters.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.8,
                        ),
                      ),
                      TextSpan(
                        text: ' m',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: theme.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Turn right',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: theme.text,
                fontFamily: 'Space Grotesk',
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'onto ${navigationState.destinationName} Road',
              style: TextStyle(
                fontSize: 14,
                color: theme.textDim,
                fontFamily: 'Space Grotesk',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'then continue ${(navigationState.distanceToDestinationKm * 0.85).toStringAsFixed(1)} km',
              style: TextStyle(
                fontSize: 13,
                color: theme.textFaint,
                fontFamily: 'Space Grotesk',
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.line),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    formattedEta,
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '·',
                      style: TextStyle(color: theme.textDim.withValues(alpha: 0.4)),
                    ),
                  ),
                  Text(
                    '${navigationState.etaMinutes} min',
                    style: TextStyle(
                      color: theme.textDim,
                      fontSize: 13,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '·',
                      style: TextStyle(color: theme.textDim.withValues(alpha: 0.4)),
                    ),
                  ),
                  Text(
                    '${navigationState.distanceToDestinationKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: theme.textDim,
                      fontSize: 13,
                      fontFamily: 'Space Grotesk',
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
),
);
  }

  Widget _buildSpeedometerHero(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: SpeedometerPainter(
                    speed: speed.toDouble(),
                    theme: theme,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$speed',
                    style: TextStyle(
                      fontSize: 98,
                      fontWeight: FontWeight.bold,
                      height: 0.9,
                      color: theme.text,
                      fontFamily: 'Space Grotesk',
                      letterSpacing: -2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'KM / H',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: theme.textDim,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 60,
                bottom: 14,
                child: Text(
                  '0',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textFaint,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
              Positioned(
                right: 52,
                bottom: 14,
                child: Text(
                  '180',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textFaint,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 13,
                  color: theme.textDim,
                ),
                children: [
                  TextSpan(
                    text: 'TRIP ',
                    style: TextStyle(
                      color: theme.textFaint,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: '${tripDistanceKm.toStringAsFixed(1)} km',
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildMetricDivider(),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 13,
                  color: theme.textDim,
                ),
                children: [
                  TextSpan(
                    text: 'AVG ',
                    style: TextStyle(
                      color: theme.textFaint,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: '64',
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildMetricDivider(),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 13,
                  color: theme.textDim,
                ),
                children: [
                  TextSpan(
                    text: 'ODO ',
                    style: TextStyle(
                      color: theme.textFaint,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: '18,402',
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 14,
      color: theme.line,
      margin: const EdgeInsets.symmetric(horizontal: 14),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.25, end: 1.0).animate(_controller),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SpeedometerPainter extends CustomPainter {
  final double speed;
  final HudTheme theme;

  SpeedometerPainter({required this.speed, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 108.0;

    final trackPaint = Paint()
      ..color = theme.track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = theme.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    const startAngle = 3 * math.pi / 4;
    const totalSweepAngle = 3 * math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweepAngle,
      false,
      trackPaint,
    );

    final double sweep = (speed / 180.0).clamp(0.0, 1.0) * totalSweepAngle;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.speed != speed || oldDelegate.theme != theme;
  }
}
