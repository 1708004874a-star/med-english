import 'package:flutter/material.dart';

/// Picks the correct string for bilingual content based on current locale.
///
/// Usage:
///   LocaleUtils.pick(context, en: word.definitionEn, zh: word.definitionZh)
abstract final class LocaleUtils {
  static String pick(
    BuildContext context, {
    required String en,
    required String zh,
  }) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'zh' ? zh : en;
  }

  static bool isZh(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'zh';
  }
}
