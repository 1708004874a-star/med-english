import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../domain/entities/morpheme.dart';
import '../viewmodels/vocab_providers.dart';

class MorphemeListScreen extends ConsumerWidget {
  const MorphemeListScreen({super.key});

  static const _types = [null, 'prefix', 'root', 'suffix'];
  static const _typeLabels = ['All', 'Prefix', 'Root', 'Suffix'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final morphemesAsync = ref.watch(filteredMorphemesProvider);
    final selectedType = ref.watch(morphemeTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.morphemeListTitle)),
      body: Column(
        children: [
          // Type filter tabs
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _types.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = selectedType == _types[i];
                return GestureDetector(
                  onTap: () => ref
                      .read(morphemeTypeFilterProvider.notifier)
                      .state = _types[i],
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      _typeLabels[i],
                      style: AppTypography.label.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Morpheme grid
          Expanded(
            child: morphemesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  Center(child: Text(l10n.errorGeneric)),
              data: (morphemes) => GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: morphemes.length,
                itemBuilder: (context, i) => _MorphemeCard(
                  morpheme: morphemes[i],
                  onTap: () => context
                      .push('/vocabulary/morphemes/${morphemes[i].id}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MorphemeCard extends StatelessWidget {
  const _MorphemeCard({required this.morpheme, required this.onTap});
  final Morpheme morpheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final idx = morpheme.type.index.clamp(0, 3);
    final color = AppColors.morphemeColors[idx];
    final bgColor = AppColors.morphemeColorsLight[idx];

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              morpheme.type.displayName,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const Spacer(),

          // Morpheme text
          Text(
            morpheme.morpheme,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          // Meaning EN
          Text(
            morpheme.meaningEn,
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Meaning ZH
          Text(
            morpheme.meaningZh,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          if (morpheme.origin != null) ...[
            const SizedBox(height: 4),
            Text(
              morpheme.origin!,
              style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
