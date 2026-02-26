import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';

import 'package:dhanur_ai_app_features_flutter/features/player/application/player_controller.dart';
import 'package:dhanur_ai_app_features_flutter/features/player/domain/playback_snapshot.dart';
import 'package:dhanur_ai_app_features_flutter/features/player/domain/video_playback_service.dart';

void main() {
  test('PlayerController updates speed and forwards seek/skip operations', () async {
    final service = _FakeVideoPlaybackService();
    final controller = PlayerController(videoPlaybackService: service);

    await controller.initialize();
    service.emit(
      const PlaybackSnapshot(
        isLoaded: true,
        isBuffering: false,
        isPlaying: false,
        position: Duration(seconds: 5),
        duration: Duration(seconds: 120),
        playbackSpeed: 1,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 1));

    await controller.setSpeed(1.5);
    expect(controller.state.playbackSpeed, 1.5);
    expect(service.speedValues.last, 1.5);

    await controller.seekTo(const Duration(seconds: 30));
    expect(service.seekTargets.last, const Duration(seconds: 30));

    await controller.skipForward();
    await controller.skipBackward();
    expect(
      service.skipDeltas,
      const [Duration(seconds: 10), Duration(seconds: -10)],
    );

    controller.dispose();
    await service.dispose();
  });
}

class _FakeVideoPlaybackService implements VideoPlaybackService {
  final StreamController<PlaybackSnapshot> _controller = StreamController.broadcast();
  final List<Duration> seekTargets = [];
  final List<Duration> skipDeltas = [];
  final List<double> speedValues = [];

  @override
  VideoPlayerController? get controller => null;

  @override
  Future<void> initialize(Uri uri) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seekTo(Duration position) async {
    seekTargets.add(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    speedValues.add(speed);
  }

  @override
  Future<void> skipBy(Duration delta) async {
    skipDeltas.add(delta);
  }

  @override
  Stream<PlaybackSnapshot> snapshots() => _controller.stream;

  void emit(PlaybackSnapshot snapshot) {
    _controller.add(snapshot);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

