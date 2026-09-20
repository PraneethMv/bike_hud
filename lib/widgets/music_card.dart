import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hud_theme.dart';
import 'hud_card.dart';
import 'equalizer_bars.dart';

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

class _MusicCardState extends State<MusicCard> {
  Timer? _playbackTimer;
  int _positionSeconds = 84; // Initial simulated position (1:24)
  final int _durationSeconds = 220; // 3:40

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MusicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      // Reset position on track change
      setState(() {
        _positionSeconds = 0;
      });
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
                Icon(
                  Icons.phone_android_rounded,
                  size: 14,
                  color: widget.theme.textFaint,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PHONE NOT CONNECTED',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: widget.theme.textDim,
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
                      color: widget.theme.card2,
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.theme.line),
                    ),
                    child: Icon(
                      Icons.phonelink_erase_rounded,
                      size: 24,
                      color: widget.theme.textFaint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Music Source',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.text,
                      fontFamily: 'Space Grotesk',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Connect your phone to show\nNow Playing and media controls',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.theme.textDim,
                      fontFamily: 'Space Grotesk',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: widget.onConnectTap,
                    icon: const Icon(Icons.bluetooth_rounded, size: 16),
                    label: const Text(
                      'Connect Phone',
                      style: TextStyle(fontSize: 12, fontFamily: 'Space Grotesk'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.theme.accent,
                      side: BorderSide(
                        color: widget.theme.accent.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

    final double progress = (_positionSeconds / _durationSeconds).clamp(0.0, 1.0);

    return HudCard(
      theme: widget.theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              EqualizerBars(isPlaying: widget.isPlaying, theme: widget.theme),
              const SizedBox(width: 8),
              Text(
                'NOW PLAYING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: widget.theme.textDim,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Album art thumbnail
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.theme.card2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: widget.theme.line),
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    color: widget.theme.accent,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.text,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.theme.textDim,
                        fontFamily: 'Space Grotesk',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress Bar
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.theme.track,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.theme.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTime(_positionSeconds),
                style: TextStyle(
                  color: widget.theme.textFaint,
                  fontSize: 11,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              Text(
                _formatTime(_durationSeconds),
                style: TextStyle(
                  color: widget.theme.textFaint,
                  fontSize: 11,
                  fontFamily: 'Space Grotesk',
                ),
              ),
            ],
          ),
          const Spacer(),
          // Media Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 24),
                onPressed: widget.onPrevious,
                color: widget.theme.text,
              ),
              const SizedBox(width: 8),
              // Big circular Play/Pause button
              GestureDetector(
                onTap: widget.onPlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.theme.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.theme.accentDim,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 24,
                    color: widget.theme.accentInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 24),
                onPressed: widget.onNext,
                color: widget.theme.text,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Volume Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_down_rounded, size: 20),
                onPressed: widget.onVolumeDown,
                color: widget.theme.textDim,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
              const SizedBox(width: 8),
              Text(
                'Volume: ${widget.volume}%',
                style: TextStyle(
                  color: widget.theme.textFaint,
                  fontSize: 12,
                  fontFamily: 'Space Grotesk',
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                onPressed: widget.onVolumeUp,
                color: widget.theme.textDim,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
