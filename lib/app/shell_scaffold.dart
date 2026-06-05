import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../core/theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: l10n.tabVocabulary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article, color: AppColors.primary),
            label: l10n.tabKnowledge,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark, color: AppColors.primary),
            label: l10n.tabNotebook,
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
