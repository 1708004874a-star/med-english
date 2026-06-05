import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_english/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../data/providers.dart';
import '../data/settings_providers.dart';
import 'router.dart';

class MedEnglishApp extends ConsumerWidget {
  const MedEnglishApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'MedEnglish',
      theme: AppTheme.light,
      locale: locale,
      routerConfig: appRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
      ],
      builder: (context, child) {
        return initState.when(
          loading: () => const _SplashScreen(),
          error: (_, __) => child!,
          data: (_) => child!,
        );
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F766E),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.medical_services_outlined, size: 64, color: Colors.white),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
