import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bilingual_text.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../domain/entities/vocabulary.dart';
import '../viewmodels/vocab_providers.dart';

class MorphemeDetailScreen extends ConsumerWidget {
  const MorphemeDetailScreen({super.key, required this.morphemeId});

  final int morphemeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final morphemeAsync = ref.watch(morphemeDetailProvider(morphemeId));
    final vocabAsync = ref.watch(vocabForMorphemeProvider(morphemeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.morphemeDetailTitle)),
      backgroundColor: AppColors.background,
      body: morphemeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (morpheme) {
          if (morpheme == null) {
            return Center(child: Text(l10n.noResults));
          }

          final idx = morpheme.type.index.clamp(0, 3);
          final color = AppColors.morphemeColors[idx];
          final bgColor = AppColors.morphemeColorsLight[idx];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          morpheme.type.displayName,
                          style: AppTypography.label
                              .copyWith(color: color, fontSize: 12),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        morpheme.morpheme,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 42,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Meaning
                      Text(morpheme.meaningEn,
                          style: AppTypography.title
                              .copyWith(color: color)),
                      Text(morpheme.meaningZh,
                          style: AppTypography.subtitle),

                      // Etymology
                      if (morpheme.origin != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              l10n.etymologyLabel,
                              style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            Text(morpheme.origin!,
                                style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // "Words with this root" label
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.wordsWithThisRoot.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),

              // Vocab list
              vocabAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const SliverToBoxAdapter(
                    child: SizedBox.shrink()),
                data: (vocabs) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CompactVocabCard(
                          vocab: vocabs[i],
                          onTap: () => context
                              .push('/vocabulary/${vocabs[i].id}'),
                        ),
                      ),
                      childCount: vocabs.length,
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

class _CompactVocabCard extends StatelessWidget {
  const _CompactVocabCard({required this.vocab, required this.onTap});
  final Vocabulary vocab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vocab.word,
                    style: AppTypography.title.copyWith(fontSize: 16)),
                if (vocab.pronunciationIpa != null)
                  Text(vocab.pronunciationIpa!,
                      style: AppTypography.ipa.copyWith(fontSize: 12)),
                const SizedBox(height: 4),
                BilingualText(
                  en: vocab.definitionEn,
                  zh: vocab.definitionZh,
                  style: AppTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              DifficultyBadge(difficulty: vocab.difficulty),
              const SizedBox(height: 4),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }
}
