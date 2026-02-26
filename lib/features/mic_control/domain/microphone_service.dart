import '../../../core/types/permission_state.dart';

abstract class MicrophoneService {
  Future<PermissionState> checkPermission();
  Future<PermissionState> requestPermission();
  Future<void> startCapture();
  Future<void> stopCapture();
  Stream<double> inputLevel();
  Future<void> dispose();
}

