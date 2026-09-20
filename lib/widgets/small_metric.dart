import 'package:flutter/material.dart';
import '../models/hud_theme.dart';

class SmallMetric extends StatelessWidget {
  final String label;
  final String value;
  final HudTheme theme;

  const SmallMetric({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.card2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textFaint,
                fontFamily: 'Space Grotesk',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.text,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
