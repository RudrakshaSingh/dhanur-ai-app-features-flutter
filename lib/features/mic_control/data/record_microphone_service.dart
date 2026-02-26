import 'dart:async';
import 'dart:typed_data';

import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/types/permission_state.dart';
import '../../../core/utils/permission_state_mapper.dart';
import '../domain/microphone_service.dart';

class RecordMicrophoneService implements MicrophoneService {
  RecordMicrophoneService({
    AudioRecorder? recorder,
  }) : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  final StreamController<double> _inputLevelStream = StreamController.broadcast();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<Uint8List>? _captureStreamSubscription;
  bool _isCapturing = false;

  @override
  Future<PermissionState> checkPermission() async {
    final status = await Permission.microphone.status;
    return mapPermissionStatus(status);
  }

  @override
  Future<PermissionState> requestPermission() async {
    final status = await Permission.microphone.request();
    return mapPermissionStatus(status);
  }

  @override
  Future<void> startCapture() async {
    if (_isCapturing) {
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw StateError('Microphone permission is not granted.');
    }

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
      ),
    );
    _captureStreamSubscription = stream.listen((_) {});
    _amplitudeSubscription = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amplitude) {
          final normalized = (((amplitude.current + 160) / 160) * 100)
              .clamp(0, 100)
              .toDouble();
          _inputLevelStream.add(normalized);
        });
    _isCapturing = true;
  }

  @override
  Future<void> stopCapture() async {
    if (!_isCapturing) {
      return;
    }
    await _amplitudeSubscription?.cancel();
    await _captureStreamSubscription?.cancel();
    _amplitudeSubscription = null;
    _captureStreamSubscription = null;
    await _recorder.stop();
    _isCapturing = false;
    _inputLevelStream.add(0);
  }

  @override
  Stream<double> inputLevel() => _inputLevelStream.stream;

  @override
  Future<void> dispose() async {
    await stopCapture();
    await _recorder.dispose();
    await _inputLevelStream.close();
  }
}

