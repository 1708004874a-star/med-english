import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../core/widgets/bilingual_text.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/clinical_case.dart';
import '../../../../domain/entities/vocabulary.dart';
import '../viewmodels/case_providers.dart';

/// Reveal screen: correct/incorrect, the epilogue explanation, and the words
/// featured in the case (tap to open the vocab detail). Marks the case solved.
class CaseResultScreen extends ConsumerStatefulWidget {
  const CaseResultScreen({
    super.key,
    required this.caseId,
    required this.correct,
    required this.pickedId,
  });

  final int caseId;
  final bool correct;
  final String pickedId;

  @override
  ConsumerState<CaseResultScreen> createState() => _CaseResultScreenState();
}

class _CaseResultScreenState extends ConsumerState<CaseResultScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.correct) {
      // Mark solved after the first frame so we don't mutate during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(solvedCasesProvider.notifier).markSolved(widget.caseId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final caseAsync = ref.watch(caseByIdProvider(widget.caseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
        title: Text(l10n.casesHubTitle, style: AppTypography.title),
      ),
      body: caseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (c) {
          if (c == null) return Center(child: Text(l10n.noResults));
          return _ResultBody(
            clinicalCase: c,
            correct: widget.correct,
            l10n: l10n,
          );
        },
      ),
    );
  }
}

class _ResultBody extends ConsumerWidget {
  const _ResultBody({
    required this.clinicalCase,
    required this.correct,
    required this.l10n,
  });

  final ClinicalCase clinicalCase;
  final bool correct;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = clinicalCase;
    final answerName =
        LocaleUtils.pick(context, en: c.answer.nameEn, zh: c.answer.nameZh);
    final accent = correct ? AppColors.success : AppColors.error;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verdict
                Row(
                  children: [
                    Icon(
                      correct
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      color: accent,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      correct ? l10n.casesCorrect : l10n.casesIncorrect,
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 24, color: accent),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.casesAnswerWas(answerName),
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),

                // Epilogue
                _SectionLabel(l10n.casesRevealLabel),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: BilingualText(
                    en: c.epilogueEn,
                    zh: c.epilogueZh,
                    style: AppTypography.body,
                  ),
                ),

                if (c.vocabIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.casesVocabLabel),
                  const SizedBox(height: 8),
                  _VocabChips(vocabIds: c.vocabIds),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/cases'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.casesPlayAgain,
                  style: AppTypography.button.copyWith(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tappable chips for the words featured in the case, opening the existing
/// vocab detail screen.
class _VocabChips extends ConsumerWidget {
  const _VocabChips({required this.vocabIds});

  final List<int> vocabIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(vocabularyRepositoryProvider);
    return FutureBuilder<List<Vocabulary>>(
      future: Future.wait(vocabIds.map(repo.getVocabById))
          .then((list) => list.whereType<Vocabulary>().toList()),
      builder: (context, snapshot) {
        final words = snapshot.data ?? const [];
        if (words.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final v in words)
              ActionChip(
                label: Text(v.word, style: AppTypography.bodySmall),
                backgroundColor: AppColors.surface,
                side: BorderSide(color: AppColors.primaryLight),
                onPressed: () => context.push('/vocabulary/${v.id}'),
              ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTypography.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
      ),
    );
  }
}
