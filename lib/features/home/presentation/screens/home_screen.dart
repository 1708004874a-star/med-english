import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/language_picker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _cardFades;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardFades = List.generate(
      4,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0.1 + i * 0.12, 0.55 + i * 0.12,
            curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDisclaimer());
  }

  Future<void> _maybeShowDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    if (prefs.getBool(kFirstLaunchKey) != true) {
      await DisclaimerDialog.show(context, () async {
        await prefs.setBool(kFirstLaunchKey, true);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Header(
              topPad: topPad,
              l10n: l10n,
              onLanguageTap: () => showLanguagePicker(context, ref),
            ),
          ),

          // ── Flashcard Quick-Start Banner ──────────────────────────────────
          SliverToBoxAdapter(
            child: _FlashcardBanner(l10n: l10n),
          ),

          // ── Module Grid ───────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
              children: [
                _ModuleCard(
                  animation: _cardFades[0],
                  icon: Icons.link,
                  color: AppColors.morphemeColors[0],
                  colorLight: AppColors.morphemeColorsLight[0],
                  title: l10n.moduleWordRootsTitle,
                  subtitle: l10n.moduleWordRootsSubtitle,
                  onTap: () => context.go('/vocabulary/morphemes'),
                ),
                _ModuleCard(
                  animation: _cardFades[1],
                  icon: Icons.menu_book,
                  color: AppColors.systemColors[1],
                  colorLight: AppColors.systemColorsLight[1],
                  title: l10n.moduleVocabTitle,
                  subtitle: l10n.moduleVocabSubtitle(348, 8),
                  onTap: () => context.go('/vocabulary'),
                ),
                _ModuleCard(
                  animation: _cardFades[2],
                  icon: Icons.article,
                  color: AppColors.systemColors[2],
                  colorLight: AppColors.systemColorsLight[2],
                  title: l10n.moduleKnowledgeTitle,
                  subtitle: l10n.moduleKnowledgeSubtitle,
                  onTap: () => context.go('/knowledge'),
                ),
                _ModuleCard(
                  animation: _cardFades[3],
                  icon: Icons.quiz,
                  color: AppColors.accent,
                  colorLight: AppColors.accentLight,
                  title: l10n.moduleQuizTitle,
                  subtitle: l10n.moduleQuizSubtitle,
                  onTap: () => context.push('/quiz'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.topPad,
    required this.l10n,
    required this.onLanguageTap,
  });

  final double topPad;
  final AppLocalizations l10n;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, topPad + 18, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: branding + about button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appTitle,
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 34,
                        color: Colors.white,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.appTagline,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLanguageTap,
                icon: const Icon(Icons.language,
                    color: Colors.white70, size: 22),
                tooltip: l10n.languageSettingTitle,
              ),
              IconButton(
                onPressed: () => context.push('/about'),
                icon: const Icon(Icons.info_outline,
                    color: Colors.white70, size: 22),
                tooltip: 'About',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Decorative morpheme chip row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: const [
              _MorphemePreviewChip('cardio-'),
              _MorphemePreviewChip('-itis'),
              _MorphemePreviewChip('neuro-'),
              _MorphemePreviewChip('-ology'),
              _MorphemePreviewChip('hepat-'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MorphemePreviewChip extends StatelessWidget {
  const _MorphemePreviewChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 12,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

// ── Flashcard Quick-Start Banner ────────────────────────────────────────────

class _FlashcardBanner extends StatelessWidget {
  const _FlashcardBanner({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: () => context.push('/flashcard'),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.flip, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.flashcardTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      l10n.startSession,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Module Card ─────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.animation,
    required this.icon,
    required this.color,
    required this.colorLight,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Animation<double> animation;
  final IconData icon;
  final Color color;
  final Color colorLight;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, 24 * (1 - animation.value)),
        child: Opacity(opacity: animation.value.clamp(0.0, 1.0), child: child),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored icon area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorLight,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15)),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                // Text content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 11, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.title.copyWith(
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Expanded(
                          child: Text(
                            subtitle,
                            style: AppTypography.caption,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.arrow_forward,
                              size: 15, color: color.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
