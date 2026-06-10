import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Persistent, non-dismissible disclaimer bar shown on the clinical-case
/// screens. Keeps the "fictional, not medical advice" framing always visible.
class CaseDisclaimerBar extends StatelessWidget {
  const CaseDisclaimerBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.accentLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
