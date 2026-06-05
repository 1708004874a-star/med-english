# MedEnglish — 医英通

A Flutter education app for learning medical English vocabulary through word roots, flashcards, anatomy articles, and quizzes.

**App Store category**: Education — Language Learning  
**Bundle ID**: `com.longyuhan.medenglish`

## Features

- **Word Roots & Affixes** — 50 morphemes (prefixes, roots, suffixes) with bilingual meanings
- **Medical Vocabulary** — 100 terms across 8 body systems with IPA pronunciation and TTS
- **Flashcard Study** — 3D flip cards with spaced study sessions
- **Knowledge Base** — 24 bilingual anatomy articles (OpenStax CC-BY 4.0)
- **Self-Test Quiz** — Multiple-choice with instant feedback and explanations
- **Notebook** — Save words, add personal notes, track mastery level
- **Full bilingual UI** — English / Simplified Chinese, follows system locale

## Setup

### Prerequisites

```bash
brew install --cask flutter
flutter doctor   # verify iOS toolchain
```

### Install & run

```bash
git clone https://github.com/longyuhan/med-english.git
cd med-english

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d "iPhone 16"
```

> The database is seeded automatically on first launch from the bundled JSON assets. No backend or network access required.

## Tech stack

| Layer | Library |
|---|---|
| Framework | Flutter 3.x |
| State | flutter_riverpod 2.x |
| Navigation | go_router 14.x |
| Database | drift (SQLite) |
| Localization | flutter_localizations + intl |
| TTS | flutter_tts |
| Fonts | google_fonts (DM Serif Display, DM Sans, Space Mono) |

## Data sources

All content is from open, freely reusable sources:

- **Morphemes** — Linguistic facts; no copyright restriction
- **Medical terminology** — [NLM MeSH](https://www.nlm.nih.gov/mesh/) (public domain, US Government work)
- **Anatomy content** — [OpenStax Anatomy & Physiology](https://openstax.org/details/books/anatomy-and-physiology-2e) (CC-BY 4.0)
- **Quiz questions** — Derived from the above

## Disclaimer

This app is for **educational and language learning purposes only**. It does not provide medical diagnosis, treatment advice, or professional medical opinion. Always consult a qualified healthcare professional for any medical concerns.

## License

MIT — see [LICENSE](LICENSE)
