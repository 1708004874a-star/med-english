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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _NotebookEntryCard(
              entry: entries[i],
              onTap: () =>
                  context.push('/vocabulary/${entries[i].vocabId}'),
              onDelete: () async {
                await ref
                    .read(notebookRepositoryProvider)
                    .removeEntry(entries[i].vocabId);
                ref.invalidate(isInNotebookProvider(entries[i].vocabId));
              },
            ),
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
                    _MasteryChip(level: entry.masteryLevel),
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
}

class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.level});
  final MasteryLevel level;

  static const _colors = [
    AppColors.textTertiary,
    Color(0xFF3B82F6),
    AppColors.accent,
    Color(0xFF10B981),
    AppColors.primary,
  ];

  static const _labels = [
    'Unseen', 'Learning', 'Familiar', 'Proficient', 'Mastered'
  ];

  @override
  Widget build(BuildContext context) {
    final idx = level.index;
    final color = _colors[idx];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _labels[idx],
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
