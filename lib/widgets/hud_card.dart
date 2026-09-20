import 'package:flutter/material.dart';
import '../models/hud_theme.dart';

class HudCard extends StatelessWidget {
  final Widget child;
  final HudTheme theme;
  final EdgeInsetsGeometry? padding;

  const HudCard({
    super.key,
    required this.child,
    required this.theme,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.line),
        boxShadow: theme.shadow,
      ),
      child: child,
    );
  }
}
