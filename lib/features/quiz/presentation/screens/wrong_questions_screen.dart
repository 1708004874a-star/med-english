import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/wrong_question_entry.dart';
import '../viewmodels/quiz_providers.dart';

class WrongQuestionsScreen extends ConsumerWidget {
  const WrongQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final entriesAsync = ref.watch(wrongQuestionsByDomainProvider);
    final wrongRepo = ref.watch(wrongQuestionRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.quizWrongBook),
        backgroundColor: AppColors.surface,
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 56, color: AppColors.textTertiary),
                  const SizedBox(height: 12),
                  Text(l10n.wrongBookEmpty,
                      style: AppTypography.subtitle),
                ],
              ),
            );
          }

          final toReview =
              entries.where((e) => !e.mastered).toList();
          final mastered =
              entries.where((e) => e.mastered).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // ── Redo To-Review button ────────────────────────────────
              if (toReview.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final ids =
                          toReview.map((e) => e.question.id).toList();
                      context.push('/quiz/session/review', extra: ids);
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l10n.redoWrong(toReview.length)),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      textStyle: AppTypography.button,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── To-Review section ────────────────────────────────────
              if (toReview.isNotEmpty) ...[
                _SectionHeader(
                  title: l10n.toReviewLabel,
                  count: toReview.length,
                  color: AppColors.error,
                ),
                ...toReview.map((e) => _WrongQuestionTile(
                      entry: e,
                      onReset: () =>
                          wrongRepo.resetMastered(e.question.id),
                      onRemove: () =>
                          wrongRepo.remove(e.question.id),
                      l10n: l10n,
                    )),
              ],

              // ── Mastered section ─────────────────────────────────────
              if (mastered.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionHeader(
                  title: l10n.masteredLabel,
                  count: mastered.length,
                  color: AppColors.success,
                ),
                ...mastered.map((e) => _WrongQuestionTile(
                      entry: e,
                      onReset: () =>
                          wrongRepo.resetMastered(e.question.id),
                      onRemove: () =>
                          wrongRepo.remove(e.question.id),
                      l10n: l10n,
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.title.copyWith(
              fontSize: 15,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: AppTypography.label.copyWith(
                fontSize: 11,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WrongQuestionTile extends StatelessWidget {
  const _WrongQuestionTile({
    required this.entry,
    required this.onReset,
    required this.onRemove,
    required this.l10n,
  });

  final WrongQuestionEntry entry;
  final VoidCallback onReset;
  final VoidCallback onRemove;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final q = entry.question;
    final questionText =
        LocaleUtils.pick(context, en: q.questionEn, zh: q.questionZh);
    final dateStr = DateFormat.yMMMd()
        .format(entry.lastWrongAt);
    final mastered = entry.mastered;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding:
            const EdgeInsets.fromLTRB(14, 0, 14, 12),
        shape: const Border(),
        title: Text(
          questionText,
          style: AppTypography.body.copyWith(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            _MetaChip(
              label: l10n.wrongCountLabel(entry.wrongCount),
              color: AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              dateStr,
              style: AppTypography.caption.copyWith(fontSize: 11),
            ),
            if (mastered) ...[
              const SizedBox(width: 8),
              _MetaChip(
                label: l10n.masteredLabel,
                color: AppColors.success,
              ),
            ],
          ],
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onReset,
                icon: Icon(
                  mastered ? Icons.undo : Icons.refresh,
                  size: 16,
                ),
                label: Text(
                  mastered
                      ? l10n.resetMastered
                      : l10n.markNotMastered,
                  style: AppTypography.caption,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(
                  l10n.removeEntry,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
