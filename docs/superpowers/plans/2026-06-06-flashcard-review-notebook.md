# Flashcard Review → Notebook Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tapping "需复习" on a flashcard saves the word to the notebook at `MasteryLevel.learning`; the notebook gains interactive mastery editing (bottom sheet) and filter chips (All / Needs Review / Mastered).

**Architecture:** New `upsertAsLearning` repository method handles insert-or-update in one call. The flashcard screen calls it and shows a Snackbar. The notebook screen adds a `StateProvider<NotebookFilter>` for client-side filtering and upgrades `_MasteryChip` to open a `showModalBottomSheet` for level selection.

**Tech Stack:** Flutter, Riverpod (StateProvider, StreamProvider), Drift (in-memory for tests), flutter_test

---

## File Map

| File | Change |
|---|---|
| `lib/l10n/app_en.arb` | Add 10 new string keys |
| `lib/l10n/app_zh.arb` | Add 10 new string keys |
| `lib/domain/repositories/i_notebook_repository.dart` | Add `upsertAsLearning(int vocabId)` |
| `lib/data/repositories/notebook_repository_impl.dart` | Implement `upsertAsLearning` |
| `test/data/notebook_repository_test.dart` | Unit tests for `upsertAsLearning` |
| `lib/features/flashcard/presentation/screens/flashcard_session_screen.dart` | `_onReview` calls `upsertAsLearning` + Snackbar |
| `lib/features/notebook/presentation/viewmodels/notebook_providers.dart` | Add `NotebookFilter` enum + `notebookFilterProvider` |
| `lib/features/notebook/presentation/screens/notebook_list_screen.dart` | Filter chips, interactive mastery chip, mastery bottom sheet, top-level helpers |

---

## Task 1: Localization — Add New String Keys

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_zh.arb`

- [ ] **Step 1: Add keys to `app_en.arb`**

In `lib/l10n/app_en.arb`, insert after the `"backToVocab"` entry:

```json
  "savedToNotebook": "Added to notebook",
  "@savedToNotebook": { "description": "Snackbar shown when a word is saved to notebook from flashcard" },
```

Then insert after the `"masteryLevel"` entry (near the notebook section):

```json
  "setMasteryTitle": "Set Mastery Level",
  "@setMasteryTitle": { "description": "Bottom sheet title for mastery level picker in notebook" },

  "filterAll": "All",
  "@filterAll": { "description": "Notebook filter chip: show all entries" },

  "filterNeedsReview": "Needs Review",
  "@filterNeedsReview": { "description": "Notebook filter chip: show learning entries" },

  "filterMastered": "Mastered",
  "@filterMastered": { "description": "Notebook filter chip: show mastered entries" },

  "masteryUnseen": "Unseen",
  "@masteryUnseen": { "description": "Mastery level label" },

  "masteryLearning": "Learning",
  "@masteryLearning": { "description": "Mastery level label" },

  "masteryFamiliar": "Familiar",
  "@masteryFamiliar": { "description": "Mastery level label" },

  "masteryProficient": "Proficient",
  "@masteryProficient": { "description": "Mastery level label" },

  "masteryMastered": "Mastered",
  "@masteryMastered": { "description": "Mastery level label" },
```

- [ ] **Step 2: Add keys to `app_zh.arb`**

In `lib/l10n/app_zh.arb`, insert after `"backToVocab"`:

```json
  "savedToNotebook": "已加入生词本",
```

Insert after `"masteryLevel"`:

```json
  "setMasteryTitle": "设置掌握程度",
  "filterAll": "全部",
  "filterNeedsReview": "待复习",
  "filterMastered": "已掌握",
  "masteryUnseen": "未接触",
  "masteryLearning": "待复习",
  "masteryFamiliar": "熟悉",
  "masteryProficient": "熟练",
  "masteryMastered": "已掌握",
```

- [ ] **Step 3: Regenerate l10n**

```bash
flutter gen-l10n
```

Expected: no errors, updated files in `lib/l10n/`.

- [ ] **Step 4: Verify compile**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/l10n/
git commit -m "feat: add mastery/filter/savedToNotebook l10n keys"
```

---

## Task 2: Repository — Add `upsertAsLearning`

**Files:**
- Modify: `lib/domain/repositories/i_notebook_repository.dart`
- Modify: `lib/data/repositories/notebook_repository_impl.dart`
- Create: `test/data/notebook_repository_test.dart`

- [ ] **Step 1: Write the failing tests**

Create `test/data/notebook_repository_test.dart`:

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_english/core/constants/db_constants.dart';
import 'package:med_english/data/database/app_database.dart';
import 'package:med_english/data/repositories/notebook_repository_impl.dart';

void main() {
  late AppDatabase db;
  late NotebookRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = NotebookRepositoryImpl(db);
  });

  tearDown(() => db.close());

  group('upsertAsLearning', () {
    test('inserts a new entry with MasteryLevel.learning when vocabId not in notebook', () async {
      await repo.upsertAsLearning(99);
      final row = await db.notebookDao.getByVocabId(99);
      expect(row, isNotNull);
      expect(row!.masteryLevel, equals(MasteryLevel.learning.value));
    });

    test('updates mastery to learning when entry already exists at unseen', () async {
      await repo.addEntry(42);
      await repo.upsertAsLearning(42);
      final row = await db.notebookDao.getByVocabId(42);
      expect(row!.masteryLevel, equals(MasteryLevel.learning.value));
    });

    test('downgrades mastery to learning when entry already exists at mastered', () async {
      await repo.addEntry(7);
      final existing = await db.notebookDao.getByVocabId(7);
      await db.notebookDao.updateMastery(existing!.id, MasteryLevel.mastered.value);
      await repo.upsertAsLearning(7);
      final updated = await db.notebookDao.getByVocabId(7);
      expect(updated!.masteryLevel, equals(MasteryLevel.learning.value));
    });

    test('does not create a duplicate entry when called twice', () async {
      await repo.upsertAsLearning(55);
      await repo.upsertAsLearning(55);
      final all = await db.notebookDao.getAll();
      expect(all.where((r) => r.vocabId == 55).length, equals(1));
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/data/notebook_repository_test.dart
```

Expected: compilation error — `upsertAsLearning` not defined.

- [ ] **Step 3: Add method to the interface**

In `lib/domain/repositories/i_notebook_repository.dart`, add:

```dart
abstract interface class INotebookRepository {
  Stream<List<NotebookEntry>> watchAll();
  Future<bool> isInNotebook(int vocabId);
  Future<void> addEntry(int vocabId);
  Future<void> removeEntry(int vocabId);
  Future<void> updateNote(int entryId, String note);
  Future<void> updateMastery(int entryId, MasteryLevel level);
  Future<void> upsertAsLearning(int vocabId);  // ← new
}
```

- [ ] **Step 4: Implement in the repository**

In `lib/data/repositories/notebook_repository_impl.dart`, add after `updateMastery`:

```dart
  @override
  Future<void> upsertAsLearning(int vocabId) async {
    final existing = await _db.notebookDao.getByVocabId(vocabId);
    if (existing == null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db.notebookDao.addEntry(
        UserNotebookCompanion.insert(vocabId: vocabId, addedAt: now),
      );
      final created = await _db.notebookDao.getByVocabId(vocabId);
      await _db.notebookDao.updateMastery(
          created!.id, MasteryLevel.learning.value);
    } else {
      await _db.notebookDao.updateMastery(
          existing.id, MasteryLevel.learning.value);
    }
  }
```

- [ ] **Step 5: Run tests to verify they pass**

```bash
flutter test test/data/notebook_repository_test.dart
```

Expected: 4 tests pass.

- [ ] **Step 6: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/domain/repositories/i_notebook_repository.dart \
        lib/data/repositories/notebook_repository_impl.dart \
        test/data/notebook_repository_test.dart
git commit -m "feat: add upsertAsLearning to notebook repository"
```

---

## Task 3: Flashcard — Wire `_onReview` to `upsertAsLearning` + Snackbar

**Files:**
- Modify: `lib/features/flashcard/presentation/screens/flashcard_session_screen.dart`

- [ ] **Step 1: Add import**

At the top of `flashcard_session_screen.dart`, add:

```dart
import '../../../../data/providers.dart';
```

- [ ] **Step 2: Replace `_onReview` with async version**

Replace the existing `_onReview` method:

```dart
// OLD
void _onReview(List<Vocabulary> cards) {
  setState(() => _currentIndex++);
  if (_currentIndex >= cards.length) {
    _navigateToComplete(cards.length);
  } else {
    _speakCurrent(cards);
  }
}
```

With:

```dart
Future<void> _onReview(List<Vocabulary> cards) async {
  final vocab = cards[_currentIndex];
  await ref.read(notebookRepositoryProvider).upsertAsLearning(vocab.id);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.savedToNotebook),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  setState(() => _currentIndex++);
  if (_currentIndex >= cards.length) {
    _navigateToComplete(cards.length);
  } else {
    _speakCurrent(cards);
  }
}
```

- [ ] **Step 3: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/features/flashcard/presentation/screens/flashcard_session_screen.dart
git commit -m "feat: save word to notebook on flashcard needs-review tap"
```

---

## Task 4: Notebook — Filter Chips

**Files:**
- Modify: `lib/features/notebook/presentation/viewmodels/notebook_providers.dart`
- Modify: `lib/features/notebook/presentation/screens/notebook_list_screen.dart`

- [ ] **Step 1: Add `NotebookFilter` enum and provider**

Replace the full contents of `lib/features/notebook/presentation/viewmodels/notebook_providers.dart` with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers.dart';
import '../../../../domain/entities/notebook_entry.dart';

enum NotebookFilter { all, needsReview, mastered }

final notebookFilterProvider =
    StateProvider<NotebookFilter>((_) => NotebookFilter.all);

final notebookStreamProvider = StreamProvider<List<NotebookEntry>>((ref) {
  return ref.watch(notebookRepositoryProvider).watchAll();
});
```

- [ ] **Step 2: Add `_FilterChipBar` widget and filtering logic to `notebook_list_screen.dart`**

At the bottom of `notebook_list_screen.dart` (after `_MasteryChip`), add:

```dart
class _FilterChipBar extends StatelessWidget {
  const _FilterChipBar({required this.selected, required this.onChanged});

  final NotebookFilter selected;
  final ValueChanged<NotebookFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = [
      (NotebookFilter.all, l10n.filterAll),
      (NotebookFilter.needsReview, l10n.filterNeedsReview),
      (NotebookFilter.mastered, l10n.filterMastered),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: chips.map((item) {
          final (filter, label) = item;
          final isSelected = selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onChanged(filter),
              selectedColor: AppColors.primaryLight,
              checkmarkColor: AppColors.primary,
              labelStyle: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 3: Update `NotebookListScreen.build` to apply filter**

In `NotebookListScreen.build`, change the `data: (entries)` branch from:

```dart
data: (entries) {
  if (entries.isEmpty) {
    return Center(
      child: Padding( ... ) // existing empty state
    );
  }

  return ListView.separated(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
    ...
  );
},
```

To:

```dart
data: (entries) {
  if (entries.isEmpty) {
    return Center(
      child: Padding( ... ) // existing empty state — unchanged
    );
  }

  final filter = ref.watch(notebookFilterProvider);
  final filtered = switch (filter) {
    NotebookFilter.all => entries,
    NotebookFilter.needsReview => entries
        .where((e) => e.masteryLevel == MasteryLevel.learning)
        .toList(),
    NotebookFilter.mastered => entries
        .where((e) => e.masteryLevel == MasteryLevel.mastered)
        .toList(),
  };

  return Column(
    children: [
      _FilterChipBar(
        selected: filter,
        onChanged: (f) =>
            ref.read(notebookFilterProvider.notifier).state = f,
      ),
      Expanded(
        child: filtered.isEmpty
            ? Center(child: Text(AppLocalizations.of(context)!.noResults))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _NotebookEntryCard(
                  entry: filtered[i],
                  onTap: () =>
                      context.push('/vocabulary/${filtered[i].vocabId}'),
                  onDelete: () async {
                    await ref
                        .read(notebookRepositoryProvider)
                        .removeEntry(filtered[i].vocabId);
                    ref.invalidate(
                        isInNotebookProvider(filtered[i].vocabId));
                  },
                ),
              ),
      ),
    ],
  );
},
```

Also add the missing import at the top of `notebook_list_screen.dart`:

```dart
import '../viewmodels/notebook_providers.dart';
```

(It should already be there — verify.)

- [ ] **Step 4: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add lib/features/notebook/presentation/viewmodels/notebook_providers.dart \
        lib/features/notebook/presentation/screens/notebook_list_screen.dart
git commit -m "feat: add notebook filter chips (all/needs-review/mastered)"
```

---

## Task 5: Notebook — Interactive Mastery Chip + Bottom Sheet

**Files:**
- Modify: `lib/features/notebook/presentation/screens/notebook_list_screen.dart`

- [ ] **Step 1: Add top-level helper functions**

At the top of `notebook_list_screen.dart` (before the class definitions, after imports), add:

```dart
String _masteryLabel(AppLocalizations l10n, MasteryLevel level) =>
    switch (level) {
      MasteryLevel.unseen => l10n.masteryUnseen,
      MasteryLevel.learning => l10n.masteryLearning,
      MasteryLevel.familiar => l10n.masteryFamiliar,
      MasteryLevel.proficient => l10n.masteryProficient,
      MasteryLevel.mastered => l10n.masteryMastered,
    };

Color _masteryColor(MasteryLevel level) => const [
      AppColors.textTertiary,
      Color(0xFF3B82F6),
      AppColors.accent,
      Color(0xFF10B981),
      AppColors.primary,
    ][level.index];
```

- [ ] **Step 2: Add `_showMasterySheet` method to `_NotebookEntryCard`**

Inside the `_NotebookEntryCard` class, add after the `_formatDate` method:

```dart
  void _showMasterySheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.setMasteryTitle, style: AppTypography.title),
            const SizedBox(height: 8),
            ...MasteryLevel.values.map((level) {
              final color = _masteryColor(level);
              return ListTile(
                leading: Icon(
                  entry.masteryLevel == level
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: color,
                ),
                title: Text(_masteryLabel(l10n, level)),
                onTap: () async {
                  await ref
                      .read(notebookRepositoryProvider)
                      .updateMastery(entry.id, level);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
```

- [ ] **Step 3: Update `_MasteryChip` to accept `onTap` and use l10n labels**

Replace the entire `_MasteryChip` class with:

```dart
class _MasteryChip extends StatelessWidget {
  const _MasteryChip({required this.level, this.onTap});

  final MasteryLevel level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _masteryColor(level);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _masteryLabel(l10n, level),
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 2),
              Icon(Icons.expand_more, size: 12, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Pass `onTap` to `_MasteryChip` in `_NotebookEntryCard.build`**

Find the line:

```dart
_MasteryChip(level: entry.masteryLevel),
```

Replace with:

```dart
_MasteryChip(
  level: entry.masteryLevel,
  onTap: () => _showMasterySheet(context, ref),
),
```

- [ ] **Step 5: Analyze**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/features/notebook/presentation/screens/notebook_list_screen.dart
git commit -m "feat: interactive mastery chip with bottom sheet in notebook"
```

---

## Final Verification

- [ ] Run all tests

```bash
flutter test
```

Expected: all pass.

- [ ] Manual smoke test checklist:
  1. Open flashcard session → tap "需复习" on a card → Snackbar "已加入生词本" appears → go to notebook → word is there with "Learning" tag
  2. Tap the same word again in flashcard "需复习" → no duplicate in notebook, still "Learning"
  3. In notebook, tap the "Learning" chip → bottom sheet opens with 5 options → select "Mastered" → chip updates
  4. Filter chips: tap "待复习" → only Learning entries show; tap "已掌握" → only Mastered; tap "全部" → all
  5. If filter is "待复习" and no learning entries → shows "未找到相关内容" (noResults)
