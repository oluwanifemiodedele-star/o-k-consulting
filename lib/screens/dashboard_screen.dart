import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business_store.dart';
import '../theme/app_colors.dart';
import '../widgets/pipeline_stage_badge.dart';
import '../widgets/stat_card.dart';
import 'business_detail_screen.dart';


class DashboardScreen extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onAddBusiness;

  const DashboardScreen({
    super.key,
    required this.isDesktop,
    required this.onAddBusiness,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: BusinessStore.instance,
        builder: (context, _) {
          final businesses = BusinessStore.instance.businesses;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? 30 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 45),
                const Text(
                  'Business Intelligence',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Build and develop evidence-backed business profiles.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 35),
                if (businesses.isEmpty)
                  _buildEmptyState()
                else
                  _buildPopulatedState(context, businesses),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      
      child: const TextField(
        enabled: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textSecondary),
          hintText: 'Search (not built yet)',
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'No businesses yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start by adding a business to build its profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: onAddBusiness,
            icon: const Icon(Icons.add_business_outlined, size: 18),
            label: const Text('Add Your First Business'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopulatedState(BuildContext context, List<Business> businesses) {
    final store = BusinessStore.instance;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Businesses',
                value: '${store.totalBusinesses}',
                icon: Icons.business_outlined,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Open Information Gaps',
                value: '${store.informationGapCount}',
                icon: Icons.info_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 25),
        const Text(
          'Businesses',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        ...businesses.map((b) => _buildBusinessCard(context, b)),
      ],
    );
  }

  Widget _buildBusinessCard(BuildContext context, Business business) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: business.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
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
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                PipelineStageBadge(stage: business.stage),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${business.sector} · ${business.location}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            if (business.informationGaps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: business.informationGaps
                    .map((gap) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            gap,
                            style: const TextStyle(fontSize: 9, color: AppColors.warningText),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}