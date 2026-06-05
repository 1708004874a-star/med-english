import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bilingual_text.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../core/widgets/system_color_chip.dart';
import '../../../../domain/entities/body_system.dart';
import '../../../../domain/entities/morpheme.dart';
import '../../../../domain/entities/vocabulary.dart';
import '../viewmodels/vocab_providers.dart';

class VocabListScreen extends ConsumerStatefulWidget {
  const VocabListScreen({super.key});

  @override
  ConsumerState<VocabListScreen> createState() => _VocabListScreenState();
}

class _VocabListScreenState extends ConsumerState<VocabListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final systemsAsync = ref.watch(allSystemsProvider);
    final vocabAsync = ref.watch(vocabDisplayProvider);
    final selectedSystem = ref.watch(selectedSystemProvider);
    final query = ref.watch(vocabSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vocabListTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/vocabulary/morphemes'),
            icon: const Icon(Icons.link, size: 20),
            tooltip: l10n.morphemeListTitle,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                ref.read(vocabSearchQueryProvider.notifier).state = v.trim();
                if (v.isNotEmpty) {
                  ref.read(selectedSystemProvider.notifier).state = null;
                }
              },
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(vocabSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),

          // ── System filter chips ──────────────────────────────────────────
          if (query.isEmpty)
            systemsAsync.when(
              data: (systems) => _SystemChipRow(
                systems: systems,
                selectedId: selectedSystem,
                onSelect: (id) {
                  ref.read(selectedSystemProvider.notifier).state = id;
                },
              ),
              loading: () => const SizedBox(height: 40),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // ── Vocab list ───────────────────────────────────────────────────
          Expanded(
            child: vocabAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(l10n.errorGeneric,
                    style: AppTypography.body),
              ),
              data: (vocabs) {
                if (vocabs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text(l10n.noResults, style: AppTypography.body),
                      ],
                    ),
                  );
                }

                final systems = systemsAsync.valueOrNull ?? [];
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: vocabs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _VocabCard(
                    vocab: vocabs[i],
                    systems: systems,
                    onTap: () =>
                        context.push('/vocabulary/${vocabs[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── System chip row ───────────────────────────────────────────────────────────

class _SystemChipRow extends StatelessWidget {
  const _SystemChipRow({
    required this.systems,
    required this.selectedId,
    required this.onSelect,
  });

  final List<BodySystem> systems;
  final int? selectedId;
  final void Function(int?) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: l10n.allSystems,
            selected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          ...systems.map((s) {
            final idx = s.id - 1;
            final label = s.nameEn;
            return _FilterChip(
              label: label,
              selected: selectedId == s.id,
              color: AppColors.systemColors[idx.clamp(0, AppColors.systemColors.length - 1)],
              onTap: () => onSelect(selectedId == s.id ? null : s.id),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.label.copyWith(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// ── Vocab card ────────────────────────────────────────────────────────────────

class _VocabCard extends StatelessWidget {
  const _VocabCard({
    required this.vocab,
    required this.systems,
    required this.onTap,
  });

  final Vocabulary vocab;
  final List<BodySystem> systems;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final system = vocab.systemId != null
        ? systems.where((s) => s.id == vocab.systemId).firstOrNull
        : null;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word + system chip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  vocab.word,
                  style: AppTypography.headline.copyWith(fontSize: 20),
                ),
              ),
              if (system != null)
                SystemColorChip(
                  systemIndex: system.id - 1,
                  label: system.nameEn,
                ),
            ],
          ),

          // IPA
          if (vocab.pronunciationIpa != null) ...[
            const SizedBox(height: 2),
            Text(vocab.pronunciationIpa!,
                style: AppTypography.ipa.copyWith(fontSize: 13)),
          ],

          const SizedBox(height: 6),

          // Definition (bilingual)
          BilingualText(
            en: vocab.definitionEn,
            zh: vocab.definitionZh,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Morpheme chips
          if (vocab.morphemes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: vocab.morphemes
                  .take(4)
                  .map((m) => _MorphemeTag(m))
                  .toList(),
            ),
          ],

          const SizedBox(height: 8),
          DifficultyBadge(difficulty: vocab.difficulty),
        ],
      ),
    );
  }
}

class _MorphemeTag extends StatelessWidget {
  const _MorphemeTag(this.m);
  final Morpheme m;

  @override
  Widget build(BuildContext context) {
    final idx = m.type.index.clamp(0, 3);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.morphemeColorsLight[idx],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        m.morpheme,
        style: AppTypography.ipa.copyWith(
          fontSize: 11,
          color: AppColors.morphemeColors[idx],
        ),
      ),
    );
  }
}
