class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.isLoaded,
    required this.isBuffering,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    this.error,
  });

  final bool isLoaded;
  final bool isBuffering;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final String? error;
}

