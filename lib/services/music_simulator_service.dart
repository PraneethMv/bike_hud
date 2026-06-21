import '../models/music_state.dart';
import '../models/music_track.dart';

class MusicSimulatorService {
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

  MusicState togglePlayPause(MusicState state) {
    return state.copyWith(isPlaying: !state.isPlaying);
  }

  MusicState nextTrack(MusicState state) {
    return state.copyWith(
      currentTrackIndex: (state.currentTrackIndex + 1) % state.tracks.length,
    );
  }

  MusicState previousTrack(MusicState state) {
    return state.copyWith(
      currentTrackIndex:
          (state.currentTrackIndex - 1 + state.tracks.length) %
          state.tracks.length,
    );
  }

  MusicState volumeUp(MusicState state) {
    return state.copyWith(volume: (state.volume + 5).clamp(0, 100).toInt());
  }

  MusicState volumeDown(MusicState state) {
    return state.copyWith(volume: (state.volume - 5).clamp(0, 100).toInt());
  }
}
