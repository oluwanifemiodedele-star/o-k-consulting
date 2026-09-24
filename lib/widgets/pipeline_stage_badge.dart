import 'package:flutter/material.dart';
import '../models/pipeline_stage.dart';
import '../theme/app_colors.dart';

class PipelineStageBadge extends StatelessWidget {
  final PipelineStage stage;

  const PipelineStageBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final Color bg = stage.isBuilt ? AppColors.neutralBg : AppColors.warningBg;
    final Color fg = stage.isBuilt ? AppColors.neutralText : AppColors.warningText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inkBorder, width: stage.isBuilt ? 1 : 0),
      ),
      child: Text(
        stage.label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: fg),
      ),
    );
  }
}