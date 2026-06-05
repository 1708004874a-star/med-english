import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/constants/db_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/domain_palette.dart';
import '../../../../core/widgets/disclaimer_banner.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../data/settings_providers.dart';
import '../../../vocabulary/presentation/viewmodels/vocab_providers.dart';

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
    final palette = ref.watch(domainPaletteProvider);
    final domain = ref.watch(domainProvider);
    final topPad = MediaQuery.of(context).padding.top;

    // Dynamic counts for the vocabulary card subtitle.
    final vocabCount = ref.watch(domainVocabCountProvider).valueOrNull ?? 0;
    final systemCount = ref.watch(domainSystemCountProvider).valueOrNull ?? 0;

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
              palette: palette,
              domain: domain,
              onLanguageTap: () => showLanguagePicker(context, ref),
            ),
          ),

          // ── Flashcard Quick-Start Banner ──────────────────────────────────
          SliverToBoxAdapter(
            child: _FlashcardBanner(l10n: l10n, palette: palette),
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
                  subtitle: l10n.moduleVocabSubtitle(vocabCount, systemCount),
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
    required this.palette,
    required this.domain,
    required this.onLanguageTap,
  });

  final double topPad;
  final AppLocalizations l10n;
  final DomainPalette palette;
  final AppDomain domain;
  final VoidCallback onLanguageTap;

  @override
  Widget build(BuildContext context) {
    final isMicro = domain == AppDomain.micro;
    final tagline = isMicro ? l10n.appTaglineMicro : l10n.appTagline;

    // Preview morpheme chips — different set per domain for flavour.
    final macroChips = const ['cardio-', '-itis', 'neuro-', '-ology', 'hepat-'];
    final microChips = const ['cyto-', '-blast', 'karyo-', '-some', 'geno-'];
    final chips = isMicro ? microChips : macroChips;

    return Container(
      padding: EdgeInsets.fromLTRB(24, topPad + 18, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.gradientStart, palette.gradientEnd],
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
                      tagline,
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

          const SizedBox(height: 16),

          // ── Domain Switcher ───────────────────────────────────────────
          _DomainSwitcher(palette: palette),

          const SizedBox(height: 16),

          // Decorative morpheme chip row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: chips
                .map((label) => _MorphemePreviewChip(label))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Domain Switcher ─────────────────────────────────────────────────────────

class _DomainSwitcher extends ConsumerWidget {
  const _DomainSwitcher({required this.palette});

  final DomainPalette palette;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final domain = ref.watch(domainProvider);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _SwitcherSegment(
            label: l10n.systemSwitcherMacro,
            selected: domain == AppDomain.macro,
            palette: palette,
            onTap: () {
              ref.read(domainProvider.notifier).setDomain(AppDomain.macro);
              // Reset system filter when switching domain.
              ref.read(selectedSystemProvider.notifier).state = null;
            },
          ),
          _SwitcherSegment(
            label: l10n.systemSwitcherMicro,
            selected: domain == AppDomain.micro,
            palette: palette,
            onTap: () {
              ref.read(domainProvider.notifier).setDomain(AppDomain.micro);
              ref.read(selectedSystemProvider.notifier).state = null;
            },
          ),
        ],
      ),
    );
  }
}

class _SwitcherSegment extends StatelessWidget {
  const _SwitcherSegment({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final DomainPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? palette.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Preview Chip ────────────────────────────────────────────────────────────

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
  const _FlashcardBanner({required this.l10n, required this.palette});

  final AppLocalizations l10n;
  final DomainPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: palette.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.primary.withValues(alpha: 0.25)),
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
                  color: palette.primary,
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
                        color: palette.primaryDark,
                      ),
                    ),
                    Text(
                      l10n.startSession,
                      style: AppTypography.caption.copyWith(
                        color: palette.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: palette.primary),
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
