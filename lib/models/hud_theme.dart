import 'package:flutter/material.dart';

class HudTheme {
  // Material 3 Surface Hierarchy
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  // Material 3 On-Surface Typography & Content
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;

  // Material 3 Accent / Primary
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  // Secondary & Tertiary
  final Color secondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;

  // Error / Alert
  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;

  // Status & Telemetry specific
  final Color statusGpsOk;
  final Color track;
  final List<BoxShadow> shadow;

  // Backward-compatibility getters for existing widgets
  Color get bg => surface;
  Color get card => surfaceContainer;
  Color get card2 => surfaceContainerHigh;
  Color get line => outlineVariant.withValues(alpha: 0.35);
  Color get text => onSurface;
  Color get textDim => onSurfaceVariant;
  Color get textFaint => outline;
  Color get accent => primary;
  Color get accentInk => onPrimary;
  Color get accentDim => primaryContainer.withValues(alpha: 0.35);

  const HudTheme({
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.statusGpsOk,
    required this.track,
    required this.shadow,
  });

  /// Material 3 Dark (Night / Automotive Default)
  static const dark = HudTheme(
    surface: Color(0xFF111318),
    surfaceContainerLowest: Color(0xFF0C0E12),
    surfaceContainerLow: Color(0xFF191C20),
    surfaceContainer: Color(0xFF1D2024),
    surfaceContainerHigh: Color(0xFF272A2F),
    surfaceContainerHighest: Color(0xFF32353A),
    onSurface: Color(0xFFE1E2E8),
    onSurfaceVariant: Color(0xFFC3C6CF),
    outline: Color(0xFF8D9199),
    outlineVariant: Color(0xFF43474E),
    primary: Color(0xFFA8C7FA),
    onPrimary: Color(0xFF062E6F),
    primaryContainer: Color(0xFF0842A0),
    onPrimaryContainer: Color(0xFFD3E3FD),
    secondary: Color(0xFFBEC6DC),
    secondaryContainer: Color(0xFF3E4758),
    onSecondaryContainer: Color(0xFFDAE2F9),
    tertiary: Color(0xFFD7BEE4),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    statusGpsOk: Color(0xFF00E5A0),
    track: Color(0x1FFFFFFF),
    shadow: [
      BoxShadow(
        color: Color(0x66000000),
        blurRadius: 24,
        offset: Offset(0, 8),
      )
    ],
  );

  /// Material 3 Light Mode (Day / Direct Sunlight)
  static const light = HudTheme(
    surface: Color(0xFFF8F9FF),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF2F3FA),
    surfaceContainer: Color(0xFFECEEF4),
    surfaceContainerHigh: Color(0xFFE6E8EE),
    surfaceContainerHighest: Color(0xFFE0E2E8),
    onSurface: Color(0xFF191C20),
    onSurfaceVariant: Color(0xFF43474E),
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C7CF),
    primary: Color(0xFF0B57D0),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD3E3FD),
    onPrimaryContainer: Color(0xFF041E49),
    secondary: Color(0xFF565F71),
    secondaryContainer: Color(0xFFDAE2F9),
    onSecondaryContainer: Color(0xFF131C2B),
    tertiary: Color(0xFF705575),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    statusGpsOk: Color(0xFF00B37A),
    track: Color(0x14000000),
    shadow: [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      )
    ],
  );

  HudTheme withAccent(String colorSeed, {bool isDark = true}) {
    Color newPrimary;
    Color newOnPrimary;
    Color newPrimaryContainer;
    Color newOnPrimaryContainer;
    Color newSecondary;
    Color newSecondaryContainer;
    Color newOnSecondaryContainer;

    if (isDark) {
      switch (colorSeed) {
        case 'emerald':
          newPrimary = const Color(0xFF6CDBAC);
          newOnPrimary = const Color(0xFF003824);
          newPrimaryContainer = const Color(0xFF005136);
          newOnPrimaryContainer = const Color(0xFF89F8C7);
          newSecondary = const Color(0xFFB4CCBD);
          newSecondaryContainer = const Color(0xFF354B3E);
          newOnSecondaryContainer = const Color(0xFFD0E8D9);
          break;
        case 'amber':
          newPrimary = const Color(0xFFFFB951);
          newOnPrimary = const Color(0xFF452B00);
          newPrimaryContainer = const Color(0xFF633F00);
          newOnPrimaryContainer = const Color(0xFFFFDDB3);
          newSecondary = const Color(0xFFDDC2A1);
          newSecondaryContainer = const Color(0xFF54442A);
          newOnSecondaryContainer = const Color(0xFFFADEBD);
          break;
        case 'purple':
          newPrimary = const Color(0xFFD2BCFF);
          newOnPrimary = const Color(0xFF381E72);
          newPrimaryContainer = const Color(0xFF4F378B);
          newOnPrimaryContainer = const Color(0xFFEADDFF);
          newSecondary = const Color(0xFFCBC2DB);
          newSecondaryContainer = const Color(0xFF4A4458);
          newOnSecondaryContainer = const Color(0xFFE8DEF8);
          break;
        case 'blue':
        default:
          newPrimary = const Color(0xFFA8C7FA);
          newOnPrimary = const Color(0xFF062E6F);
          newPrimaryContainer = const Color(0xFF0842A0);
          newOnPrimaryContainer = const Color(0xFFD3E3FD);
          newSecondary = const Color(0xFFBEC6DC);
          newSecondaryContainer = const Color(0xFF3E4758);
          newOnSecondaryContainer = const Color(0xFFDAE2F9);
          break;
      }
    } else {
      switch (colorSeed) {
        case 'emerald':
          newPrimary = const Color(0xFF006C49);
          newOnPrimary = const Color(0xFFFFFFFF);
          newPrimaryContainer = const Color(0xFF89F8C7);
          newOnPrimaryContainer = const Color(0xFF002114);
          newSecondary = const Color(0xFF4D6354);
          newSecondaryContainer = const Color(0xFFD0E8D9);
          newOnSecondaryContainer = const Color(0xFF0A1F14);
          break;
        case 'amber':
          newPrimary = const Color(0xFF835500);
          newOnPrimary = const Color(0xFFFFFFFF);
          newPrimaryContainer = const Color(0xFFFFDDB3);
          newOnPrimaryContainer = const Color(0xFF2A1800);
          newSecondary = const Color(0xFF6C5C40);
          newSecondaryContainer = const Color(0xFFF6E0BB);
          newOnSecondaryContainer = const Color(0xFF251A04);
          break;
        case 'purple':
          newPrimary = const Color(0xFF6750A4);
          newOnPrimary = const Color(0xFFFFFFFF);
          newPrimaryContainer = const Color(0xFFEADDFF);
          newOnPrimaryContainer = const Color(0xFF21005D);
          newSecondary = const Color(0xFF625B71);
          newSecondaryContainer = const Color(0xFFE8DEF8);
          newOnSecondaryContainer = const Color(0xFF1D192B);
          break;
        case 'blue':
        default:
          newPrimary = const Color(0xFF0B57D0);
          newOnPrimary = const Color(0xFFFFFFFF);
          newPrimaryContainer = const Color(0xFFD3E3FD);
          newOnPrimaryContainer = const Color(0xFF041E49);
          newSecondary = const Color(0xFF565F71);
          newSecondaryContainer = const Color(0xFFDAE2F9);
          newOnSecondaryContainer = const Color(0xFF131C2B);
          break;
      }
    }

    return HudTheme(
      surface: surface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      primary: newPrimary,
      onPrimary: newOnPrimary,
      primaryContainer: newPrimaryContainer,
      onPrimaryContainer: newOnPrimaryContainer,
      secondary: newSecondary,
      secondaryContainer: newSecondaryContainer,
      onSecondaryContainer: newOnSecondaryContainer,
      tertiary: tertiary,
      error: error,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      statusGpsOk: statusGpsOk,
      track: track,
      shadow: shadow,
    );
  }
}
