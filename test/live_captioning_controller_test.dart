import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dhanur_ai_app_features_flutter/core/types/permission_state.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/application/live_captioning_controller.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/domain/speech_event.dart';
import 'package:dhanur_ai_app_features_flutter/features/live_captioning/domain/speech_recognition_service.dart';

void main() {
  test(
    'LiveCaptioningController appends only final transcript and preserves interim',
    () async {
      final service = _FakeSpeechRecognitionService(
        permission: PermissionState.granted,
        isAvailable: true,
      );
      final controller = LiveCaptioningController(speechService: service);

      await controller.initialize();
      service.emit(SpeechEvent.partial('hello'));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(controller.state.interim, 'hello');
      expect(controller.state.finalized, isEmpty);

      service.emit(SpeechEvent.finalResult('hello world'));
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(controller.state.interim, '');
      expect(controller.state.finalized.length, 1);
      expect(controller.state.finalized.first.text, 'hello world');

      controller.dispose();
      await service.dispose();
    },
  );
}

class _FakeSpeechRecognitionService implements SpeechRecognitionService {
  _FakeSpeechRecognitionService({
    required this.permission,
    required this.isAvailable,
  });

  PermissionState permission;
  bool isAvailable;
  final StreamController<SpeechEvent> _controller = StreamController.broadcast();

  @override
  Future<PermissionState> checkPermission() async => permission;

  @override
  Stream<SpeechEvent> events() => _controller.stream;

  void emit(SpeechEvent event) {
    _controller.add(event);
  }

  @override
  Future<bool> initialize() async => isAvailable;

  @override
  Future<PermissionState> requestPermission() async => permission;

  @override
  Future<void> start({
    required String localeId,
    required bool partialResults,
  }) async {
    _controller.add(SpeechEvent.started());
  }

  @override
  Future<void> stop() async {
    _controller.add(SpeechEvent.stopped());
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

