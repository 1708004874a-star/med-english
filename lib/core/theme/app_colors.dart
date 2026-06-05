import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary — deep medical teal
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color primaryLight = Color(0xFFCCFBF1);

  // Accent — warm amber (unexpected contrast against teal)
  static const Color accent = Color(0xFFB45309);
  static const Color accentLight = Color(0xFFFEF3C7);

  // Backgrounds
  static const Color background = Color(0xFFFAFAF9);
  static const Color surface = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1C1917);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textTertiary = Color(0xFFA8A29E);

  // Borders & dividers
  static const Color divider = Color(0xFFE7E5E4);
  static const Color border = Color(0xFFE7E5E4);

  // Semantic
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Body system accent colors (index matches system_id - 1).
  // 0–7: macro organ systems. 8–12: micro (cellular) categories — a cooler
  // violet→cyan family to reinforce the "microscope / lab" mood.
  static const List<Color> systemColors = [
    Color(0xFFEF4444), // 0 Cardiovascular
    Color(0xFF3B82F6), // 1 Respiratory
    Color(0xFF8B5CF6), // 2 Nervous
    Color(0xFFF59E0B), // 3 Digestive
    Color(0xFF10B981), // 4 Musculoskeletal
    Color(0xFFEC4899), // 5 Endocrine
    Color(0xFF06B6D4), // 6 Urinary
    Color(0xFF84CC16), // 7 Integumentary
    Color(0xFF7C3AED), // 8 Cell Structure (micro)
    Color(0xFF6366F1), // 9 Cell Function & Molecular (micro)
    Color(0xFF2563EB), // 10 Genetics & Molecular Biology (micro)
    Color(0xFF0891B2), // 11 Histology (micro)
    Color(0xFF0D9488), // 12 Embryology (micro)
  ];

  static const List<Color> systemColorsLight = [
    Color(0xFFFEE2E2),
    Color(0xFFDBEAFE),
    Color(0xFFEDE9FE),
    Color(0xFFFEF3C7),
    Color(0xFFD1FAE5),
    Color(0xFFFCE7F3),
    Color(0xFFCFFAFE),
    Color(0xFFECFCCB),
    Color(0xFFEDE9FE), // 8 Cell Structure
    Color(0xFFE0E7FF), // 9 Cell Function & Molecular
    Color(0xFFDBEAFE), // 10 Genetics & Molecular Biology
    Color(0xFFCFFAFE), // 11 Histology
    Color(0xFFCCFBF1), // 12 Embryology
  ];

  // Morpheme chip colors for word decomposition visualization
  static const List<Color> morphemeColors = [
    Color(0xFF0F766E), // prefix — teal
    Color(0xFFB45309), // root — amber
    Color(0xFF7C3AED), // suffix — violet
    Color(0xFF059669), // extra — emerald
  ];

  static const List<Color> morphemeColorsLight = [
    Color(0xFFCCFBF1),
    Color(0xFFFEF3C7),
    Color(0xFFEDE9FE),
    Color(0xFFD1FAE5),
  ];
}
