import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Small pill used to list out a single missing piece of info (from
// Business.informationGaps) — just a rendering wrapper, no logic here.
class InfoGapChip extends StatelessWidget {
  final String label;

  const InfoGapChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        // Ink border rather than the softer default border color — makes
        // these stand out a bit more since they're meant to draw attention.
        border: Border.all(color: AppColors.inkBorder, width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    );
  }
}