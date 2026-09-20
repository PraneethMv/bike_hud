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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          // Left: Weather info
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.wb_sunny_rounded,
                  color: theme.accent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '18°',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.text,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                if ((callState == null || !callState!.isActive) &&
                    (!showMiniMusic || musicTitle == null || musicTitle!.isEmpty)) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Clear · feels 16°',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.textDim,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ],
                if (callState != null && callState!.isActive) ...[
                  const SizedBox(width: 14),
                  Flexible(
                    child: _buildActiveCallPill(),
                  ),
                ] else if (showMiniMusic && musicTitle != null && musicTitle!.isNotEmpty) ...[
                  const SizedBox(width: 14),
                  Flexible(
                    child: _buildMiniMusicPill(),
                  ),
                ],
              ],
            ),
          ),
          
          // Center: Large Clock
          Text(
            timeString,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: theme.text,
              fontFamily: 'Space Grotesk',
              letterSpacing: -0.5,
            ),
          ),

          // Right: Status chips, Notifications, Theme switcher
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Phone connection chip
                Tooltip(
                  message: phoneConnected
                      ? 'Phone Connected'
                      : 'Phone Disconnected (Tap for Settings)',
                  child: GestureDetector(
                    onTap: onPhoneTap,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: _buildStatusIcon(
                        phoneConnected ? Icons.phone_android : Icons.phone_android,
                        phoneConnected ? theme.accent : theme.textFaint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // GPS connection chip
                _buildStatusIcon(
                  Icons.gps_fixed,
                  gpsConnected ? theme.accent : theme.textFaint,
                ),
                const SizedBox(width: 14),
                // Notification bell
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: theme.text,
                      size: 22,
                    ),
                    Positioned(
                      top: -4,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: theme.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: theme.accentInk,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Day/Night Segment Switcher
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: theme.line),
                  ),
                  child: Row(
                    children: [
                      _buildThemeSegmentButton(
                        ThemeMode.light,
                        Icons.wb_sunny_rounded,
                      ),
                      _buildThemeSegmentButton(
                        ThemeMode.dark,
                        Icons.mode_night_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, Color color) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: theme.card,
        shape: BoxShape.circle,
        border: Border.all(color: theme.line),
      ),
      child: Center(
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildThemeSegmentButton(ThemeMode targetMode, IconData icon) {
    final bool isSelected = themeMode == targetMode;
    return GestureDetector(
      onTap: () => onThemeChanged(targetMode),
      child: Container(
        width: 34,
        height: 26,
        decoration: BoxDecoration(
          color: isSelected ? theme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 14,
          color: isSelected ? theme.accentInk : theme.textDim,
        ),
      ),
    );
  }

  Widget _buildMiniMusicPill() {
    return GestureDetector(
      onTap: onMusicTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying
                ? theme.accent.withValues(alpha: 0.35)
                : theme.line,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EqualizerBars(
              isPlaying: isPlaying,
              theme: theme,
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Space Grotesk',
                    fontSize: 12,
                    color: theme.text,
                  ),
                  children: [
                    TextSpan(
                      text: musicTitle ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if ((musicArtist ?? '').isNotEmpty) ...[
                      TextSpan(
                        text: ' · $musicArtist',
                        style: TextStyle(color: theme.textDim),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCallPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E5A0).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5A0).withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00E5A0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.phone_in_talk_rounded,
            color: Color(0xFF00E5A0),
            size: 15,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              callState?.callerName.isNotEmpty == true
                  ? callState!.callerName
                  : 'Call Active',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.text,
                fontFamily: 'Space Grotesk',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            callState?.formattedDuration ?? '00:00',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF00E5A0),
              fontWeight: FontWeight.w600,
              fontFamily: 'Space Grotesk',
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: 'End Call',
            child: GestureDetector(
              onTap: onEndCall,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE53935),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
