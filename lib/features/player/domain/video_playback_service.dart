import 'package:video_player/video_player.dart';

import 'playback_snapshot.dart';

abstract class VideoPlaybackService {
  VideoPlayerController? get controller;

  Future<void> initialize(Uri uri);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration position);
  Future<void> setSpeed(double speed);
  Future<void> skipBy(Duration delta);
  Stream<PlaybackSnapshot> snapshots();
  Future<void> dispose();
}

