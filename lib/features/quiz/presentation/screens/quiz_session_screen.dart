import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../domain/entities/quiz_question.dart';
import '../viewmodels/quiz_providers.dart';

class QuizSessionScreen extends ConsumerStatefulWidget {
  const QuizSessionScreen({super.key});

  @override
  ConsumerState<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends ConsumerState<QuizSessionScreen> {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _answered = false;
  final List<int> _wrongIds = [];

  void _selectAnswer(int idx, QuizQuestion q) {
    if (_answered) return;
    setState(() {
      _selectedIndex = idx;
      _answered = true;
      if (idx == q.correctIndex) {
        _correctCount++;
      } else {
        _wrongIds.add(q.id);
      }
    });
  }

  void _nextQuestion(int total) {
    if (_currentIndex + 1 >= total) {
      context.pushReplacement('/quiz/result', extra: {
        'correct': _correctCount,
        'total': total,
        'wrongIds': _wrongIds,
      });
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final questionsAsync = ref.watch(quizSessionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.quizTitle),
        backgroundColor: AppColors.surface,
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (questions) {
          if (questions.isEmpty) {
            return Center(child: Text(l10n.noResults));
          }

          final q = questions[_currentIndex];
          final total = questions.length;
          final options = LocaleUtils.isZh(context)
              ? q.optionsZh
              : q.optionsEn;
          final question = LocaleUtils.pick(context,
              en: q.questionEn, zh: q.questionZh);
          final explanation = LocaleUtils.pick(context,
              en: q.explanationEn, zh: q.explanationZh);

          return Column(
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / total,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 3,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.questionOf(_currentIndex + 1, total),
                          style: AppTypography.caption,
                        ),
                      ),

                      // Question card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          question,
                          style: AppTypography.title.copyWith(
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Answer options
                      ...List.generate(options.length, (i) {
                        Color borderColor = AppColors.border;
                        Color bgColor = AppColors.surface;
                        Color textColor = AppColors.textPrimary;

                        if (_answered) {
                          if (i == q.correctIndex) {
                            borderColor = AppColors.success;
                            bgColor = AppColors.successLight;
                            textColor = AppColors.success;
                          } else if (i == _selectedIndex) {
                            borderColor = AppColors.error;
                            bgColor = AppColors.errorLight;
                            textColor = AppColors.error;
                          }
                        } else if (_selectedIndex == i) {
                          borderColor = AppColors.primary;
                          bgColor = AppColors.primaryLight;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () => _selectAnswer(i, q),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: borderColor, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          borderColor.withValues(alpha: 0.15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(
                                            65 + i), // A B C D
                                        style: AppTypography.label
                                            .copyWith(color: borderColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      options[i],
                                      style: AppTypography.body.copyWith(
                                        color: textColor,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (_answered && i == q.correctIndex)
                                    Icon(Icons.check_circle,
                                        color: AppColors.success,
                                        size: 20),
                                  if (_answered &&
                                      i == _selectedIndex &&
                                      i != q.correctIndex)
                                    Icon(Icons.cancel,
                                        color: AppColors.error,
                                        size: 20),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      // Explanation
                      if (_answered) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  color: AppColors.primary, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  explanation,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Next / Finish button
              if (_answered)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _nextQuestion(total),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        textStyle: AppTypography.button,
                      ),
                      child: Text(
                        _currentIndex + 1 >= total
                            ? l10n.seeResults
                            : l10n.nextQuestion,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
