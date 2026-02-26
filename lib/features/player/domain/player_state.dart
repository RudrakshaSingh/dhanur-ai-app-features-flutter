class PlayerState {
  const PlayerState({
    required this.isLoading,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.isMiniPlayer,
    required this.error,
  });

  factory PlayerState.initial() => const PlayerState(
    isLoading: true,
    isPlaying: false,
    position: Duration.zero,
    duration: Duration.zero,
    playbackSpeed: 1,
    isMiniPlayer: false,
    error: null,
  );

  final bool isLoading;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final bool isMiniPlayer;
  final String? error;

  PlayerState copyWith({
    bool? isLoading,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? playbackSpeed,
    bool? isMiniPlayer,
    String? error,
    bool clearError = false,
  }) {
    return PlayerState(
      isLoading: isLoading ?? this.isLoading,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isMiniPlayer: isMiniPlayer ?? this.isMiniPlayer,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

