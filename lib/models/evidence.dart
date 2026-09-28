import 'dart:typed_data';

// One piece of supporting evidence a business submits — a description plus
// an optional photo/document. `analysis` stays null until it's actually
// been run through validation.
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

// Result of validating a piece of evidence against the business's collected
// data — did it actually back up what they claimed, and how sure are we.
class EvidenceAnalysis {
  // True if the evidence supports the collected data, false if it conflicts.
  final bool agrees;

  // 0-100 — how confident the analysis is in that agrees/conflicts call.
  final int confidencePercent;

  // Plain-language explanation for the result, meant to be shown directly
  // to whoever's reviewing it, not just logged internally.
  final String reasoning;

  final DateTime analyzedAt;

  EvidenceAnalysis({
    required this.agrees,
    required this.confidencePercent,
    required this.reasoning,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();
}