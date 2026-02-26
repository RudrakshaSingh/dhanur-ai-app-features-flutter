import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/video_player_service.dart';
import '../domain/playback_snapshot.dart';
import '../domain/player_state.dart';
import '../domain/video_playback_service.dart';

const sampleVideoUrl = 'https://d23dyxeqlo5psv.cloudfront.net/big_buck_bunny.mp4';

final videoPlaybackServiceProvider = Provider<VideoPlaybackService>((ref) {
  final service = VideoPlayerService();
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>((ref) {
      final controller = PlayerController(
        videoPlaybackService: ref.read(videoPlaybackServiceProvider),
      );
      ref.onDispose(controller.dispose);
      unawaited(controller.initialize());
      return controller;
    });

class PlayerController extends StateNotifier<PlayerState> {
  PlayerController({
    required VideoPlaybackService videoPlaybackService,
  }) : _videoPlaybackService = videoPlaybackService,
       super(PlayerState.initial());

  final VideoPlaybackService _videoPlaybackService;
  StreamSubscription<PlaybackSnapshot>? _snapshotsSubscription;

  Future<void> initialize() async {
    _snapshotsSubscription ??= _videoPlaybackService
        .snapshots()
        .listen(_onSnapshot);
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    await _videoPlaybackService.initialize(Uri.parse(sampleVideoUrl));
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _videoPlaybackService.pause();
    } else {
      await _videoPlaybackService.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    await _videoPlaybackService.seekTo(position);
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(playbackSpeed: speed);
    await _videoPlaybackService.setSpeed(speed);
  }

  Future<void> skipForward() async {
    await _videoPlaybackService.skipBy(const Duration(seconds: 10));
  }

  Future<void> skipBackward() async {
    await _videoPlaybackService.skipBy(const Duration(seconds: -10));
  }

  void toggleMiniPlayer() {
    state = state.copyWith(isMiniPlayer: !state.isMiniPlayer);
  }

  void _onSnapshot(PlaybackSnapshot snapshot) {
    state = state.copyWith(
      isLoading: !snapshot.isLoaded || snapshot.isBuffering,
      isPlaying: snapshot.isPlaying,
      position: snapshot.position,
      duration: snapshot.duration,
      playbackSpeed: snapshot.playbackSpeed,
      error: snapshot.error,
    );
  }

  @override
  void dispose() {
    _snapshotsSubscription?.cancel();
    super.dispose();
  }
}

