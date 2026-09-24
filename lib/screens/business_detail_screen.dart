import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business_store.dart';
import '../theme/app_colors.dart';
import '../widgets/info_gap_chip.dart';
import '../widgets/pipeline_stage_badge.dart';
import '../widgets/section_card.dart';
import 'evidence_section.dart';

class BusinessDetailScreen extends StatelessWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: BusinessStore.instance,
          builder: (context, _) {
            final business = BusinessStore.instance.getById(businessId);

            if (business == null) {
              return const Center(
                child: Text('Business not found.', style: TextStyle(color: AppColors.textSecondary)),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, business),
                      const SizedBox(height: 30),
                      _buildDataCollectionSection(business),
                      if (business.collectedInfo.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildCleaningSection(business),
                      ],
                      if (business.standardizedInfo != null) ...[
                        const SizedBox(height: 20),
                        _buildMatchingStub(),
                        const SizedBox(height: 20),
                        EvidenceSection(businessId: business.id),
                      ],
                      const SizedBox(height: 25),
                      _buildGapsSection(business),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Business business) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                    ),
                    PipelineStageBadge(stage: business.stage),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${business.sector} · ${business.location} · ${business.yearsOperating} years operating',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCollectionSection(Business business) {
    if (business.dataCollectionMethod == null) {
      return _buildDecisionCard(business);
    }
    if (business.dataCollectionMethod == DataCollectionMethod.automatic) {
      return _buildAutomaticStub(business);
    }
    if (business.collectedInfo.isEmpty) {
      return _RequestInfoForm(businessId: business.id);
    }
    return _buildCollectedInfoCard(business);
  }

  Widget _buildDecisionCard(Business business) {
    return SectionCard(
      title: 'Can Data Be Obtained Automatically?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose how to collect data for this business.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => BusinessStore.instance.chooseAutomaticDataSource(business.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.inkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text('Yes — Connect to Data Source'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => BusinessStore.instance.chooseManualDataSource(business.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.inkBorder),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: const Text('No — Request Information'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAutomaticStub(Business business) {
    return SectionCard(
      title: 'Connect to Data Source / API / Public Record',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.link_off, color: AppColors.textSecondary, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Not connected yet. No registry or public-record API is wired up, '
                  'so this path can\'t retrieve anything right now.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => BusinessStore.instance.resetDataCollectionMethod(business.id),
            child: const Text('Choose a different method'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectedInfoCard(Business business) {
    return SectionCard(
      title: 'Collected Data (Raw)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Retrieved from the business/stakeholder directly, exactly as entered.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ..._buildInfoRows(business.collectedInfo),
        ],
      ),
    );
  }

  List<Widget> _buildInfoRows(Map<String, String> info) {
    return info.entries
        .map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value.isEmpty ? '—' : entry.value,
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  /// "Clean & Standardize Data". Shown once real data has been
  /// collected.
  Widget _buildCleaningSection(Business business) {
    if (business.standardizedInfo == null) {
      return SectionCard(
        title: 'Clean & Standardize Data',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trim whitespace, normalize casing, and standardize formatting '
              'on the data collected above.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => BusinessStore.instance.cleanAndStandardizeData(business.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.inkBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                ),
                child: const Text('Run Cleaning & Standardization'),
              ),
            ),
          ],
        ),
      );
    }

    return SectionCard(
      title: 'Cleaned & Standardized Data',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trimmed and normalized from the raw submission above.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          ..._buildInfoRows(business.standardizedInfo!),
        ],
      ),
    );
  }

  Widget _buildMatchingStub() {
    return SectionCard(
      title: 'Match & Connect Information Across Sources',
      child: const Row(
        children: [
          Icon(Icons.compare_arrows, color: AppColors.textSecondary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Not applicable yet. This business only has one data source — '
              'matching needs at least two to reconcile against each other.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGapsSection(Business business) {
    if (business.informationGaps.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'Still Missing',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: business.informationGaps.map((gap) => InfoGapChip(label: gap)).toList(),
      ),
    );
  }
}

class _RequestInfoForm extends StatefulWidget {
  final String businessId;

  const _RequestInfoForm({required this.businessId});

  @override
  State<_RequestInfoForm> createState() => _RequestInfoFormState();
}

class _RequestInfoFormState extends State<_RequestInfoForm> {
  final registrationController = TextEditingController();
  final addressController = TextEditingController();
  final contactPersonController = TextEditingController();

  @override
  void dispose() {
    registrationController.dispose();
    addressController.dispose();
    contactPersonController.dispose();
    super.dispose();
  }

  void _submit() {
    BusinessStore.instance.submitRequestedInfo(widget.businessId, {
      'Registration Number': registrationController.text.trim(),
      'Official Address': addressController.text.trim(),
      'Contact Person': contactPersonController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Request Information From Business / Stakeholder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _formField('Registration Number', registrationController),
          const SizedBox(height: 14),
          _formField('Official Address', addressController),
          const SizedBox(height: 14),
          _formField('Contact Person', contactPersonController),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 7),
        TextField(controller: controller, style: const TextStyle(color: AppColors.textPrimary)),
      ],
    );
  }
}