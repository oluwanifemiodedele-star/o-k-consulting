import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const List<String> kNavigationItems = [
  'Home',
  'My Businesses',
  'Add Business',
  'Intelligence Hub',
  'Monitoring',
  'Reports',
  'Settings',
];

const List<IconData> kNavigationIcons = [
  Icons.grid_view_rounded,
  Icons.business_outlined,
  Icons.add_business_outlined,
  Icons.auto_awesome_outlined,
  Icons.radar_outlined,
  Icons.analytics_outlined,
  Icons.settings_outlined,
];

class AppSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const AppSidebar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(right: BorderSide(color: AppColors.inkBorder, width: 1.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 35),
              Expanded(child: _buildNavList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O-K',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'BUSINESS INTELLIGENCE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(height: 2, color: AppColors.inkBorder),
      ],
    );
  }

  Widget _buildNavList(BuildContext context) {
    return ListView.builder(
      itemCount: kNavigationItems.length,
      itemBuilder: (context, index) {
        final bool isSelected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              onSelect(index);
              if (Scaffold.of(context).hasDrawer) {
                Navigator.of(context).pop();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: isSelected
                    ? const LinearGradient(colors: [AppColors.primaryBlue, Color(0xFF315BEA)])
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    kNavigationIcons[index],
                    size: 19,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 13),
                  Text(
                    kNavigationItems[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}