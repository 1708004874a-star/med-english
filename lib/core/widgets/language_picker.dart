import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../../data/settings_providers.dart';
import '../theme/app_colors.dart';

/// The user-selectable UI languages. `null` locale = follow the system.
const _languageOptions = <(Locale?, String)>[
  (null, ''), // label resolved from l10n at build time
  (Locale('en'), 'English'),
  (Locale('zh'), '中文'),
];

/// Shows a bottom sheet that lets the user pick the app's interface language.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      final current = ref.read(localeProvider);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                l10n.languageSettingTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
              ),
            ),
            for (final (locale, rawLabel) in _languageOptions)
              _LanguageTile(
                label: locale == null ? l10n.languageFollowSystem : rawLabel,
                selected: current?.languageCode == locale?.languageCode,
                onTap: () {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.primary : null,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : const Icon(Icons.circle_outlined, color: Colors.black26),
      onTap: onTap,
    );
  }
}
