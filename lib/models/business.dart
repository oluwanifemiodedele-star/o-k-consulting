import 'evidence.dart';
import 'pipeline_stage.dart';

enum DataCollectionMethod {
  automatic,
  manual,
}


class Business {
  final String id;
  final String name;
  final String businessType;
  final String sector;
  final String location;
  final int yearsOperating;
  final DateTime createdAt;

  PipelineStage stage;

  DataCollectionMethod? dataCollectionMethod;

  Map<String, String> collectedInfo;

  Map<String, String>? standardizedInfo;

  bool evidenceMarkedUnavailable;

  Evidence? evidence;

  String? evidenceAnalysisError;

  Business({
    required this.name,
    required this.businessType,
    required this.sector,
    required this.location,
    required this.yearsOperating,
    String? id,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        stage = PipelineStage.detailsCollected,
        dataCollectionMethod = null,
        collectedInfo = {},
        standardizedInfo = null,
        evidenceMarkedUnavailable = false,
        evidence = null,
        evidenceAnalysisError = null;

  void chooseAutomaticDataSource() {
    dataCollectionMethod = DataCollectionMethod.automatic;
  }

  void chooseManualDataSource() {
    dataCollectionMethod = DataCollectionMethod.manual;
  }

  void resetDataCollectionMethod() {
    dataCollectionMethod = null;
  }

  /// "Request Information From Business / Stakeholder" -> submitted.
  void submitRequestedInfo(Map<String, String> info) {
    dataCollectionMethod = DataCollectionMethod.manual;
    collectedInfo = info;
    stage = PipelineStage.dataRetrieval;
    standardizedInfo = null; // new raw data invalidates any prior cleaning
  }

  /// "Clean & Standardize Data".
  void cleanAndStandardizeData() {
    if (collectedInfo.isEmpty) return;

    final cleaned = <String, String>{};
    collectedInfo.forEach((key, rawValue) {
      final trimmed = rawValue.trim();
      switch (key) {
        case 'Registration Number':
          cleaned[key] = trimmed.toUpperCase().replaceAll(RegExp(r'\s+'), '');
          break;
        case 'Contact Person':
          cleaned[key] = _toTitleCase(trimmed);
          break;
        default:
          cleaned[key] = trimmed;
      }
    });

    standardizedInfo = cleaned;
    stage = PipelineStage.dataCleaned;
  }

  void markEvidenceUnavailable() {
    evidenceMarkedUnavailable = true;
    evidence = null;
    evidenceAnalysisError = null;
    stage = PipelineStage.evidenceValidation;
  }

  void reconsiderEvidence() {
    evidenceMarkedUnavailable = false;
  }

  void submitEvidence(Evidence newEvidence) {
    evidenceMarkedUnavailable = false;
    evidence = newEvidence;
    evidenceAnalysisError = null;
  }

  void setEvidenceAnalysis(EvidenceAnalysis analysis) {
    evidence?.analysis = analysis;
    evidenceAnalysisError = null;
    stage = PipelineStage.evidenceValidation;
  }

  void setEvidenceAnalysisError(String message) {
    evidenceAnalysisError = message;
  }

  void clearEvidence() {
    evidence = null;
    evidenceAnalysisError = null;
  }

  List<String> get informationGaps {
    final gaps = <String>[];

    if (dataCollectionMethod == null) {
      gaps.add('Data collection method not yet chosen');
      return gaps;
    }

    if (dataCollectionMethod == DataCollectionMethod.automatic) {
      gaps.add('Automated data source connection not yet built');
      return gaps;
    }

    if (collectedInfo.isEmpty) {
      gaps.add('Information request not yet submitted');
      return gaps;
    }

    if (standardizedInfo == null) {
      gaps.add('Data not yet cleaned and standardized');
      return gaps;
    }

    gaps.add('Only one data source connected — nothing to match across sources yet');

    if (evidenceMarkedUnavailable) {
      gaps.add('Marked unverified — no supporting evidence available');
    } else if (evidence == null) {
      gaps.add('Supporting evidence not yet collected');
    } else if (evidenceAnalysisError != null) {
      gaps.add('Evidence validation failed — retry needed');
    } else if (evidence!.analysis == null) {
      gaps.add('Evidence submitted — validation pending');
    } else if (!evidence!.analysis!.agrees) {
      gaps.add('Evidence conflicts with collected data — needs review');
    } else {
      gaps.add('Business profile not yet finalized');
    }

    return gaps;
  }
}

String _toTitleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(' ')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}