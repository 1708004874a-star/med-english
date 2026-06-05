import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/settings_providers.dart';
import '../constants/db_constants.dart';
import 'app_colors.dart';

/// Theme colours that change with the active knowledge domain.
///
/// *macro* keeps the existing teal identity; *micro* adopts a violet-blue
/// "laboratory" palette for quick visual distinction.
class DomainPalette {
  const DomainPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.gradientStart,
    required this.gradientEnd,
    required this.surfaceLight,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color gradientStart;
  final Color gradientEnd;
  final Color surfaceLight;

  static const _macro = DomainPalette(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryLight: AppColors.primaryLight,
    gradientStart: Color(0xFF0F766E),
    gradientEnd: Color(0xFF134E4A),
    surfaceLight: Color(0xFFF0FDFA),
  );

  static const _micro = DomainPalette(
    primary: Color(0xFF6D28D9),
    primaryDark: Color(0xFF5B21B6),
    primaryLight: Color(0xFFEDE9FE),
    gradientStart: Color(0xFF5B21B6),
    gradientEnd: Color(0xFF312E81),
    surfaceLight: Color(0xFFF5F3FF),
  );
}

/// Derives the active palette from [domainProvider].
final domainPaletteProvider = Provider<DomainPalette>((ref) {
  final domain = ref.watch(domainProvider);
  return domain == AppDomain.micro ? DomainPalette._micro : DomainPalette._macro;
});
