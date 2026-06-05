import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../viewmodels/knowledge_providers.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final int articleId;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _showBoth = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final articleAsync = ref.watch(articleDetailProvider(widget.articleId));
    final isZh = LocaleUtils.isZh(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: articleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (article) {
          if (article == null) {
            return Center(child: Text(l10n.noResults));
          }

          final idx = (article.systemId - 1).clamp(0, AppColors.systemColors.length - 1);
          final color = AppColors.systemColors[idx];
          final difficulty = Difficulty.fromValue(article.difficulty);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                title: Text(
                  l10n.knowledgeTitle,
                  style: AppTypography.headline.copyWith(fontSize: 18),
                ),
                actions: [
                  // Toggle bilingual / primary language
                  IconButton(
                    onPressed: () =>
                        setState(() => _showBoth = !_showBoth),
                    icon: Icon(
                      _showBoth
                          ? Icons.translate
                          : Icons.g_translate,
                      color: _showBoth
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    tooltip: 'Toggle bilingual',
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + difficulty row
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 12,
                                  color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                l10n.articleReadTime(
                                    article.estimatedReadMinutes),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          DifficultyBadge(difficulty: difficulty),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Title
                      Text(
                        LocaleUtils.pick(context,
                            en: article.titleEn,
                            zh: article.titleZh),
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 28,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),

                      if (_showBoth) ...[
                        const SizedBox(height: 4),
                        Text(
                          isZh ? article.titleEn : article.titleZh,
                          style: AppTypography.subtitle.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Decorative divider
                      Container(
                        height: 2,
                        width: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Content (primary language)
                      Text(
                        LocaleUtils.pick(context,
                            en: article.contentEn,
                            zh: article.contentZh),
                        style: AppTypography.body.copyWith(height: 1.75),
                      ),

                      // Secondary language (bilingual toggle)
                      if (_showBoth) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            isZh
                                ? article.contentEn
                                : article.contentZh,
                            style: AppTypography.bodySmall
                                .copyWith(height: 1.65),
                          ),
                        ),
                      ],

                      const SizedBox(height: 48),
                    ],
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
