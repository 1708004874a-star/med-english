import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/locale_utils.dart';
import '../../../../domain/entities/body_system.dart';
import '../viewmodels/knowledge_providers.dart';

// Maps icon_name (from DB) → Material icon
final _iconMap = <String, IconData>{
  'heart': Icons.favorite,
  'lungs': Icons.air,
  'brain': Icons.psychology,
  'stomach': Icons.bubble_chart,
  'bone': Icons.sports_gymnastics,
  'gland': Icons.biotech,
  'kidney': Icons.water_drop,
  'skin': Icons.spa,
};

class SystemsGridScreen extends ConsumerWidget {
  const SystemsGridScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final systemsAsync = ref.watch(knowledgeSystemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.knowledgeTitle)),
      backgroundColor: AppColors.background,
      body: systemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.errorGeneric)),
        data: (systems) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: systems.length,
          itemBuilder: (context, i) => _SystemCard(
            system: systems[i],
            onTap: () =>
                context.push('/knowledge/${systems[i].id}'),
          ),
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.system, required this.onTap});

  final BodySystem system;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final idx = (system.id - 1).clamp(0, 7);
    final color = AppColors.systemColors[idx];
    final bgColor = AppColors.systemColorsLight[idx];
    final icon = _iconMap[system.iconName] ?? Icons.medical_services;
    final name =
        LocaleUtils.pick(context, en: system.nameEn, zh: system.nameZh);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 26),
              ),

              const Spacer(),

              Text(
                name,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 17,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Text(
                    '3 articles',
                    style: AppTypography.caption,
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 11, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
