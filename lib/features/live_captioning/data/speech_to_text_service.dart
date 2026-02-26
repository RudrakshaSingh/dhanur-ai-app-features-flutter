import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/types/permission_state.dart';
import '../../../core/utils/permission_state_mapper.dart';
import '../domain/speech_event.dart';
import '../domain/speech_recognition_service.dart';

class SpeechToTextService implements SpeechRecognitionService {
  SpeechToTextService({
    SpeechToText? speechToText,
  }) : _speech = speechToText ?? SpeechToText();

  final SpeechToText _speech;
  final StreamController<SpeechEvent> _events = StreamController.broadcast();
  bool _initialized = false;
  bool _isListening = false;

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
  Future<bool> initialize() async {
    if (_initialized) {
      return _speech.isAvailable;
    }
    final isAvailable = await _speech.initialize(
      onError: _onError,
      onStatus: _onStatus,
      debugLogging: false,
    );
    _initialized = true;
    if (!isAvailable) {
      _events.add(SpeechEvent.error('Speech recognition is unavailable.'));
    }
    return isAvailable;
  }

  @override
  Stream<SpeechEvent> events() => _events.stream;

  @override
  Future<void> start({
    required String localeId,
    required bool partialResults,
  }) async {
    if (!_initialized) {
      final available = await initialize();
      if (!available) {
        return;
      }
    }
    if (_isListening) {
      return;
    }

    await _speech.listen(
      onResult: _onResult,
      localeId: localeId,
      partialResults: partialResults,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
    _isListening = true;
    _events.add(SpeechEvent.started());
  }

  @override
  Future<void> stop() async {
    if (!_isListening) {
      return;
    }
    await _speech.stop();
    _isListening = false;
    _events.add(SpeechEvent.stopped());
  }

  void _onResult(SpeechRecognitionResult result) {
    final transcript = result.recognizedWords.trim();
    if (transcript.isEmpty) {
      return;
    }
    if (result.finalResult) {
      _events.add(SpeechEvent.finalResult(transcript));
    } else {
      _events.add(SpeechEvent.partial(transcript));
    }
  }

  void _onError(SpeechRecognitionError error) {
    _isListening = false;
    _events.add(SpeechEvent.error(error.errorMsg));
  }

  void _onStatus(String status) {
    if (status == 'listening') {
      _isListening = true;
      _events.add(SpeechEvent.started());
      return;
    }
    if (status == 'notListening' || status == 'done') {
      _isListening = false;
      _events.add(SpeechEvent.stopped());
    }
  }

  @override
  Future<void> dispose() async {
    if (_isListening) {
      await stop();
    }
    await _events.close();
  }
}

