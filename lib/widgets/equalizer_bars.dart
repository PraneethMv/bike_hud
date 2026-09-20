import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/hud_theme.dart';

class EqualizerBars extends StatefulWidget {
  final bool isPlaying;
  final HudTheme theme;

  const EqualizerBars({
    super.key,
    required this.isPlaying,
    required this.theme,
  });

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(0),
            const SizedBox(width: 2),
            _buildBar(1),
            const SizedBox(width: 2),
            _buildBar(2),
          ],
        );
      },
    );
  }

  Widget _buildBar(int index) {
    double value = 0.35;
    if (widget.isPlaying) {
      final phase = index * (math.pi / 3);
      value = 0.35 + 0.65 * (math.sin(_controller.value * 2 * math.pi + phase).abs());
    }
    return Container(
      width: 3,
      height: 12 * value,
      decoration: BoxDecoration(
        color: widget.theme.accent,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
