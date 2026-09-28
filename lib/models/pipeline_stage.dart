/// The stages a business record moves through, in order, as its profile
/// gets built out.
enum PipelineStage {
  identified,
  detailsCollected,
  dataRetrieval,
  dataCleaned,
  evidenceValidation,
  profileBuilt,
  monitoring,
}

extension PipelineStageX on PipelineStage {
  /// The label shown in the UI for this stage.
  String get label {
    switch (this) {
      case PipelineStage.identified:
        return 'Identified';
      case PipelineStage.detailsCollected:
        return 'Details Collected';
      case PipelineStage.dataRetrieval:
        return 'Data Retrieval';
      case PipelineStage.dataCleaned:
        return 'Data Cleaned';
      case PipelineStage.evidenceValidation:
        return 'Evidence Validation';
      case PipelineStage.profileBuilt:
        return 'Profile Built';
      case PipelineStage.monitoring:
        return 'Monitoring';
    }
  }

  // True for every stage before the profile is finished. Once it reaches
  // profileBuilt or monitoring, we're maintaining it, not building it.
  bool get isBuilt =>
      this == PipelineStage.identified ||
      this == PipelineStage.detailsCollected ||
      this == PipelineStage.dataRetrieval ||
      this == PipelineStage.dataCleaned ||
      this == PipelineStage.evidenceValidation;
}