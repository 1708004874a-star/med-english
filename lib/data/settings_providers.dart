import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/db_constants.dart';

/// Provides the [SharedPreferences] instance.
///
/// Overridden in `main()` with the already-loaded instance so the rest of the
/// app can read it synchronously.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

/// Holds the user-selected UI locale.
///
/// `null` means "follow the system language" (the default). When set, the value
/// is persisted and drives [MaterialApp.locale].
final localeProvider =
    NotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(kLocaleKey);
    if (code == null) return null;
    return Locale(code);
  }

  /// Sets the UI locale. Pass `null` to revert to following the system language.
  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(kLocaleKey);
    } else {
      await prefs.setString(kLocaleKey, locale.languageCode);
    }
    state = locale;
  }
}

// ── Domain ────────────────────────────────────────────────────────────────────

/// Holds the currently active knowledge domain (macro or micro).
///
/// Persisted in SharedPreferences so the selection survives restarts. Defaults
/// to [AppDomain.macro] on first launch.
final domainProvider =
    NotifierProvider<DomainNotifier, AppDomain>(DomainNotifier.new);

class DomainNotifier extends Notifier<AppDomain> {
  @override
  AppDomain build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppDomain.fromStorage(prefs.getString(kDomainKey));
  }

  /// Switches the active domain and persists the choice.
  Future<void> setDomain(AppDomain domain) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(kDomainKey, domain.storageValue);
    state = domain;
  }
}
