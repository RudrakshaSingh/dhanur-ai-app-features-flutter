import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:dhanur_ai_app_features_flutter/core/types/permission_state.dart';
import 'package:dhanur_ai_app_features_flutter/features/mic_control/application/mic_control_controller.dart';
import 'package:dhanur_ai_app_features_flutter/features/mic_control/domain/microphone_service.dart';

void main() {
  test(
    'MicControlController transitions permission state and handles release flow',
    () async {
      final service = _FakeMicrophoneService(
        checkPermissionState: PermissionState.denied,
        requestPermissionState: PermissionState.granted,
      );
      final controller = MicControlController(microphoneService: service);

      await controller.initialize();
      expect(controller.state.micPermission, PermissionState.denied);

      await controller.toggleMicrophone();
      expect(controller.state.micPermission, PermissionState.granted);
      expect(controller.state.isMicEnabled, isTrue);

      service.emitLevel(55);
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(controller.state.inputLevel, 55);

      await controller.releaseMicrophone();
      expect(controller.state.isMicEnabled, isFalse);
      expect(controller.state.inputLevel, 0);

      controller.dispose();
      await service.dispose();
    },
  );
}

class _FakeMicrophoneService implements MicrophoneService {
  _FakeMicrophoneService({
    required this.checkPermissionState,
    required this.requestPermissionState,
  });

  PermissionState checkPermissionState;
  PermissionState requestPermissionState;
  bool started = false;
  final StreamController<double> _levelController = StreamController.broadcast();

  @override
  Future<PermissionState> checkPermission() async => checkPermissionState;

  @override
  Stream<double> inputLevel() => _levelController.stream;

  void emitLevel(double level) {
    _levelController.add(level);
  }

  @override
  Future<PermissionState> requestPermission() async {
    checkPermissionState = requestPermissionState;
    return requestPermissionState;
  }

  @override
  Future<void> startCapture() async {
    started = true;
  }

  @override
  Future<void> stopCapture() async {
    started = false;
    _levelController.add(0);
  }

  @override
  Future<void> dispose() async {
    await _levelController.close();
  }
}

