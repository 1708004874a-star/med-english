import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:med_english/data/settings_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('locale defaults to system (null), then switches and persists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    // Defaults to "follow system".
    expect(container.read(localeProvider), isNull);

    // Switching to Chinese updates state and persists the code.
    await container.read(localeProvider.notifier).setLocale(const Locale('zh'));
    expect(container.read(localeProvider)?.languageCode, 'zh');
    expect(prefs.getString('app_locale'), 'zh');

    // Reverting to system clears the stored value.
    await container.read(localeProvider.notifier).setLocale(null);
    expect(container.read(localeProvider), isNull);
    expect(prefs.getString('app_locale'), isNull);
  });

  test('a previously saved locale is restored on launch', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'en'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(localeProvider)?.languageCode, 'en');
  });
}
