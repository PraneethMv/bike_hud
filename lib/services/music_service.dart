import 'package:flutter/services.dart';
import '../models/music_state.dart';
import '../models/music_track.dart';

class MusicService {
  static const _channel = MethodChannel('bike_hud/music');

  static const List<MusicTrack> defaultTracks = [
    MusicTrack(title: 'Blinding Lights', artist: 'The Weeknd'),
    MusicTrack(title: 'Tokyo Drift', artist: 'Teriyaki Boyz'),
    MusicTrack(title: 'Starboy', artist: 'The Weeknd'),
    MusicTrack(title: 'After Dark', artist: 'Mr.Kitty'),
  ];

  MusicState initialState() {
    return const MusicState(
      tracks: defaultTracks,
      currentTrackIndex: 0,
      isPlaying: false,
      volume: 50,
    );
  }

  Future<bool> hasNotificationAccess() async {
    try {
      final bool hasAccess = await _channel.invokeMethod('hasNotificationAccess');
      return hasAccess;
    } catch (e) {
      return true; // Assume true on other platforms (e.g. Windows) to bypass permission screen
    }
  }

  Future<void> requestNotificationAccess() async {
    try {
      await _channel.invokeMethod('requestNotificationAccess');
    } catch (_) {}
  }

  Future<MusicState> syncWithSystem(MusicState state) async {
    try {
      final Map<dynamic, dynamic>? result = await _channel.invokeMethod('getMediaInfo');
      if (result != null && result['success'] == true) {
        final String title = result['title'] ?? '';
        final String artist = result['artist'] ?? '';
        final bool isPlaying = result['isPlaying'] ?? false;

        if (title.isNotEmpty) {
          final track = MusicTrack(title: title, artist: artist);
          return state.copyWith(
            tracks: [track],
            currentTrackIndex: 0,
            isPlaying: isPlaying,
          );
        }
      }
    } catch (_) {}
    return state;
  }

  Future<MusicState> togglePlayPause(MusicState state) async {
    try {
      if (state.isPlaying) {
        await _channel.invokeMethod('pause');
      } else {
        await _channel.invokeMethod('play');
      }
      return state.copyWith(isPlaying: !state.isPlaying);
    } catch (_) {
      // Fallback to simulation
      return state.copyWith(isPlaying: !state.isPlaying);
    }
  }

  Future<MusicState> nextTrack(MusicState state) async {
    try {
      await _channel.invokeMethod('next');
      return state;
    } catch (_) {
      // Fallback to simulation
      return state.copyWith(
        currentTrackIndex: (state.currentTrackIndex + 1) % state.tracks.length,
      );
    }
  }

  Future<MusicState> previousTrack(MusicState state) async {
    try {
      await _channel.invokeMethod('previous');
      return state;
    } catch (_) {
      // Fallback to simulation
      return state.copyWith(
        currentTrackIndex:
            (state.currentTrackIndex - 1 + state.tracks.length) %
            state.tracks.length,
      );
    }
  }

  MusicState volumeUp(MusicState state) {
    return state.copyWith(volume: (state.volume + 5).clamp(0, 100).toInt());
  }

  MusicState volumeDown(MusicState state) {
    return state.copyWith(volume: (state.volume - 5).clamp(0, 100).toInt());
  }
}
