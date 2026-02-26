import '../../../core/types/permission_state.dart';
import 'speech_event.dart';

abstract class SpeechRecognitionService {
  Future<PermissionState> checkPermission();
  Future<PermissionState> requestPermission();
  Future<bool> initialize();
  Stream<SpeechEvent> events();
  Future<void> start({
    required String localeId,
    required bool partialResults,
  });
  Future<void> stop();
  Future<void> dispose();
}

