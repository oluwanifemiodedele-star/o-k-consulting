import 'package:flutter/material.dart';
import '../models/pipeline_stage.dart';
import '../theme/app_colors.dart';

/// Small pill that shows which pipeline stage a business is at.
///
/// Early stages get a white pill with an outline. The last two stages
/// (profile built and monitoring) get a solid dark pill.
class PipelineStageBadge extends StatelessWidget {
  /// The stage to show.
  final PipelineStage stage;

  const PipelineStageBadge({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    // isBuilt is true for the early stages, so those get the light look.
    final Color bg = stage.isBuilt ? AppColors.neutralBg : AppColors.warningBg;
    final Color fg = stage.isBuilt ? AppColors.neutralText : AppColors.warningText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        // Width 0 instead of no border, so both looks stay the same size.
        border: Border.all(color: AppColors.inkBorder, width: stage.isBuilt ? 1 : 0),
      ),
      child: Text(
        stage.label.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: fg),
      ),
    );
  }
}