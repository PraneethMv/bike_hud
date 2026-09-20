import 'package:flutter/material.dart';

class HudTheme {
  final Color bg;
  final Color card;
  final Color card2;
  final Color line;
  final Color track;
  final Color text;
  final Color textDim;
  final Color textFaint;
  final Color accent;
  final Color accentInk;
  final Color accentDim;
  final List<BoxShadow> shadow;

  const HudTheme({
    required this.bg,
    required this.card,
    required this.card2,
    required this.line,
    required this.track,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.accentInk,
    required this.accentDim,
    required this.shadow,
  });

  static const dark = HudTheme(
    bg: Color(0xFF0B0B0D),
    card: Color(0xFF161619),
    card2: Color(0xFF202024),
    line: Color(0x14FFFFFF), // rgba(255,255,255,0.08)
    track: Color(0x1AFFFFFF), // rgba(255,255,255,0.10)
    text: Color(0xFFF5F5F3),
    textDim: Color(0xFF8C8C93),
    textFaint: Color(0xFF5C5C62),
    accent: Color(0xFF00E5A0),
    accentInk: Color(0xFF052B20),
    accentDim: Color(0x2400E5A0), // rgba(0,229,160,0.14)
    shadow: [
      BoxShadow(
        color: Color(0x73000000), // rgba(0,0,0,0.45)
        blurRadius: 30,
        offset: Offset(0, 10),
      )
    ],
  );

  static const light = HudTheme(
    bg: Color(0xFFE9E8E3),
    card: Color(0xFFFFFFFF),
    card2: Color(0xFFF3F2ED),
    line: Color(0x12000000), // rgba(0,0,0,0.07)
    track: Color(0x1A000000), // rgba(0,0,0,0.10)
    text: Color(0xFF1A1A16),
    textDim: Color(0xFF6C6C63),
    textFaint: Color(0xFFA2A299),
    accent: Color(0xFF00AA7A),
    accentInk: Color(0xFFFFFFFF),
    accentDim: Color(0x2400AA7A), // rgba(0,170,122,0.14)
    shadow: [
      BoxShadow(
        color: Color(0x21000000), // rgba(0,0,0,0.13)
        blurRadius: 22,
        offset: Offset(0, 8),
      )
    ],
  );
}
