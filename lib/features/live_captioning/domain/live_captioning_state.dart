import '../../../core/types/permission_state.dart';
import 'caption_line.dart';

class LiveCaptioningState {
  const LiveCaptioningState({
    required this.isListening,
    required this.finalized,
    required this.interim,
    required this.micPermission,
    required this.error,
    required this.isAvailable,
  });

  factory LiveCaptioningState.initial() => const LiveCaptioningState(
    isListening: false,
    finalized: [],
    interim: '',
    micPermission: PermissionState.checking,
    error: null,
    isAvailable: true,
  );

  final bool isListening;
  final List<CaptionLine> finalized;
  final String interim;
  final PermissionState micPermission;
  final String? error;
  final bool isAvailable;

  bool get hasTranscript => finalized.isNotEmpty || interim.trim().isNotEmpty;

  LiveCaptioningState copyWith({
    bool? isListening,
    List<CaptionLine>? finalized,
    String? interim,
    PermissionState? micPermission,
    String? error,
    bool clearError = false,
    bool? isAvailable,
  }) {
    return LiveCaptioningState(
      isListening: isListening ?? this.isListening,
      finalized: finalized ?? this.finalized,
      interim: interim ?? this.interim,
      micPermission: micPermission ?? this.micPermission,
      error: clearError ? null : (error ?? this.error),
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

