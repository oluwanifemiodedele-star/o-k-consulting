import 'package:flutter/foundation.dart';
import '../models/business.dart';
import '../models/evidence.dart';

/// Holds every business in memory and shares them across the app.
///
/// Each method finds the business by id, updates it, then tells listeners.
/// The data is lost when the app closes.
class BusinessStore extends ChangeNotifier {
  BusinessStore._internal();
  static final BusinessStore instance = BusinessStore._internal();

  final List<Business> _businesses = [];

  /// All businesses. The list can't be changed directly, use [addBusiness].
  List<Business> get businesses => List.unmodifiable(_businesses);

  void addBusiness(Business business) {
    _businesses.add(business);
    notifyListeners();
  }

  /// Returns the business with this id, or null if there isn't one.
  Business? getById(String id) {
    for (final business in _businesses) {
      if (business.id == id) return business;
    }
    return null;
  }

  /// Data can be obtained automatically: yes.
  void chooseAutomaticDataSource(String businessId) {
    getById(businessId)?.chooseAutomaticDataSource();
    notifyListeners();
  }

  /// Data can be obtained automatically: no.
  void chooseManualDataSource(String businessId) {
    getById(businessId)?.chooseManualDataSource();
    notifyListeners();
  }

  /// Goes back to the automatic or manual choice.
  void resetDataCollectionMethod(String businessId) {
    getById(businessId)?.resetDataCollectionMethod();
    notifyListeners();
  }

  /// Saves the information requested from the business.
  void submitRequestedInfo(String businessId, Map<String, String> info) {
    getById(businessId)?.submitRequestedInfo(info);
    notifyListeners();
  }

  /// Cleans and standardizes the collected data.
  void cleanAndStandardizeData(String businessId) {
    getById(businessId)?.cleanAndStandardizeData();
    notifyListeners();
  }

  /// Marks the business as unverified because there is no evidence.
  void markEvidenceUnavailable(String businessId) {
    getById(businessId)?.markEvidenceUnavailable();
    notifyListeners();
  }

  /// Undoes "marked unverified".
  void reconsiderEvidence(String businessId) {
    getById(businessId)?.reconsiderEvidence();
    notifyListeners();
  }

  void submitEvidence(String businessId, Evidence evidence) {
    getById(businessId)?.submitEvidence(evidence);
    notifyListeners();
  }

  /// Saves the result that came back from the webhook.
  void setEvidenceAnalysis(String businessId, EvidenceAnalysis analysis) {
    getById(businessId)?.setEvidenceAnalysis(analysis);
    notifyListeners();
  }

  /// Saves the error when the webhook call fails.
  void setEvidenceAnalysisError(String businessId, String message) {
    getById(businessId)?.setEvidenceAnalysisError(message);
    notifyListeners();
  }

  /// Removes the evidence so different evidence can be submitted.
  void clearEvidence(String businessId) {
    getById(businessId)?.clearEvidence();
    notifyListeners();
  }

  int get totalBusinesses => _businesses.length;

  /// Total number of missing items across all businesses.
  int get informationGapCount =>
      _businesses.fold<int>(0, (sum, b) => sum + b.informationGaps.length);
}