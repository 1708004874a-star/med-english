# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Generate drift DB code (required after any Table/DAO change)
dart run build_runner build --delete-conflicting-outputs

# Generate l10n code (required after editing .arb files)
flutter gen-l10n

# Analyze
flutter analyze

# Test
flutter test

# Run on iOS simulator
flutter run -d "iPhone 16"

# Release build (no code signing, for CI verification)
flutter build ios --release --no-codesign
```

## Architecture

**Clean Architecture** with three layers:

```
lib/
├── core/            # Theme, constants, shared widgets, utilities
├── data/            # Drift tables, DAOs, repositories (impls), seed, providers
├── domain/          # Entities, repository interfaces (I*Repository)
└── features/        # Feature modules (home, vocabulary, flashcard, knowledge, quiz, notebook, settings)
    └── <feature>/presentation/
        ├── screens/         # ConsumerWidget / ConsumerStatefulWidget screens
        ├── viewmodels/      # *_providers.dart (FutureProvider, StreamProvider, StateProvider)
        └── widgets/         # Feature-specific reusable widgets
```

**State management**: `flutter_riverpod` — all providers in `lib/data/providers.dart` (DB + repositories) and per-feature `viewmodels/*_providers.dart`.

**Navigation**: `go_router` with `StatefulShellRoute.indexedStack` (4 tabs: Home, Vocabulary, Knowledge, Notebook). Flashcard and Quiz are full-screen routes outside the shell.

**Database**: drift (SQLite). Tables in `lib/data/models/`. DAOs in `lib/data/database/daos/`. Generated files (`*.g.dart`) are git-ignored — always run `build_runner` after checkout.

**Seed data**: `lib/data/seed/db_seeder.dart` runs once on first launch (checks `kDbSeededKey` in SharedPreferences). JSON assets in `assets/data/`.

**Localization**: ARB files in `lib/l10n/`. Generated `AppLocalizations` accessed via `AppLocalizations.of(context)!`. Bilingual content uses `LocaleUtils.pick(context, en:, zh:)` or `BilingualText` widget.

## Key files

| Concern | File |
|---|---|
| App entry | `lib/main.dart` |
| MaterialApp + init | `lib/app/app.dart` |
| Route definitions | `lib/app/router.dart` |
| Bottom nav shell | `lib/app/shell_scaffold.dart` |
| DB init + seeder provider | `lib/data/providers.dart` (`appInitProvider`) |
| Drift DB class | `lib/data/database/app_database.dart` |
| Color palette | `lib/core/theme/app_colors.dart` |
| Typography | `lib/core/theme/app_typography.dart` |
| TTS utility | `lib/core/utils/tts_helper.dart` |
| Disclaimer dialog | `lib/core/widgets/disclaimer_banner.dart` |

## Naming conflicts (drift vs domain)

Drift generates data classes with the same names as domain entities (e.g., `KnowledgeArticle`, `BodySystem`, `QuizQuestion`). Repository impl files resolve this by aliasing the domain entity import:

```dart
import '../../domain/entities/knowledge_article.dart' as entity;
// drift-generated KnowledgeArticle is unaliased; entity.KnowledgeArticle is the domain class
```

## App Store compliance

The app is categorized as **Education**, not Medical. Never add:
- Diagnostic / treatment advice language
- Health & Fitness claims
- References to prescribing or clinical use

The disclaimer (shown on first launch and in About) must always be present.

## Data sources

- Word roots: linguistic facts, no copyright
- Medical vocabulary: NLM MeSH (public domain, US government)
- Anatomy articles: OpenStax Anatomy & Physiology (CC-BY 4.0)
- Quiz questions: derived from above sources
