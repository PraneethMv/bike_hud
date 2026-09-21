import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Minimalist vector speedometer icon and "RevHUD" branding lockup
/// designed to match Material 3 automotive aesthetic.
class RevHudLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color primaryColor;
  final bool showText;

  const RevHudLogo({
    super.key,
    this.iconSize = 72,
    this.fontSize = 48,
    this.primaryColor = const Color(0xFF4C8DF6), // Material 3 Accent Blue
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget icon = SizedBox(
      width: iconSize,
      height: iconSize * 0.85,
      child: CustomPaint(
        painter: _SpeedometerVectorPainter(accentColor: primaryColor),
      ),
    );

    if (!showText) {
      return icon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        SizedBox(width: iconSize * 0.22),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Rev',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'HUD',
                style: TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Precision minimalist speedometer painter matching the modern automotive gauge.
class _SpeedometerVectorPainter extends CustomPainter {
  final Color accentColor;

  _SpeedometerVectorPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.48, size.height * 0.80);
    final radius = size.width * 0.44;

    // Gauge geometry: starts from lower-left (200 deg) to lower-right (-20 deg)
    const startAngle = 195 * (math.pi / 180);
    const totalSweep = 210 * (math.pi / 180);
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final strokeWidth = radius * 0.16;

    // 1. Inactive/Base Arc (Muted dark slate grey)
    const baseSweepRatio = 0.68;
    final baseSweep = totalSweep * baseSweepRatio;
    final baseArcPaint = Paint()
      ..color = const Color(0xFF4A5568)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, startAngle, baseSweep, false, baseArcPaint);

    // 2. Active Zone Arc (Accent Blue)
    const activeStartRatio = 0.74;
    final activeStartAngle = startAngle + (totalSweep * activeStartRatio);
    final activeSweep = totalSweep * (1.0 - activeStartRatio);
    final activeArcPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, activeStartAngle, activeSweep, false, activeArcPaint);

    // 3. Inner Tick Marks (Subtle radial ticks along the base arc)
    const tickCount = 5;
    final tickInner = radius * 0.62;
    final tickOuter = radius * 0.78;

    for (int i = 0; i < tickCount; i++) {
      final tickAngle = startAngle + (baseSweep * (i / (tickCount - 1)));
      final p1 = Offset(
        center.dx + tickInner * math.cos(tickAngle),
        center.dy + tickInner * math.sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + tickOuter * math.cos(tickAngle),
        center.dy + tickOuter * math.sin(tickAngle),
      );

      final tickPaint = Paint()
        ..color = const Color(0xFF718096)
        ..strokeWidth = radius * 0.045
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 4. White Speedometer Needle pointing up-right (~45 deg)
    const needleAngle = -42 * (math.pi / 180);
    final needleLength = radius * 0.82;
    final needleTip = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    // Clean white needle line
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = radius * 0.085
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    // 5. Center Hub (Solid White circle)
    final hubPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.18, hubPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeedometerVectorPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
