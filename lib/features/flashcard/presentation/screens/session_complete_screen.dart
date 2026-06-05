import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SessionCompleteScreen extends ConsumerWidget {
  const SessionCompleteScreen({
    super.key,
    required this.correct,
    required this.total,
  });

  final int correct;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pct = total > 0 ? (correct / total * 100).round() : 0;
    final isGreat = pct >= 70;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Trophy / result icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isGreat
                      ? AppColors.successLight
                      : AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGreat ? Icons.emoji_events : Icons.refresh,
                  size: 52,
                  color: isGreat ? AppColors.success : AppColors.accent,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.sessionComplete,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 30,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Score ring
              Text(
                '$pct%',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 64,
                  color: isGreat ? AppColors.success : AppColors.accent,
                  height: 1.0,
                ),
              ),

              Text(
                l10n.scoreLabel(correct, total),
                style: AppTypography.subtitle,
              ),

              const SizedBox(height: 48),

              // Study Again
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                    context.push('/flashcard');
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.studyAgain),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTypography.button,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Back to vocabulary
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/vocabulary'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTypography.button,
                  ),
                  child: Text(l10n.backToVocab),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
