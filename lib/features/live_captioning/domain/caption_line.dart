class CaptionLine {
  const CaptionLine({
    required this.text,
    required this.isFinal,
    required this.timestamp,
  });

  final String text;
  final bool isFinal;
  final DateTime timestamp;
}

