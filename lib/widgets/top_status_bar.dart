import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import '../models/call_state.dart';
import 'equalizer_bars.dart';

class TopStatusBar extends StatelessWidget {
  final bool phoneConnected;
  final bool gpsConnected;
  final HudTheme theme;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final String timeString;
  final String? musicTitle;
  final String? musicArtist;
  final bool isPlaying;
  final bool showMiniMusic;
  final VoidCallback? onMusicTap;
  final VoidCallback? onPhoneTap;
  final CallState? callState;
  final VoidCallback? onEndCall;
  final int speedLimit;
  final double currentSpeed;

  const TopStatusBar({
    super.key,
    required this.phoneConnected,
    required this.gpsConnected,
    required this.theme,
    required this.themeMode,
    required this.onThemeChanged,
    required this.timeString,
    this.musicTitle,
    this.musicArtist,
    this.isPlaying = false,
    this.showMiniMusic = false,
    this.onMusicTap,
    this.onPhoneTap,
    this.callState,
    this.onEndCall,
    this.speedLimit = 60,
    this.currentSpeed = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOverspeed = currentSpeed > speedLimit;
    final bool hasActiveCall = callState != null && callState!.isActive;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Cluster: GPS + Speed Limit + Active Call / Music Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!hasActiveCall)
                _buildFullGpsChip()
              else
                _buildCompactGpsChip(),
              const SizedBox(width: 8),

              _buildSpeedLimitBadge(isOverspeed),

              if (hasActiveCall) ...[
                const SizedBox(width: 8),
                _buildActiveCallPill(),
              ] else if (showMiniMusic && musicTitle != null && musicTitle!.isNotEmpty) ...[
                const SizedBox(width: 8),
                _buildMiniMusicPill(),
              ],
            ],
          ),

          // Center Cluster: Clock & Ambient Weather
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                  fontFamily: 'Space Grotesk',
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '•',
                style: TextStyle(color: theme.outline, fontSize: 13),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.wb_sunny_rounded,
                size: 14,
                color: theme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '28°C Sunny',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.onSurfaceVariant,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),

          // Right Cluster: Comms, Hardware 12V Aux Power & Theme Toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Helmet Intercom
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
                      Icons.headphones_rounded,
                      size: 13,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Sena 50S',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: theme.onSurfaceVariant,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Phone Battery & Connection
              GestureDetector(
                onTap: onPhoneTap,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: phoneConnected
                            ? theme.primary.withValues(alpha: 0.4)
                            : theme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          size: 13,
                          color: phoneConnected ? theme.primary : theme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          phoneConnected ? '85%' : 'Disconnected',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: phoneConnected ? theme.onSurface : theme.outline,
                            fontFamily: 'Space Grotesk',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 12V AUX Hardware Power Chip
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
                      Icons.bolt_rounded,
                      size: 13,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '12V AUX',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // M3 Theme Toggle Button
              GestureDetector(
                onTap: () {
                  onThemeChanged(
                    themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.wb_sunny_outlined
                          : Icons.nightlight_round_outlined,
                      size: 16,
                      color: theme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullGpsChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            Icons.satellite_alt_rounded,
            size: 13,
            color: gpsConnected ? theme.primary : theme.outline,
          ),
          const SizedBox(width: 5),
          Text(
            'GPS 3D FIX',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
              fontFamily: 'Space Grotesk',
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(12 sats)',
            style: TextStyle(
              fontSize: 9,
              color: theme.outline,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactGpsChip() {
    return Container(
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
            Icons.satellite_alt_rounded,
            size: 13,
            color: gpsConnected ? theme.primary : theme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '3D FIX',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedLimitBadge(bool isOverspeed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isOverspeed ? theme.errorContainer : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isOverspeed ? theme.error : const Color(0xFFBA1A1A),
          width: 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$speedLimit',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isOverspeed ? theme.onErrorContainer : const Color(0xFFBA1A1A),
            fontFamily: 'Space Grotesk',
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMusicPill() {
    return GestureDetector(
      onTap: onMusicTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: theme.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isPlaying
                  ? theme.primary.withValues(alpha: 0.4)
                  : theme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EqualizerBars(isPlaying: isPlaying, theme: theme),
              const SizedBox(width: 6),
              Text(
                musicTitle ?? 'Playing',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: theme.onSurface,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveCallPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.statusGpsOk.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: theme.statusGpsOk,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.phone_in_talk_rounded,
              color: theme.statusGpsOk,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              callState?.callerName.isNotEmpty == true
                  ? callState!.callerName
                  : 'Call Active',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.onSurface,
                fontFamily: 'Space Grotesk',
              ),
            ),
            const SizedBox(width: 6),
            Text(
              callState?.formattedDuration ?? '00:00',
              style: TextStyle(
                fontSize: 11,
                color: theme.statusGpsOk,
                fontWeight: FontWeight.w600,
                fontFamily: 'Space Grotesk',
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onEndCall,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.call_end_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
