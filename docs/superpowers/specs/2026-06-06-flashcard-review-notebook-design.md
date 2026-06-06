# Flashcard "需复习" → Notebook Integration

**Date:** 2026-06-06  
**Status:** Approved

## Overview

When a user taps "需复习" on a flashcard, the word is automatically saved to the notebook with mastery level `Learning`. The notebook gains interactive mastery level editing (tap chip → bottom sheet) and a filter chip bar.

## Feature Requirements

### 1. Flashcard `_onReview` Behavior

- If word is **not** in notebook: add it with `MasteryLevel.learning`
- If word **is** in notebook at any level: update mastery to `MasteryLevel.learning`
- Show a Snackbar with an **Undo** button (3-second timeout)
  - Undo: if the word was newly added, remove it; if it was updated, restore previous level
- After Snackbar action, continue to next card as normal

### 2. Notebook — Interactive Mastery Chip

- Tapping the `_MasteryChip` on any notebook entry opens a **Modal Bottom Sheet**
- Bottom sheet lists all 5 levels as a radio-style list with color indicators
- Selecting a level calls `updateMastery(entryId, level)` and closes the sheet
- Levels: Unseen → Learning → Familiar → Proficient → Mastered

### 3. Notebook — Filter Chips

- A horizontal chip bar appears below the AppBar with three options:
  - **全部 / All** — shows all entries (default)
  - **待复习 / Needs Review** — shows entries where `masteryLevel == learning`
  - **已掌握 / Mastered** — shows entries where `masteryLevel == mastered`
- Filter state is held in a local `StateProvider<NotebookFilter>` (not persisted)
- The `notebookStreamProvider` streams all entries; filtering is done client-side

## Architecture

### Repository Layer

Add `upsertAsLearning(int vocabId)` to `INotebookRepository` and `NotebookRepositoryImpl`:

```dart
Future<MasteryLevel?> upsertAsLearning(int vocabId);
// Returns the previous MasteryLevel if the entry existed (for Undo), null if newly created.
```

Implementation:
1. Call `notebookDao.getByVocabId(vocabId)`
2. If null: insert new entry with `masteryLevel = MasteryLevel.learning.value`; return null
3. If exists: call `updateMastery(entry.id, MasteryLevel.learning.value)`; return previous `MasteryLevel`

### State

- `NotebookFilter` enum: `all`, `needsReview`, `mastered` — defined in `notebook_providers.dart`
- `notebookFilterProvider = StateProvider<NotebookFilter>(_ => NotebookFilter.all)`
- Filtered list computed in `NotebookListScreen.build` from the stream result

### Flashcard Screen

`FlashcardSessionScreen` becomes aware of `notebookRepositoryProvider`:

```dart
void _onReview(List<Vocabulary> cards) async {
  final vocab = cards[_currentIndex];
  final prevLevel = await ref.read(notebookRepositoryProvider).upsertAsLearning(vocab.id);
  ref.invalidate(isInNotebookProvider(vocab.id));
  _showReviewSnackbar(vocab, prevLevel);
  setState(() => _currentIndex++);
  if (_currentIndex >= cards.length) _navigateToComplete(cards.length);
  else _speakCurrent(cards);
}
```

Snackbar shows word name + "已加入生词本" with Undo action.

### Notebook Screen

- `_MasteryChip` receives an `onTap` callback
- Tapping calls `_showMasterySheet(context, ref, entry)`
- Bottom sheet built inline in `NotebookListScreen`
- Filter chip bar rendered above the `ListView`

## Localization Keys (new)

| Key | EN | ZH |
|---|---|---|
| `savedToNotebook` | "Added to notebook" | "已加入生词本" |
| `undo` | "Undo" | "撤销" |
| `setMasteryTitle` | "Set Mastery Level" | "设置掌握程度" |
| `filterAll` | "All" | "全部" |
| `filterNeedsReview` | "Needs Review" | "待复习" |
| `filterMastered` | "Mastered" | "已掌握" |
| `masteryUnseen` | "Unseen" | "未接触" |
| `masteryLearning` | "Learning" | "待复习" |
| `masteryFamiliar` | "Familiar" | "熟悉" |
| `masteryProficient` | "Proficient" | "熟练" |
| `masteryMastered` | "Mastered" | "已掌握" |

## Files Changed

| File | Change |
|---|---|
| `lib/l10n/app_en.arb` | Add new keys |
| `lib/l10n/app_zh.arb` | Add new keys |
| `lib/domain/repositories/i_notebook_repository.dart` | Add `upsertAsLearning` |
| `lib/data/repositories/notebook_repository_impl.dart` | Implement `upsertAsLearning` |
| `lib/features/flashcard/presentation/screens/flashcard_session_screen.dart` | Call `upsertAsLearning`, show Snackbar |
| `lib/features/notebook/presentation/viewmodels/notebook_providers.dart` | Add `NotebookFilter` enum + `notebookFilterProvider` |
| `lib/features/notebook/presentation/screens/notebook_list_screen.dart` | Add filter chips, interactive mastery chip, bottom sheet |

## Out of Scope

- Persisting the selected notebook filter across sessions
- Showing a "needs review count" badge on the notebook tab icon
- Flashcard sessions that only show "needs review" words
