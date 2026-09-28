import 'evidence.dart';
import 'pipeline_stage.dart';

/// How the business's data was collected — automatically from a source,
/// or typed in manually.
enum DataCollectionMethod {
  automatic,
  manual,
}

/// Tracks one business as it moves through the pipeline, from initial
/// details to a finished, monitored profile. Most methods here just move
/// the business into its next state and update [stage] to match.
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

  // Stays null until cleanAndStandardizeData() runs, even if collectedInfo
  // already has data in it.
  Map<String, String>? standardizedInfo;

  bool evidenceMarkedUnavailable;

  Evidence? evidence;

  // Only set if the analysis request itself fails. A missing analysis
  // result on its own doesn't mean an error happened.
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

  /// Sets the data collection method to automatic.
  void chooseAutomaticDataSource() {
    dataCollectionMethod = DataCollectionMethod.automatic;
  }

  /// Sets the data collection method to manual.
  void chooseManualDataSource() {
    dataCollectionMethod = DataCollectionMethod.manual;
  }

  /// Clears the chosen data collection method so the user can pick again.
  void resetDataCollectionMethod() {
    dataCollectionMethod = null;
  }

  /// Saves manually submitted data and moves the business into the data
  /// retrieval stage. Clears any previous cleaned data since it no longer
  /// matches.
  void submitRequestedInfo(Map<String, String> info) {
    dataCollectionMethod = DataCollectionMethod.manual;
    collectedInfo = info;
    stage = PipelineStage.dataRetrieval;
    standardizedInfo = null;
  }

  /// Trims and normalizes [collectedInfo] into [standardizedInfo], then
  /// moves the business into the cleaned stage. Does nothing if there's no
  /// data yet.
  void cleanAndStandardizeData() {
    if (collectedInfo.isEmpty) return;

    final cleaned = <String, String>{};
    collectedInfo.forEach((key, rawValue) {
      final trimmed = rawValue.trim();
      switch (key) {
        // Registration numbers get typed inconsistently, so strip spaces
        // and force uppercase to keep them comparable later.
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

  /// Marks that no supporting evidence exists for this business.
  void markEvidenceUnavailable() {
    evidenceMarkedUnavailable = true;
    evidence = null;
    evidenceAnalysisError = null;
    stage = PipelineStage.evidenceValidation;
  }

  /// Undoes [markEvidenceUnavailable] if the user decides evidence can be
  /// found after all.
  void reconsiderEvidence() {
    evidenceMarkedUnavailable = false;
  }

  /// Saves newly submitted evidence and clears any previous error.
  void submitEvidence(Evidence newEvidence) {
    evidenceMarkedUnavailable = false;
    evidence = newEvidence;
    evidenceAnalysisError = null;
  }

  /// Attaches a completed analysis result to the current evidence.
  void setEvidenceAnalysis(EvidenceAnalysis analysis) {
    evidence?.analysis = analysis;
    evidenceAnalysisError = null;
    stage = PipelineStage.evidenceValidation;
  }

  /// Records that the analysis request failed, with a message to show.
  void setEvidenceAnalysisError(String message) {
    evidenceAnalysisError = message;
  }

  /// Removes the current evidence so different evidence can be submitted.
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
      // Automatic collection isn't built yet, so this will always be a gap.
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

    // Only one data source exists right now, so this will always show
    // until multi-source matching is built.
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

/// Capitalizes the first letter of each word. Doesn't handle names like
/// "McDonald" or "O'Brien" correctly.
String _toTitleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(' ')
      .map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}