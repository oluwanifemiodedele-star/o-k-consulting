import 'dart:typed_data';

class Evidence {
  final String description;
  final Uint8List? imageBytes;
  final String? imageName;
  final DateTime submittedAt;

  EvidenceAnalysis? analysis;

  Evidence({
    required this.description,
    this.imageBytes,
    this.imageName,
    DateTime? submittedAt,
    this.analysis,
  }) : submittedAt = submittedAt ?? DateTime.now();
}

class EvidenceAnalysis {
  final bool agrees;
  final int confidencePercent;
  final String reasoning;
  final DateTime analyzedAt;

  EvidenceAnalysis({
    required this.agrees,
    required this.confidencePercent,
    required this.reasoning,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();
}