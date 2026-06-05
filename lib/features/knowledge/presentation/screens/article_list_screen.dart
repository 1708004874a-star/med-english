import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../domain/entities/knowledge_article.dart';
import '../viewmodels/knowledge_providers.dart';

class ArticleListScreen extends ConsumerWidget {
  const ArticleListScreen({super.key, required this.systemId});

  final int systemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final articlesAsync = ref.watch(articlesBySystemProvider(systemId));
    final systemsAsync = ref.watch(knowledgeSystemsProvider);

    final systems = systemsAsync.valueOrNull ?? [];
    final matchingSystem =
        systems.where((s) => s.id == systemId).firstOrNull;
    final systemName = matchingSystem != null
        ? LocaleUtils.pick(context,
            en: matchingSystem.nameEn, zh: matchingSystem.nameZh)
        : l10n.knowledgeTitle;

    return Scaffold(
      appBar: AppBar(title: Text(systemName)),
      backgroundColor: AppColors.background,
      body: articlesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (articles) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: articles.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) => _ArticleCard(
            article: articles[i],
            systemIndex: systemId - 1,
            onTap: () => context
                .push('/knowledge/$systemId/${articles[i].id}'),
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.systemIndex,
    required this.onTap,
  });

  final KnowledgeArticle article;
  final int systemIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final idx = systemIndex.clamp(0, 7);
    final color = AppColors.systemColors[idx];
    final title = LocaleUtils.pick(context,
        en: article.titleEn, zh: article.titleZh);
    final difficulty = Difficulty.fromValue(article.difficulty);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left color accent bar
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      l10n.articleReadTime(
                          article.estimatedReadMinutes),
                      style: AppTypography.caption,
                    ),
                    const SizedBox(width: 12),
                    DifficultyBadge(difficulty: difficulty),
                  ],
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios,
              size: 13, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

