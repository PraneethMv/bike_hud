import 'music_track.dart';

class MusicState {
  final List<MusicTrack> tracks;
  final int currentTrackIndex;
  final bool isPlaying;
  final int volume;

  const MusicState({
    required this.tracks,
    this.currentTrackIndex = 0,
    this.isPlaying = false,
    this.volume = 50,
  });

  MusicTrack get currentTrack => tracks[currentTrackIndex];

  MusicState copyWith({
    List<MusicTrack>? tracks,
    int? currentTrackIndex,
    bool? isPlaying,
    int? volume,
  }) {
    return MusicState(
      tracks: tracks ?? this.tracks,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
    );
  }
}
