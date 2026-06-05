import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/tts_helper.dart';
import '../../../../core/widgets/bilingual_text.dart';
import '../../../../domain/entities/vocabulary.dart';
import '../viewmodels/flashcard_providers.dart';
import '../widgets/flip_card.dart';

class FlashcardSessionScreen extends ConsumerStatefulWidget {
  const FlashcardSessionScreen({super.key, this.systemId});

  final int? systemId;

  @override
  ConsumerState<FlashcardSessionScreen> createState() =>
      _FlashcardSessionScreenState();
}

class _FlashcardSessionScreenState
    extends ConsumerState<FlashcardSessionScreen> {
  int _currentIndex = 0;
  int _knownCount = 0;
  final _flipCardKey = GlobalKey<FlipCardState>();

  @override
  void dispose() {
    TtsHelper.stop();
    super.dispose();
  }

  void _onKnown(List<Vocabulary> cards) {
    setState(() {
      _knownCount++;
      _currentIndex++;
    });
    if (_currentIndex >= cards.length) {
      _navigateToComplete(cards.length);
    } else {
      _speakCurrent(cards);
    }
  }

  void _onReview(List<Vocabulary> cards) {
    setState(() => _currentIndex++);
    if (_currentIndex >= cards.length) {
      _navigateToComplete(cards.length);
    } else {
      _speakCurrent(cards);
    }
  }

  void _speakCurrent(List<Vocabulary> cards) {
    if (_currentIndex < cards.length) {
      TtsHelper.speak(cards[_currentIndex].word);
    }
  }

  void _navigateToComplete(int total) {
    context.pushReplacement(
      '/flashcard/complete',
      extra: {'correct': _knownCount, 'total': total},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchAsync = ref.watch(flashcardBatchProvider(widget.systemId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.flashcardTitle),
        backgroundColor: AppColors.surface,
      ),
      body: batchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            Center(child: Text(l10n.errorGeneric)),
        data: (cards) {
          if (cards.isEmpty) {
            return Center(child: Text(l10n.noResults));
          }

          if (_currentIndex >= cards.length) {
            return const SizedBox.shrink();
          }

          final vocab = cards[_currentIndex];
          final progress = _currentIndex / cards.length;

          return Column(
            children: [
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.divider,
                color: AppColors.primary,
                minHeight: 3,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${cards.length}',
                      style: AppTypography.caption,
                    ),
                    Text(
                      '✓ $_knownCount known',
                      style: AppTypography.caption.copyWith(
                          color: AppColors.success),
                    ),
                  ],
                ),
              ),

              // Flip card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FlipCard(
                    key: _flipCardKey,
                    resetKey: _currentIndex,
                    onTap: () => TtsHelper.speak(vocab.word),
                    front: _CardFace(
                      color: AppColors.surface,
                      child: _FrontContent(vocab: vocab, l10n: l10n),
                    ),
                    back: _CardFace(
                      color: const Color(0xFFF0FDF4),
                      child: _BackContent(vocab: vocab),
                    ),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: l10n.needsReview,
                        icon: Icons.refresh,
                        color: AppColors.accent,
                        onTap: () => _onReview(cards),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        label: l10n.iKnowThis,
                        icon: Icons.check,
                        color: AppColors.success,
                        onTap: () => _onKnown(cards),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Card faces ─────────────────────────────────────────────────────────────────

class _CardFace extends StatelessWidget {
  const _CardFace({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FrontContent extends StatelessWidget {
  const _FrontContent({required this.vocab, required this.l10n});
  final Vocabulary vocab;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Word
          Text(
            vocab.word,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 40,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),

          if (vocab.pronunciationIpa != null) ...[
            const SizedBox(height: 10),
            Text(
              vocab.pronunciationIpa!,
              style: AppTypography.ipa.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],

          const Spacer(),

          // Hint
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_outlined,
                  size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(l10n.tapToFlip,
                  style: AppTypography.caption),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BackContent extends StatelessWidget {
  const _BackContent({required this.vocab});
  final Vocabulary vocab;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vocab.word,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 26,
              color: AppColors.primary,
            ),
          ),

          const Divider(height: 20),

          // Definition
          BilingualText(
            en: vocab.definitionEn,
            zh: vocab.definitionZh,
            style: AppTypography.body,
          ),

          // Example
          if (vocab.exampleEn != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: BilingualText(
                en: vocab.exampleEn!,
                zh: vocab.exampleZh ?? '',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        textStyle: AppTypography.button,
      ),
    );
  }
}
