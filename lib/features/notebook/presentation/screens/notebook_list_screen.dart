import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/notebook_entry.dart';
import '../viewmodels/notebook_providers.dart';
import '../../../vocabulary/presentation/viewmodels/vocab_providers.dart';

String _masteryLabel(AppLocalizations l10n, MasteryLevel level) =>
    switch (level) {
      MasteryLevel.unseen => l10n.masteryUnseen,
      MasteryLevel.learning => l10n.masteryLearning,
      MasteryLevel.familiar => l10n.masteryFamiliar,
      MasteryLevel.proficient => l10n.masteryProficient,
      MasteryLevel.mastered => l10n.masteryMastered,
    };

Color _masteryColor(MasteryLevel level) => const [
      AppColors.textTertiary,
      Color(0xFF3B82F6),
      AppColors.accent,
      Color(0xFF10B981),
      AppColors.primary,
    ][level.index];

class NotebookListScreen extends ConsumerWidget {
  const NotebookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notebookAsync = ref.watch(notebookStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notebookTitle)),
      backgroundColor: AppColors.background,
      body: notebookAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_border,
                          size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.notebookEmpty,
                        style: AppTypography.title),
                    const SizedBox(height: 8),
                    Text(
                      l10n.notebookEmptyHint,
                      style: AppTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final filter = ref.watch(notebookFilterProvider);
          final filtered = switch (filter) {
            NotebookFilter.all => entries,
            NotebookFilter.needsReview => entries
                .where((e) => e.masteryLevel == MasteryLevel.learning)
                .toList(),
            NotebookFilter.mastered => entries
                .where((e) => e.masteryLevel == MasteryLevel.mastered)
                .toList(),
          };

          return Column(
            children: [
              _FilterChipBar(
                selected: filter,
                onChanged: (f) =>
                    ref.read(notebookFilterProvider.notifier).state = f,
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Text(l10n.noResults))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, i) => _NotebookEntryCard(
                          entry: filtered[i],
                          onTap: () => context
                              .push('/vocabulary/${filtered[i].vocabId}'),
                          onDelete: () async {
                            await ref
                                .read(notebookRepositoryProvider)
                                .removeEntry(filtered[i].vocabId);
                            ref.invalidate(
                                isInNotebookProvider(filtered[i].vocabId));
                          },
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

class _NotebookEntryCard extends ConsumerWidget {
  const _NotebookEntryCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final NotebookEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vocabAsync = ref.watch(vocabDetailProvider(entry.vocabId));
    final dateStr = _formatDate(entry.addedAt);

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Remove from notebook?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.delete,
                    style:
                        TextStyle(color: AppColors.error))),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: vocabAsync.when(
                        loading: () => const SizedBox(
                            height: 20,
                            child: LinearProgressIndicator()),
                        error: (_, __) => Text(
                            'Word #${entry.vocabId}',
                            style: AppTypography.title),
                        data: (vocab) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vocab?.word ?? 'Word #${entry.vocabId}',
                              style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 20),
                            ),
                            if (vocab?.pronunciationIpa != null)
                              Text(vocab!.pronunciationIpa!,
                                  style: AppTypography.ipa
                                      .copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MasteryChip(
                      level: entry.masteryLevel,
                      onTap: () => _showMasterySheet(context, ref),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Date saved
                Text(
                  l10n.savedOn(dateStr),
                  style: AppTypography.caption,
                ),

                // User note (if any)
                if (entry.userNote.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    entry.userNote,
                    style: AppTypography.bodySmall.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showMasterySheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.setMasteryTitle, style: AppTypography.title),
            const SizedBox(height: 8),
            ...MasteryLevel.values.map((level) {
              final color = _masteryColor(level);
              return ListTile(
                leading: Icon(
                  entry.masteryLevel == level
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: color,
                ),
                title: Text(_masteryLabel(l10n, level)),
                onTap: () async {
                  await ref
                      .read(notebookRepositoryProvider)
                      .updateMastery(entry.id, level);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.level, this.onTap});
  final MasteryLevel level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _masteryColor(level);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _masteryLabel(l10n, level),
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.expand_more, size: 12, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChipBar extends StatelessWidget {
  const _FilterChipBar({required this.selected, required this.onChanged});

  final NotebookFilter selected;
  final ValueChanged<NotebookFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = [
      (NotebookFilter.all, l10n.filterAll),
      (NotebookFilter.needsReview, l10n.filterNeedsReview),
      (NotebookFilter.mastered, l10n.filterMastered),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: chips.map((item) {
          final (filter, label) = item;
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: AppTypography.caption.copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
