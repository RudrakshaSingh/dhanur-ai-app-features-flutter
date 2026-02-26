import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/types/permission_state.dart';
import '../data/record_microphone_service.dart';
import '../domain/mic_control_state.dart';
import '../domain/microphone_service.dart';

final microphoneServiceProvider = Provider<MicrophoneService>((ref) {
  final service = RecordMicrophoneService();
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

final micControlControllerProvider =
    StateNotifierProvider<MicControlController, MicControlState>((ref) {
      final controller = MicControlController(
        microphoneService: ref.read(microphoneServiceProvider),
      );
      ref.onDispose(controller.dispose);
      unawaited(controller.initialize());
      return controller;
    });

class MicControlController extends StateNotifier<MicControlState> {
  MicControlController({
    required MicrophoneService microphoneService,
  }) : _microphoneService = microphoneService,
       super(MicControlState.initial());

  final MicrophoneService _microphoneService;
  StreamSubscription<double>? _inputLevelSubscription;

  Future<void> initialize() async {
    _inputLevelSubscription ??= _microphoneService.inputLevel().listen((level) {
      state = state.copyWith(inputLevel: level);
    });
    await refreshPermissionStatus();
  }

  Future<void> refreshPermissionStatus() async {
    final permission = await _microphoneService.checkPermission();
    state = state.copyWith(
      micPermission: permission,
      permissionMessage: _permissionMessage(permission),
    );
  }

  Future<void> requestPermission() async {
    final permission = await _microphoneService.requestPermission();
    state = state.copyWith(
      micPermission: permission,
      permissionMessage: _permissionMessage(permission),
    );
  }

  Future<void> toggleMicrophone() async {
    if (state.micPermission != PermissionState.granted) {
      await requestPermission();
      if (state.micPermission != PermissionState.granted) {
        state = state.copyWith(
          error:
              'Microphone access was denied. Enable permission in system settings.',
        );
        return;
      }
    }

    if (state.isMicEnabled) {
      await releaseMicrophone();
      return;
    }
    await enableMicrophone();
  }

  Future<void> enableMicrophone() async {
    try {
      state = state.copyWith(clearError: true);
      await _microphoneService.startCapture();
      state = state.copyWith(
        isMicEnabled: true,
        permissionMessage: _permissionMessage(state.micPermission),
      );
    } catch (_) {
      state = state.copyWith(
        isMicEnabled: false,
        inputLevel: 0,
        error: 'Failed to enable microphone.',
      );
    }
  }

  Future<void> releaseMicrophone() async {
    try {
      await _microphoneService.stopCapture();
    } finally {
      state = state.copyWith(
        isMicEnabled: false,
        inputLevel: 0,
      );
    }
  }

  String _permissionMessage(PermissionState permission) {
    switch (permission) {
      case PermissionState.granted:
        return 'Microphone permission granted';
      case PermissionState.denied:
        return 'Microphone permission denied';
      case PermissionState.permanentlyDenied:
        return 'Permission permanently denied';
      case PermissionState.restricted:
        return 'Permission restricted by system policy';
      case PermissionState.unavailable:
        return 'Microphone permission unavailable';
      case PermissionState.checking:
        return 'Checking...';
    }
  }

  @override
  void dispose() {
    _inputLevelSubscription?.cancel();
    super.dispose();
  }
}

