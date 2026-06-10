import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../domain/entities/clinical_case.dart';
import '../viewmodels/case_providers.dart';
import '../widgets/case_disclaimer_bar.dart';

/// Lists the fictional clinical cases. A persistent disclaimer bar sits at the
/// top; the cases themselves are framed as a medical-English learning game.
class CaseHubScreen extends ConsumerWidget {
  const CaseHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final casesAsync = ref.watch(allCasesProvider);
    final solved = ref.watch(solvedCasesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: Text(l10n.casesHubTitle, style: AppTypography.title),
      ),
      body: Column(
        children: [
          CaseDisclaimerBar(text: l10n.casesDisclaimer),
          Expanded(
            child: casesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(child: Text(l10n.errorGeneric)),
              data: (cases) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cases.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _CaseCard(
                  clinicalCase: cases[i],
                  solved: solved.contains(cases[i].id),
                  l10n: l10n,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  const _CaseCard({
    required this.clinicalCase,
    required this.solved,
    required this.l10n,
  });

  final ClinicalCase clinicalCase;
  final bool solved;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final c = clinicalCase;
    final color = AppColors.systemColors[
        ((c.systemId ?? 1) - 1).clamp(0, AppColors.systemColors.length - 1)];

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/cases/session/${c.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.medical_information_outlined,
                        color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LocaleUtils.pick(context, en: c.titleEn, zh: c.titleZh),
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (solved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            l10n.casesSolvedBadge,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              DifficultyBadge(difficulty: Difficulty.fromValue(c.difficulty)),
            ],
          ),
        ),
      ),
    );
  }
}
