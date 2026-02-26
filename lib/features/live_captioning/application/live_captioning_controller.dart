import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/types/permission_state.dart';
import '../data/speech_to_text_service.dart';
import '../domain/caption_line.dart';
import '../domain/live_captioning_state.dart';
import '../domain/speech_event.dart';
import '../domain/speech_recognition_service.dart';

final speechRecognitionServiceProvider = Provider<SpeechRecognitionService>((ref) {
  final service = SpeechToTextService();
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});

final liveCaptioningControllerProvider =
    StateNotifierProvider<LiveCaptioningController, LiveCaptioningState>((ref) {
      final controller = LiveCaptioningController(
        speechService: ref.read(speechRecognitionServiceProvider),
      );
      ref.onDispose(controller.dispose);
      unawaited(controller.initialize());
      return controller;
    });

class LiveCaptioningController extends StateNotifier<LiveCaptioningState> {
  LiveCaptioningController({
    required SpeechRecognitionService speechService,
  }) : _speechService = speechService,
       super(LiveCaptioningState.initial());

  final SpeechRecognitionService _speechService;
  StreamSubscription<SpeechEvent>? _eventsSubscription;

  Future<void> initialize() async {
    _eventsSubscription ??= _speechService.events().listen(_handleSpeechEvent);

    final permission = await _speechService.checkPermission();
    final available = await _speechService.initialize();
    state = state.copyWith(
      micPermission: permission,
      isAvailable: available,
    );
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
      return;
    }
    await startListening();
  }

  Future<void> startListening() async {
    var permission = state.micPermission;
    if (permission != PermissionState.granted) {
      permission = await _speechService.requestPermission();
      state = state.copyWith(micPermission: permission);
    }

    if (permission != PermissionState.granted) {
      state = state.copyWith(
        error: 'Please grant microphone permission to use live captioning.',
      );
      return;
    }

    if (!state.isAvailable) {
      state = state.copyWith(
        error: 'Speech recognition is not available on this device.',
      );
      return;
    }

    try {
      state = state.copyWith(clearError: true);
      await _speechService.start(
        localeId: 'en_US',
        partialResults: true,
      );
    } catch (_) {
      state = state.copyWith(
        isListening: false,
        error: 'Failed to start speech recognition.',
      );
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechService.stop();
    } catch (_) {
      state = state.copyWith(
        isListening: false,
        error: 'Failed to stop speech recognition cleanly.',
      );
    }
  }

  void clearCaptions() {
    state = state.copyWith(
      finalized: const [],
      interim: '',
      clearError: true,
    );
  }

  void _handleSpeechEvent(SpeechEvent event) {
    switch (event.type) {
      case SpeechEventType.partial:
        state = state.copyWith(interim: event.transcript);
        break;
      case SpeechEventType.finalResult:
        final next = [
          ...state.finalized,
          CaptionLine(
            text: event.transcript,
            isFinal: true,
            timestamp: DateTime.now(),
          ),
        ];
        state = state.copyWith(
          finalized: next,
          interim: '',
        );
        break;
      case SpeechEventType.started:
        state = state.copyWith(
          isListening: true,
          clearError: true,
        );
        break;
      case SpeechEventType.stopped:
        state = state.copyWith(isListening: false);
        break;
      case SpeechEventType.error:
        state = state.copyWith(
          isListening: false,
          error: event.errorMessage ?? 'Speech recognition error.',
        );
        break;
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}

