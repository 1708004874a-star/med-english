# MedEnglish — 医英通

A Flutter education app for learning medical English vocabulary through word roots, flashcards, anatomy articles, and quizzes.

**App Store category**: Education — Language Learning  
**Bundle ID**: `com.longyuhan.medenglish`

## 下载 / Download

### 📱 Android（安卓）

扫码或点击下载最新版 APK，然后在手机上安装。
Scan the QR code or use the link below to download the latest APK.

<a href="https://github.com/1708004874a-star/med-english/releases/latest">
  <img src="docs/download-qr.png" alt="Download QR" width="160">
</a>

**下载链接 / Link**: <https://github.com/1708004874a-star/med-english/releases/latest>

安装步骤 / Install steps:
1. 用手机浏览器打开上面的链接，下载 `app-release.apk`。
2. 点击安装；若提示「未知来源」，允许该来源安装即可。
3. （Play Protect 可能扫描一下，点继续即可。）

> **鸿蒙 HarmonyOS**：HarmonyOS 4 及更早（兼容安卓）可直接安装上面的 APK；
> HarmonyOS NEXT / 5.0「纯血鸿蒙」不支持 APK，暂无法安装。

### 🍎 iOS

iOS builds are signed with a free personal Apple ID and can only be installed on
the developer's own device. Distributing to other iPhones requires a paid Apple
Developer account (TestFlight). Build locally with `flutter build ios --release`.

## Features

- **Word Roots & Affixes** — 131 morphemes (prefixes, roots, suffixes) with bilingual meanings
- **Medical Vocabulary** — 348 terms across 8 body systems with IPA pronunciation and TTS
- **Flashcard Study** — 3D flip cards with spaced study sessions
- **Knowledge Base** — 48 bilingual anatomy articles (OpenStax CC-BY 4.0)
- **Self-Test Quiz** — 479 multiple-choice questions with instant feedback and explanations
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
git clone https://github.com/1708004874a-star/med-english.git
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
