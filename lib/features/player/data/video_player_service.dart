import 'dart:async';

import 'package:video_player/video_player.dart';

import '../domain/playback_snapshot.dart';
import '../domain/video_playback_service.dart';

class VideoPlayerService implements VideoPlaybackService {
  VideoPlayerController? _controller;
  void Function()? _controllerListener;
  final StreamController<PlaybackSnapshot> _snapshots =
      StreamController.broadcast();

  @override
  VideoPlayerController? get controller => _controller;

  @override
  Future<void> initialize(Uri uri) async {
    await _disposeControllerOnly();

    final nextController = VideoPlayerController.networkUrl(uri);
    _controller = nextController;
    try {
      await nextController.initialize();
      await nextController.setLooping(true);
      _controllerListener = () => _emitSnapshot();
      nextController.addListener(_controllerListener!);
      _emitSnapshot();
    } catch (error) {
      _snapshots.add(
        PlaybackSnapshot(
          isLoaded: false,
          isBuffering: false,
          isPlaying: false,
          position: Duration.zero,
          duration: Duration.zero,
          playbackSpeed: 1,
          error: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    if (_controller == null) {
      return;
    }
    await _controller!.play();
    _emitSnapshot();
  }

  @override
  Future<void> pause() async {
    if (_controller == null) {
      return;
    }
    await _controller!.pause();
    _emitSnapshot();
  }

  @override
  Future<void> seekTo(Duration position) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final duration = _controller!.value.duration;
    final clamped = Duration(
      milliseconds: position.inMilliseconds.clamp(0, duration.inMilliseconds),
    );
    await _controller!.seekTo(clamped);
    _emitSnapshot();
  }

  @override
  Future<void> setSpeed(double speed) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    await _controller!.setPlaybackSpeed(speed);
    _emitSnapshot();
  }

  @override
  Future<void> skipBy(Duration delta) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    final target = _controller!.value.position + delta;
    await seekTo(target);
  }

  @override
  Stream<PlaybackSnapshot> snapshots() => _snapshots.stream;

  void _emitSnapshot() {
    final currentController = _controller;
    if (currentController == null) {
      return;
    }
    final value = currentController.value;
    _snapshots.add(
      PlaybackSnapshot(
        isLoaded: value.isInitialized,
        isBuffering: value.isBuffering,
        isPlaying: value.isPlaying,
        position: value.position,
        duration: value.duration,
        playbackSpeed: value.playbackSpeed,
        error: value.errorDescription,
      ),
    );
  }

  Future<void> _disposeControllerOnly() async {
    final existing = _controller;
    if (existing == null) {
      return;
    }
    if (_controllerListener != null) {
      existing.removeListener(_controllerListener!);
    }
    await existing.dispose();
    _controllerListener = null;
    _controller = null;
  }

  @override
  Future<void> dispose() async {
    await _disposeControllerOnly();
    await _snapshots.close();
  }
}
