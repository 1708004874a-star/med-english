# MedEnglish — 医英通

> 一款帮助中文用户学习**医学英语**的 Flutter 教育应用：词根词缀、单词卡、解剖图文、自测题库，全程中英双语。
>
> A bilingual (中文 / English) Flutter education app for learning **medical English** through word roots, flashcards, anatomy articles, and quizzes.

**应用分类 / Category**：教育 · 语言学习（Education · Language Learning）
**包名 / Bundle ID**：`com.longyuhan.medenglish`

---

## 📥 下载与安装 / Download & Install

### 📱 安卓 / Android

最新版安装包可在 GitHub Releases 页面下载：
The latest APK is available on the GitHub Releases page:

<a href="https://github.com/1708004874a-star/med-english/releases/latest">
  <img src="docs/download-qr.png" alt="下载二维码 / Download QR" width="160">
</a>

**👉 下载链接 / Download link**：<https://github.com/1708004874a-star/med-english/releases/latest>

下载文件名为 `app-release.apk`。
The file to download is named `app-release.apk`.

#### 详细安装教程（安卓）

> 安卓手机默认不允许安装应用商店以外的安装包，需要手动允许一次。以下步骤一次设置后，以后更新都不必再设。

1. **下载安装包**
   用**手机自带浏览器**（如 Chrome、华为浏览器、小米浏览器等）打开上面的下载链接，点击 `app-release.apk` 下载。
   - 微信 / QQ 内置浏览器可能拦截下载，建议复制链接到系统浏览器打开。

2. **打开安装包**
   下载完成后，在通知栏或「文件管理 → Download」里点击 `app-release.apk`。

3. **允许安装未知来源应用**（仅首次需要）
   系统会提示「为了安全，禁止安装未知来源应用」或「此来源的应用不被允许安装」。
   - 点击提示中的「**设置**」→ 打开「**允许来自此来源的应用**」开关 → 返回。
   - 不同品牌路径略有差异：
     - **华为 / 荣耀**：设置 → 安全 → 更多安全设置 → 安装外部来源应用 → 选择浏览器 → 允许
     - **小米 / Redmi**：弹窗点「设置」→ 允许这个来源
     - **OPPO / vivo / 一加**：弹窗点「去设置」→ 允许安装

4. **完成安装**
   返回后再次点击安装包 → 点「**安装**」→「**打开**」。

5. **若提示 Play Protect 扫描**
   点「**仍然安装 / 继续**」即可。本应用为开源自签名安装包，不含任何收费或广告内容。

#### 常见问题（安卓）

| 问题 | 解决办法 |
|---|---|
| 下载被微信/QQ拦截 | 复制链接，用系统浏览器打开下载 |
| 提示「无法安装」「解析包错误」 | 重新下载（可能未下载完整）；确认手机为安卓 5.0 以上 |
| 提示「应用未安装」 | 先卸载旧版本再安装新版本 |
| 找不到下载的文件 | 在「文件管理 → 内部存储 → Download」中查找 |

#### 鸿蒙 HarmonyOS 用户请注意

- **HarmonyOS 4 及更早**（兼容安卓）：可直接按上面的步骤安装 APK。
- **HarmonyOS NEXT / 5.0「纯血鸿蒙」**：不再兼容安卓 APK，暂时**无法安装**本应用。

---

### 🍎 苹果 / iOS

iOS 版本目前使用免费个人开发者证书签名，只能安装在开发者本人的设备上。
若要分发到其他 iPhone，需要付费的 Apple Developer 账号（TestFlight）。
开发者可本地构建运行：

The iOS build is signed with a free personal Apple ID and can only run on the
developer's own device. Distributing to other iPhones requires a paid Apple
Developer account (TestFlight). To build locally:

```bash
flutter build ios --release
```

> ℹ️ iOS 26 及 ProMotion 高刷机型（如 iPhone 17 Pro）的原生工程做了专门适配，
> 详见 `CLAUDE.md` 的「iOS native setup」一节。

---

## ✨ 功能 / Features

| 功能 | 说明 / Description |
|---|---|
| **词根词缀 / Word Roots & Affixes** | 131 个词素（前缀 / 词根 / 后缀），中英双语释义 |
| **医学词汇 / Medical Vocabulary** | 8 大人体系统、348 个术语，含 IPA 音标与语音朗读（TTS） |
| **单词卡 / Flashcard Study** | 3D 翻转卡片，可左右滑动连续学习；「需复习」自动存入笔记本 |
| **知识库 / Knowledge Base** | 48 篇中英双语解剖图文（OpenStax CC-BY 4.0） |
| **自测题库 / Self-Test Quiz** | 479 道选择题，即时反馈与解析，错题自动收录 |
| **笔记本 / Notebook** | 收藏单词、添加笔记、标记掌握程度、按状态筛选 |
| **全双语界面 / Bilingual UI** | 简体中文 / English，跟随系统语言 |

---

## 🛠️ 开发者构建 / Build from Source

### 环境要求 / Prerequisites

```bash
brew install --cask flutter
flutter doctor   # 检查工具链 / verify toolchain
```

### 克隆与运行 / Clone & run

```bash
git clone https://github.com/1708004874a-star/med-english.git
cd med-english

flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 生成数据库代码 / generate DB code
flutter run
```

### 打包安卓 APK / Build the Android APK

```bash
flutter build apk --release
# 产物 / output: build/app/outputs/flutter-apk/app-release.apk
```

> 首次启动时数据库会自动从内置 JSON 资源初始化，无需后端或联网。
> The database is seeded automatically on first launch from bundled JSON assets — no backend or network required.

---

## 🧱 技术栈 / Tech Stack

| 层 / Layer | 库 / Library |
|---|---|
| 框架 / Framework | Flutter 3.x |
| 状态管理 / State | flutter_riverpod 2.x |
| 路由 / Navigation | go_router 14.x |
| 数据库 / Database | drift (SQLite) |
| 本地化 / Localization | flutter_localizations + intl |
| 语音 / TTS | flutter_tts |
| 字体 / Fonts | google_fonts (DM Serif Display, DM Sans, Space Mono) |

---

## 📚 数据来源 / Data Sources

所有内容均来自开放、可自由再利用的来源：
All content comes from open, freely reusable sources:

- **词素 / Morphemes** — 语言学事实，无版权限制 / linguistic facts, no copyright
- **医学术语 / Medical terminology** — [NLM MeSH](https://www.nlm.nih.gov/mesh/)（美国政府公有领域 / public domain, US Government work）
- **解剖内容 / Anatomy content** — [OpenStax Anatomy & Physiology](https://openstax.org/details/books/anatomy-and-physiology-2e)（CC-BY 4.0）
- **题库 / Quiz questions** — 由以上来源衍生 / derived from the above

---

## ⚠️ 免责声明 / Disclaimer

本应用**仅用于教育与语言学习目的**，不提供医学诊断、治疗建议或专业医疗意见。如有任何健康问题，请咨询合格的医疗专业人员。

This app is for **educational and language-learning purposes only**. It does not
provide medical diagnosis, treatment advice, or professional medical opinion.
Always consult a qualified healthcare professional for any medical concerns.

---

## 📄 许可证 / License

MIT — 详见 / see [LICENSE](LICENSE)
