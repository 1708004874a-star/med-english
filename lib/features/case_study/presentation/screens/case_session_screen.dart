import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../core/widgets/bilingual_text.dart';
import '../../../../domain/entities/clinical_case.dart';
import '../viewmodels/case_providers.dart';
import '../widgets/case_disclaimer_bar.dart';

/// Drives one case through its stages:
///   presentation -> differentials -> N investigation rounds -> final choice.
/// On the final choice the screen pushes the result route.
class CaseSessionScreen extends ConsumerWidget {
  const CaseSessionScreen({super.key, required this.caseId});

  final int caseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final caseAsync = ref.watch(caseByIdProvider(caseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        title: Text(l10n.casesHubTitle, style: AppTypography.title),
      ),
      body: caseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (c) {
          if (c == null) return Center(child: Text(l10n.noResults));
          return Column(
            children: [
              CaseDisclaimerBar(text: l10n.casesDisclaimer),
              Expanded(child: _CaseFlow(clinicalCase: c, l10n: l10n)),
            ],
          );
        },
      ),
    );
  }
}

class _CaseFlow extends StatefulWidget {
  const _CaseFlow({required this.clinicalCase, required this.l10n});

  final ClinicalCase clinicalCase;
  final AppLocalizations l10n;

  @override
  State<_CaseFlow> createState() => _CaseFlowState();
}

/// Stage machine: 0 = presentation, 1 = differentials, then one stage per
/// round, finishing with the final-choice stage.
class _CaseFlowState extends State<_CaseFlow> {
  int _stage = 0;
  final Set<String> _ruledOut = {};
  // Per round: the chosen test id and whether the finding has been revealed.
  final Map<int, String> _chosenTestPerRound = {};

  ClinicalCase get c => widget.clinicalCase;
  int get _roundCount => c.rounds.length;

  // Stage indices: 0 presentation, 1 differentials, 2..(1+roundCount) rounds,
  // (2 + roundCount) final choice.
  int get _finalStage => 2 + _roundCount;

  void _next() => setState(() => _stage++);

  void _chooseTest(int roundIndex, CaseTest test) {
    setState(() {
      _chosenTestPerRound[roundIndex] = test.id;
      _ruledOut.addAll(test.rulesOut);
    });
  }

  void _submitAnswer(Differential pick) {
    final correct = pick.id == c.answerId;
    context.pushReplacement('/cases/result', extra: {
      'caseId': c.id,
      'correct': correct,
      'pickedId': pick.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    if (_stage == 0) {
      return _PresentationStage(clinicalCase: c, l10n: l10n, onNext: _next);
    }
    if (_stage == 1) {
      return _DifferentialsStage(
        clinicalCase: c,
        l10n: l10n,
        ruledOut: _ruledOut,
        onNext: _next,
      );
    }
    if (_stage < _finalStage) {
      final roundIndex = _stage - 2;
      return _RoundStage(
        round: c.rounds[roundIndex],
        differentials: c.differentials,
        l10n: l10n,
        ruledOut: _ruledOut,
        chosenTestId: _chosenTestPerRound[roundIndex],
        onChoose: (t) => _chooseTest(roundIndex, t),
        onContinue: _next,
      );
    }
    return _FinalChoiceStage(
      clinicalCase: c,
      l10n: l10n,
      ruledOut: _ruledOut,
      onPick: _submitAnswer,
    );
  }
}

// ── Stage 0: presentation ─────────────────────────────────────────────────

class _PresentationStage extends StatelessWidget {
  const _PresentationStage({
    required this.clinicalCase,
    required this.l10n,
    required this.onNext,
  });

  final ClinicalCase clinicalCase;
  final AppLocalizations l10n;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final c = clinicalCase;
    return _StageScaffold(
      buttonLabel: l10n.casesDifferentialsLabel,
      onButton: onNext,
      children: [
        Text(
          LocaleUtils.pick(context, en: c.titleEn, zh: c.titleZh),
          style: GoogleFonts.dmSerifDisplay(
              fontSize: 26, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        _SectionLabel(l10n.casesPresentationLabel),
        const SizedBox(height: 8),
        _Panel(
          child: BilingualText(
            en: c.presentationEn,
            zh: c.presentationZh,
            style: AppTypography.body,
          ),
        ),
      ],
    );
  }
}

// ── Stage 1: differentials ────────────────────────────────────────────────

class _DifferentialsStage extends StatelessWidget {
  const _DifferentialsStage({
    required this.clinicalCase,
    required this.l10n,
    required this.ruledOut,
    required this.onNext,
  });

  final ClinicalCase clinicalCase;
  final AppLocalizations l10n;
  final Set<String> ruledOut;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _StageScaffold(
      buttonLabel: l10n.casesOrderTest,
      onButton: onNext,
      children: [
        _SectionLabel(l10n.casesDifferentialsLabel),
        const SizedBox(height: 6),
        Text(l10n.casesDifferentialsIntro,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        for (final d in clinicalCase.differentials)
          _DifferentialCard(
            differential: d,
            ruledOut: ruledOut.contains(d.id),
            l10n: l10n,
          ),
      ],
    );
  }
}

class _DifferentialCard extends StatelessWidget {
  const _DifferentialCard({
    required this.differential,
    required this.ruledOut,
    required this.l10n,
  });

  final Differential differential;
  final bool ruledOut;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final d = differential;
    final name = LocaleUtils.pick(context, en: d.nameEn, zh: d.nameZh);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ruledOut ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ruledOut ? AppColors.border : AppColors.primaryLight,
          width: ruledOut ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ruledOut
                        ? AppColors.textTertiary
                        : AppColors.textPrimary,
                    decoration:
                        ruledOut ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (ruledOut)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(l10n.casesRuledOut,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.error)),
                  ],
                ),
            ],
          ),
          if (!ruledOut) ...[
            const SizedBox(height: 6),
            BilingualText(
              en: d.rationaleEn,
              zh: d.rationaleZh,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Stage: one investigation round ────────────────────────────────────────

class _RoundStage extends StatelessWidget {
  const _RoundStage({
    required this.round,
    required this.differentials,
    required this.l10n,
    required this.ruledOut,
    required this.chosenTestId,
    required this.onChoose,
    required this.onContinue,
  });

  final CaseRound round;
  final List<Differential> differentials;
  final AppLocalizations l10n;
  final Set<String> ruledOut;
  final String? chosenTestId;
  final ValueChanged<CaseTest> onChoose;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final chosen = chosenTestId == null
        ? null
        : round.tests.firstWhere((t) => t.id == chosenTestId);

    return _StageScaffold(
      buttonLabel: chosen == null ? null : l10n.casesContinue,
      onButton: chosen == null ? null : onContinue,
      children: [
        _SectionLabel(l10n.casesOrderTest),
        const SizedBox(height: 12),
        for (final t in round.tests)
          _TestTile(
            test: t,
            selected: t.id == chosenTestId,
            disabled: chosen != null && t.id != chosenTestId,
            onTap: chosen == null ? () => onChoose(t) : null,
          ),
        if (chosen != null) ...[
          const SizedBox(height: 16),
          _SectionLabel(l10n.casesFindingLabel),
          const SizedBox(height: 8),
          _Panel(
            highlight: true,
            child: BilingualText(
              en: chosen.findingEn,
              zh: chosen.findingZh,
              style: AppTypography.body,
            ),
          ),
        ],
      ],
    );
  }
}

class _TestTile extends StatelessWidget {
  const _TestTile({
    required this.test,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final CaseTest test;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final name = LocaleUtils.pick(context, en: test.nameEn, zh: test.nameZh);
    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.science_outlined,
                    size: 20,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(name,
                        style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Final stage: pick the answer ──────────────────────────────────────────

class _FinalChoiceStage extends StatelessWidget {
  const _FinalChoiceStage({
    required this.clinicalCase,
    required this.l10n,
    required this.ruledOut,
    required this.onPick,
  });

  final ClinicalCase clinicalCase;
  final AppLocalizations l10n;
  final Set<String> ruledOut;
  final ValueChanged<Differential> onPick;

  @override
  Widget build(BuildContext context) {
    // The player chooses among the differentials still standing.
    final remaining = clinicalCase.differentials
        .where((d) => !ruledOut.contains(d.id))
        .toList();
    return _StageScaffold(
      children: [
        _SectionLabel(l10n.casesFinalPrompt),
        const SizedBox(height: 12),
        for (final d in remaining)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onPick(d),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleUtils.pick(context,
                              en: d.nameEn, zh: d.nameZh),
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Icon(Icons.arrow_forward,
                          size: 18, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Shared stage chrome ───────────────────────────────────────────────────

class _StageScaffold extends StatelessWidget {
  const _StageScaffold({
    required this.children,
    this.buttonLabel,
    this.onButton,
  });

  final List<Widget> children;
  final String? buttonLabel;
  final VoidCallback? onButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        if (buttonLabel != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButton,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(buttonLabel!,
                    style: AppTypography.button
                        .copyWith(color: Colors.white)),
              ),
            ),
          ),
      ],
    );
  }
}

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

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.highlight = false});
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primaryLight : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: highlight ? AppColors.primary : AppColors.border),
      ),
      child: child,
    );
  }
}
