import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import 'hud_card.dart';

class MusicCard extends StatefulWidget {
  final String title;
  final String artist;
  final bool isPlaying;
  final int volume;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onVolumeUp;
  final VoidCallback onVolumeDown;
  final HudTheme theme;
  final bool phoneConnected;
  final VoidCallback? onConnectTap;

  const MusicCard({
    super.key,
    required this.title,
    required this.artist,
    required this.isPlaying,
    required this.volume,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onVolumeUp,
    required this.onVolumeDown,
    required this.theme,
    this.phoneConnected = true,
    this.onConnectTap,
  });

  @override
  State<MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> with SingleTickerProviderStateMixin {
  Timer? _playbackTimer;
  int _positionSeconds = 84;
  final int _durationSeconds = 220;
  late AnimationController _discAnimController;

  @override
  void initState() {
    super.initState();
    _discAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isPlaying && widget.phoneConnected) {
      _discAnimController.repeat();
    }
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MusicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      setState(() {
        _positionSeconds = 0;
      });
    }
    if (widget.isPlaying && widget.phoneConnected) {
      if (!_discAnimController.isAnimating) {
        _discAnimController.repeat();
      }
    } else {
      if (_discAnimController.isAnimating) {
        _discAnimController.stop();
      }
    }
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    if (widget.phoneConnected && widget.isPlaying && _playbackTimer == null) {
      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _positionSeconds = (_positionSeconds + 1) % _durationSeconds;
          });
        }
      });
    } else if ((!widget.isPlaying || !widget.phoneConnected) && _playbackTimer != null) {
      _playbackTimer?.cancel();
      _playbackTimer = null;
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _discAnimController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.phoneConnected) {
      return HudCard(
        theme: widget.theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: widget.theme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phonelink_erase_rounded,
                    size: 14,
                    color: widget.theme.outline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PHONE NOT CONNECTED',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: widget.theme.onSurfaceVariant,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.theme.surfaceContainerHigh,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.theme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.music_off_rounded,
                      size: 24,
                      color: widget.theme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Audio Source',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.onSurface,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Connect phone to show Now Playing & audio controls',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.theme.onSurfaceVariant,
                        fontFamily: 'Space Grotesk',
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (widget.onConnectTap != null)
                    GestureDetector(
                      onTap: widget.onConnectTap,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: widget.theme.primaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: widget.theme.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings_bluetooth_rounded,
                                size: 14,
                                color: widget.theme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pair Phone',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.primary,
                                  fontFamily: 'Space Grotesk',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      );
    }

    return HudCard(
      theme: widget.theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Now Playing & Bluetooth source badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: widget.theme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.radio_rounded,
                      size: 15,
                      color: widget.theme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Now Playing',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.onSurface,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                      Text(
                        'Bluetooth Intercom',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: widget.theme.onSurfaceVariant,
                          fontFamily: 'Space Grotesk',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: widget.theme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Spotify',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.primary,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),

          // Center: Album Art with rotating vinyl badge
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: widget.theme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: widget.theme.outlineVariant.withValues(alpha: 0.35),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.album_rounded,
                        size: 42,
                        color: widget.theme.primary,
                      ),
                    ),
                    if (widget.isPlaying)
                      RotationTransition(
                        turns: _discAnimController,
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: widget.theme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: widget.theme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.motion_photos_on_rounded,
                            size: 13,
                            color: widget.theme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.onSurface,
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                Text(
                  widget.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: widget.theme.onSurfaceVariant,
                    fontFamily: 'Space Grotesk',
                  ),
                ),

                // M3 Progress Bar
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _positionSeconds / _durationSeconds,
                    minHeight: 4,
                    backgroundColor: widget.theme.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.theme.primary),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_positionSeconds),
                      style: TextStyle(
                        fontSize: 9.5,
                        color: widget.theme.outline,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    Text(
                      _formatTime(_durationSeconds),
                      style: TextStyle(
                        fontSize: 9.5,
                        color: widget.theme.outline,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),

          // Media Controls (Previous, Play/Pause FAB Pill, Next)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMediaButton(
                icon: Icons.skip_previous_rounded,
                onTap: widget.onPrevious,
                isFab: false,
              ),
              _buildMediaButton(
                icon: widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                onTap: widget.onPlayPause,
                isFab: true,
              ),
              _buildMediaButton(
                icon: Icons.skip_next_rounded,
                onTap: widget.onNext,
                isFab: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isFab,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isFab ? 48 : 36,
          height: isFab ? 36 : 36,
          decoration: BoxDecoration(
            color: isFab
                ? widget.theme.primary
                : widget.theme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isFab
                  ? Colors.transparent
                  : widget.theme.outlineVariant.withValues(alpha: 0.3),
            ),
            boxShadow: isFab
                ? [
                    BoxShadow(
                      color: widget.theme.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              size: isFab ? 22 : 18,
              color: isFab
                  ? widget.theme.onPrimary
                  : widget.theme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
