import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SystemColorChip extends StatelessWidget {
  const SystemColorChip({
    super.key,
    required this.systemIndex,
    required this.label,
  });

  final int systemIndex;
  final String label;

  @override
  Widget build(BuildContext context) {
    final idx = systemIndex.clamp(0, AppColors.systemColors.length - 1);
    final color = AppColors.systemColors[idx];
    final bgColor = AppColors.systemColorsLight[idx];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: color),
      ),
    );
  }
}
