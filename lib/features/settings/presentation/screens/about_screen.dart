import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/language_picker.dart';
import '../../../../data/settings_providers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final languageLabel = switch (locale?.languageCode) {
      'en' => 'English',
      'zh' => '中文',
      _ => l10n.languageFollowSystem,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App identity block
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text('MedEnglish',
                      style: AppTypography.display.copyWith(fontSize: 26)),
                  const SizedBox(height: 4),
                  Text(l10n.appTagline, style: AppTypography.subtitle),
                  const SizedBox(height: 4),
                  Text(l10n.aboutAppVersion('1.0.0'),
                      style: AppTypography.caption),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Language setting section
            _SectionHeader(title: l10n.languageSettingTitle),
            const SizedBox(height: 8),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showLanguagePicker(context, ref),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(languageLabel, style: AppTypography.body),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.black38),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Disclaimer section
            _SectionHeader(title: l10n.disclaimerTitle),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.accent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l10n.disclaimerBody,
                        style: AppTypography.bodySmall),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Data sources section
            _SectionHeader(title: l10n.dataSourcesTitle),
            const SizedBox(height: 8),
            Text(l10n.dataSourcesBody, style: AppTypography.body),
            const SizedBox(height: 12),
            _SourceTile(
              icon: Icons.school_outlined,
              label: l10n.openStaxCredit,
            ),
            const SizedBox(height: 8),
            _SourceTile(
              icon: Icons.local_hospital_outlined,
              label: l10n.meshCredit,
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.headline.copyWith(fontSize: 18));
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppTypography.bodySmall)),
      ],
    );
  }
}
