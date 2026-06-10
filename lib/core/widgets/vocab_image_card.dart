import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Rounded illustration card for a vocabulary word, with an optional
/// attribution line (required for CC-BY sourced images).
class VocabImageCard extends StatelessWidget {
  const VocabImageCard({
    super.key,
    required this.imagePath,
    this.credit,
    this.maxHeight = 220,
  });

  final String imagePath;
  final String? credit;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              // A missing asset should never break the page — just hide.
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        if (credit != null && credit!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              credit!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
