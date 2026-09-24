import 'package:flutter/foundation.dart';
import '../models/business.dart';
import '../models/evidence.dart';

class BusinessStore extends ChangeNotifier {
  BusinessStore._internal();
  static final BusinessStore instance = BusinessStore._internal();

  final List<Business> _businesses = [];

  List<Business> get businesses => List.unmodifiable(_businesses);

  void addBusiness(Business business) {
    _businesses.add(business);
    notifyListeners();
  }

  Business? getById(String id) {
    for (final business in _businesses) {
      if (business.id == id) return business;
    }
    return null;
  }

  /// "Can Data Be Obtained Automatically?" -> Yes.
  void chooseAutomaticDataSource(String businessId) {
    getById(businessId)?.chooseAutomaticDataSource();
    notifyListeners();
  }

  /// "Can Data Be Obtained Automatically?" -> No.
  void chooseManualDataSource(String businessId) {
    getById(businessId)?.chooseManualDataSource();
    notifyListeners();
  }

  /// Backs out of the data collection decision, returning to the fork.
  void resetDataCollectionMethod(String businessId) {
    getById(businessId)?.resetDataCollectionMethod();
    notifyListeners();
  }

  /// "Request Information From Business / Stakeholder" -> submitted.
  void submitRequestedInfo(String businessId, Map<String, String> info) {
    getById(businessId)?.submitRequestedInfo(info);
    notifyListeners();
  }

  /// "Clean & Standardize Data".
  void cleanAndStandardizeData(String businessId) {
    getById(businessId)?.cleanAndStandardizeData();
    notifyListeners();
  }

  /// "Is Supporting Evidence Available?" -> No.
  void markEvidenceUnavailable(String businessId) {
    getById(businessId)?.markEvidenceUnavailable();
    notifyListeners();
  }

  /// Backs out of "marked unverified".
  void reconsiderEvidence(String businessId) {
    getById(businessId)?.reconsiderEvidence();
    notifyListeners();
  }

  /// "Is Supporting Evidence Available?" -> Yes, evidence submitted.
  void submitEvidence(String businessId, Evidence evidence) {
    getById(businessId)?.submitEvidence(evidence);
    notifyListeners();
  }

  /// Real result from the webhook — "Does Evidence Agree?" answered.
  void setEvidenceAnalysis(String businessId, EvidenceAnalysis analysis) {
    getById(businessId)?.setEvidenceAnalysis(analysis);
    notifyListeners();
  }

  /// The webhook call failed — surfaced honestly, not silently dropped.
  void setEvidenceAnalysisError(String businessId, String message) {
    getById(businessId)?.setEvidenceAnalysisError(message);
    notifyListeners();
  }

  /// "Flag Conflict / Need Review" -> submit different evidence.
  void clearEvidence(String businessId) {
    getById(businessId)?.clearEvidence();
    notifyListeners();
  }

  int get totalBusinesses => _businesses.length;

  int get informationGapCount =>
      _businesses.fold<int>(0, (sum, b) => sum + b.informationGaps.length);
}