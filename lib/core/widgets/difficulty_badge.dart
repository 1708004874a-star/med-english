import 'package:flutter/material.dart';
import '../constants/db_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class DifficultyBadge extends StatelessWidget {
  const DifficultyBadge({super.key, required this.difficulty});

  final Difficulty difficulty;

  static const List<Color> _colors = [
    Color(0xFF16A34A), // 1 beginner — green
    Color(0xFF0F766E), // 2 elementary — teal
    Color(0xFFB45309), // 3 intermediate — amber
    Color(0xFFEA580C), // 4 advanced — orange
    Color(0xFFDC2626), // 5 expert — red
  ];

  static const List<Color> _bgColors = [
    Color(0xFFDCFCE7),
    Color(0xFFCCFBF1),
    Color(0xFFFEF3C7),
    Color(0xFFFFEDD5),
    Color(0xFFFEE2E2),
  ];

  static const List<String> _labels = [
    'Beginner',
    'Elementary',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  Widget build(BuildContext context) {
    final idx = difficulty.index;
    final color = _colors[idx];
    final bgColor = _bgColors[idx];
    final label = _labels[idx];
    final filledCount = difficulty.value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < filledCount
                          ? color
                          : AppColors.divider,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
