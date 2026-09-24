import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/evidence.dart';
import '../services/business_store.dart';
import '../services/evidence_analysis_service.dart';
import '../theme/app_colors.dart';
import '../widgets/section_card.dart';

class EvidenceSection extends StatefulWidget {
  final String businessId;

  const EvidenceSection({super.key, required this.businessId});

  @override
  State<EvidenceSection> createState() => _EvidenceSectionState();
}

class _EvidenceSectionState extends State<EvidenceSection> {
  final _descriptionController = TextEditingController();
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  bool _showForm = false;
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _pickedImageName = picked.name;
    });
  }

  Future<void> _submitAndAnalyze() async {
    final store = BusinessStore.instance;
    final business = store.getById(widget.businessId);
    if (business == null) return;

    final evidence = Evidence(
      description: _descriptionController.text.trim(),
      imageBytes: _pickedImageBytes,
      imageName: _pickedImageName,
    );

    store.submitEvidence(widget.businessId, evidence);
    setState(() => _isAnalyzing = true);

    try {
      final analysis = await EvidenceAnalysisService.analyze(business: business, evidence: evidence);
      store.setEvidenceAnalysis(widget.businessId, analysis);
    } catch (e) {
      store.setEvidenceAnalysisError(widget.businessId, e.toString());
    }

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _showForm = false;
        _descriptionController.clear();
        _pickedImageBytes = null;
        _pickedImageName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BusinessStore.instance,
      builder: (context, _) {
        final business = BusinessStore.instance.getById(widget.businessId);
        if (business == null) return const SizedBox.shrink();

        if (business.evidenceMarkedUnavailable) {
          return _buildUnverifiedCard();
        }

        if (business.evidence != null) {
          if (business.evidenceAnalysisError != null) {
            return _buildErrorCard(business.evidenceAnalysisError!);
          }
          if (business.evidence!.analysis != null) {
            return _buildResultCard(business.evidence!.analysis!);
          }
          if (_isAnalyzing) {
            return _buildAnalyzingCard();
          }
        }

        if (_showForm) {
          return _buildForm();
        }

        return _buildDecisionCard();
      },
    );
  }

  Widget _buildDecisionCard() {
    return SectionCard(
      title: 'Is Supporting Evidence Available?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Any proof an AI can review to help determine whether this business is authentic — '
            'a registration document, a utility bill, a photo of the premises, anything like that.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => BusinessStore.instance.markEvidenceUnavailable(widget.businessId),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.inkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text('No — Not Available'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _showForm = true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.inkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text('Yes — Submit Evidence'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnverifiedCard() {
    return SectionCard(
      title: 'Marked as Unverified',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.textSecondary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No supporting evidence was available. This business is recorded as unverified '
                  'until some is provided.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => BusinessStore.instance.reconsiderEvidence(widget.businessId),
            child: const Text('Actually, I have evidence'),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SectionCard(
      title: 'Submit Evidence',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 7),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'e.g. CAC registration certificate, number RC-123456'),
          ),
          const SizedBox(height: 16),
          if (_pickedImageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(_pickedImageBytes!, height: 160, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined, size: 18),
            label: Text(_pickedImageBytes == null ? 'Add Photo' : 'Change Photo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.inkBorder),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_descriptionController.text.trim().isEmpty && _pickedImageBytes == null)
                  ? null
                  : _submitAndAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: const Text('Submit for Validation'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return SectionCard(
      title: 'Validate Evidence',
      child: const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
          ),
          SizedBox(width: 12),
          Text('Analyzing submitted evidence...', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return SectionCard(
      title: 'Evidence Validation Failed',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => setState(() => _showForm = true),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.inkBorder),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(EvidenceAnalysis analysis) {
    final bool agrees = analysis.agrees;
    return SectionCard(
      title: agrees ? 'Evidence Supports This Business' : 'Evidence Conflicts — Needs Review',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                agrees ? Icons.check_circle_outline : Icons.flag_outlined,
                size: 18,
                color: agrees ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence: ${analysis.confidencePercent}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            analysis.reasoning,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          if (!agrees) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => BusinessStore.instance.clearEvidence(widget.businessId),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.inkBorder),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: const Text('Submit Different Evidence'),
            ),
          ],
        ],
      ),
    );
  }
}