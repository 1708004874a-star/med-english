import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class QuizResultScreen extends ConsumerWidget {
  const QuizResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.wrongIds,
  });

  final int correct;
  final int total;
  final List<int> wrongIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pct = total > 0 ? (correct / total * 100).round() : 0;
    final isPass = pct >= 60;
    final color = isPass ? AppColors.success : AppColors.error;
    final bgColor = isPass ? AppColors.successLight : AppColors.errorLight;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Score circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$pct%',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 40,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      l10n.yourScore,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                l10n.quizResult,
                style: GoogleFonts.dmSerifDisplay(fontSize: 26),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.scoreLabel(correct, total),
                style: AppTypography.subtitle,
              ),

              const SizedBox(height: 32),

              // Wrong answer count badge
              if (wrongIds.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: AppColors.error, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${wrongIds.length} ${l10n.incorrect}',
                        style: AppTypography.label
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                    context.push('/quiz');
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.retakeQuiz),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: AppTypography.button,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: AppTypography.button,
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
