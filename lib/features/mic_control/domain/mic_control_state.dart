import '../../../core/types/permission_state.dart';

class MicControlState {
  const MicControlState({
    required this.micPermission,
    required this.isMicEnabled,
    required this.inputLevel,
    required this.permissionMessage,
    required this.error,
  });

  factory MicControlState.initial() => const MicControlState(
    micPermission: PermissionState.checking,
    isMicEnabled: false,
    inputLevel: 0,
    permissionMessage: 'Checking...',
    error: null,
  );

  final PermissionState micPermission;
  final bool isMicEnabled;
  final double inputLevel;
  final String permissionMessage;
  final String? error;

  MicControlState copyWith({
    PermissionState? micPermission,
    bool? isMicEnabled,
    double? inputLevel,
    String? permissionMessage,
    String? error,
    bool clearError = false,
  }) {
    return MicControlState(
      micPermission: micPermission ?? this.micPermission,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      inputLevel: inputLevel ?? this.inputLevel,
      permissionMessage: permissionMessage ?? this.permissionMessage,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

