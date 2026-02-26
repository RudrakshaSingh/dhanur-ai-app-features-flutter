enum SpeechEventType {
  partial,
  finalResult,
  started,
  stopped,
  error,
}

class SpeechEvent {
  const SpeechEvent({
    required this.type,
    this.transcript = '',
    this.errorMessage,
  });

  factory SpeechEvent.partial(String transcript) => SpeechEvent(
    type: SpeechEventType.partial,
    transcript: transcript,
  );

  factory SpeechEvent.finalResult(String transcript) => SpeechEvent(
    type: SpeechEventType.finalResult,
    transcript: transcript,
  );

  factory SpeechEvent.started() => const SpeechEvent(type: SpeechEventType.started);

  factory SpeechEvent.stopped() => const SpeechEvent(type: SpeechEventType.stopped);

  factory SpeechEvent.error(String message) => SpeechEvent(
    type: SpeechEventType.error,
    errorMessage: message,
  );

  final SpeechEventType type;
  final String transcript;
  final String? errorMessage;
}

