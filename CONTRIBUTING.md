# Contributing to MedEnglish

## Development setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

## Adding vocabulary data

Edit `assets/data/vocabulary.json`. Follow the existing schema:

```json
{
  "id": 101,
  "word": "tachycardia",
  "ipa": "/ˌtæk.ɪˈkɑːr.di.ə/",
  "def_en": "Abnormally rapid heart rate, typically over 100 beats per minute",
  "def_zh": "心动过速",
  "example_en": "Exercise-induced tachycardia is normal.",
  "example_zh": "运动引起的心动过速是正常的。",
  "system_id": 1,
  "difficulty": 3,
  "morpheme_ids": [1, 29]
}
```

**Data source requirement**: Only use NLM MeSH terms (public domain) or original definitions. Cite the source in a comment if non-obvious.

## Adding morphemes

Edit `assets/data/morphemes.json`:

```json
{
  "id": 51,
  "morpheme": "tachy-",
  "type": "prefix",
  "meaning_zh": "快速",
  "meaning_en": "rapid, fast",
  "origin": "Greek"
}
```

## Code style

- No comments unless the WHY is non-obvious
- No trailing summary comments
- Screens extend `ConsumerWidget` or `ConsumerStatefulWidget`
- Providers live in `*_providers.dart` files, not inside screens
- Use `LocaleUtils.pick(context, en:, zh:)` for bilingual strings
- Use `BilingualText` widget for bilingual body text in lists

## App Store compliance

Never add content that could be interpreted as:
- Medical diagnosis or clinical advice
- Treatment recommendations
- Drug or dosage information

The disclaimer shown on first launch and in the About screen must always be present and unmodified.

## PR checklist

- [ ] `flutter analyze` passes with no warnings
- [ ] `flutter test` passes
- [ ] Bilingual strings added to both `app_en.arb` and `app_zh.arb`
- [ ] New seed data validated (no duplicate IDs, valid `system_id` 1–8, valid `morpheme_ids`)
- [ ] No diagnostic / treatment language added
