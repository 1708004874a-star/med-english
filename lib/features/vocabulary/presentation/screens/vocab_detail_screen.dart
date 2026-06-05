import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/difficulty_badge.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/morpheme.dart';
import '../../../../domain/entities/vocabulary.dart';
import '../viewmodels/vocab_providers.dart';

class VocabDetailScreen extends ConsumerWidget {
  const VocabDetailScreen({super.key, required this.vocabId});

  final int vocabId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final vocabAsync = ref.watch(vocabDetailProvider(vocabId));
    final inNotebookAsync = ref.watch(isInNotebookProvider(vocabId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: vocabAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (vocab) {
          if (vocab == null) {
            return Center(child: Text(l10n.noResults));
          }
          return _VocabDetailBody(
            vocab: vocab,
            inNotebookAsync: inNotebookAsync,
            l10n: l10n,
            ref: ref,
          );
        },
      ),
    );
  }
}

class _VocabDetailBody extends StatelessWidget {
  const _VocabDetailBody({
    required this.vocab,
    required this.inNotebookAsync,
    required this.l10n,
    required this.ref,
  });

  final Vocabulary vocab;
  final AsyncValue<bool> inNotebookAsync;
  final AppLocalizations l10n;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final inNotebook = inNotebookAsync.valueOrNull ?? false;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero app bar ───────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 0,
          pinned: true,
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          actions: [
            IconButton(
              onPressed: () => _toggleNotebook(context, ref, inNotebook),
              icon: Icon(
                inNotebook ? Icons.bookmark : Icons.bookmark_outline,
                color: inNotebook ? AppColors.accent : AppColors.textSecondary,
              ),
              tooltip: inNotebook
                  ? l10n.removeFromNotebook
                  : l10n.tabNotebook,
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Word ────────────────────────────────────────────────────
                Text(
                  vocab.word,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 38,
                    color: AppColors.textPrimary,
                    height: 1.1,
                  ),
                ),

                // ── IPA + TTS ────────────────────────────────────────────────
                if (vocab.pronunciationIpa != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(vocab.pronunciationIpa!,
                            style: AppTypography.ipa.copyWith(fontSize: 15)),
                        const SizedBox(width: 10),
                        _SpeakButton(
                          word: vocab.word,
                          label: l10n.speakWord,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                DifficultyBadge(difficulty: vocab.difficulty),

                // ── Morpheme decomposition ───────────────────────────────────
                if (vocab.morphemes.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.morphemesLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vocab.morphemes
                        .map((m) => _MorphemeDetailChip(
                              morpheme: m,
                              onTap: () => context
                                  .push('/vocabulary/morphemes/${m.id}'),
                            ))
                        .toList(),
                  ),
                ],

                // ── Definition ────────────────────────────────────────────────
                const SizedBox(height: 20),
                _SectionLabel(
                  Localizations.localeOf(context).languageCode == 'zh'
                      ? '释义'
                      : 'Definition',
                ),
                const SizedBox(height: 8),
                _BilingualBlock(
                  en: vocab.definitionEn,
                  zh: vocab.definitionZh,
                ),

                // ── Example ───────────────────────────────────────────────────
                if (vocab.exampleEn != null) ...[
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.exampleLabel),
                  const SizedBox(height: 8),
                  _BilingualBlock(
                    en: vocab.exampleEn!,
                    zh: vocab.exampleZh ?? '',
                    isItalic: true,
                  ),
                ],

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleNotebook(
      BuildContext context, WidgetRef ref, bool isIn) async {
    final repo = ref.read(notebookRepositoryProvider);
    if (isIn) {
      await repo.removeEntry(vocab.id);
    } else {
      await repo.addEntry(vocab.id);
    }
    ref.invalidate(isInNotebookProvider(vocab.id));
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

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

class _BilingualBlock extends StatelessWidget {
  const _BilingualBlock({
    required this.en,
    required this.zh,
    this.isItalic = false,
  });

  final String en;
  final String zh;
  final bool isItalic;

  @override
  Widget build(BuildContext context) {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    final primaryText = isZh ? zh : en;
    final secondaryText = isZh ? en : zh;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            primaryText,
            style: AppTypography.body.copyWith(
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (secondaryText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              secondaryText,
              style: AppTypography.bodySmall.copyWith(
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpeakButton extends StatefulWidget {
  const _SpeakButton({required this.word, required this.label});
  final String word;
  final String label;

  @override
  State<_SpeakButton> createState() => _SpeakButtonState();
}

class _SpeakButtonState extends State<_SpeakButton> {
  bool _speaking = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _speaking ? null : _speak,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _speaking ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _speaking ? Icons.volume_up : Icons.volume_up_outlined,
              size: 14,
              color: _speaking ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: AppTypography.caption.copyWith(
                color: _speaking ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speak() async {
    setState(() => _speaking = true);
    await TtsHelper.speak(widget.word);
    if (mounted) setState(() => _speaking = false);
  }
}

class _MorphemeDetailChip extends StatelessWidget {
  const _MorphemeDetailChip({required this.morpheme, required this.onTap});
  final Morpheme morpheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final idx = morpheme.type.index.clamp(0, 3);
    final color = AppColors.morphemeColors[idx];
    final bgColor = AppColors.morphemeColorsLight[idx];
    final typeLabel =
        morpheme.type.displayName; // "Prefix" / "Root" / "Suffix"

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              morpheme.morpheme,
              style: GoogleFonts.spaceMono(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$typeLabel · ${morpheme.meaningEn}',
              style: AppTypography.caption.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
