# Vocab Detail Swipe Navigation Design

**Date:** 2026-06-06  
**Status:** Approved

## Overview

Users can swipe left/right in the vocabulary detail screen to navigate between words in the same list context (category, search result, or notebook). The swipe range is always the list the user came from — no cross-context navigation.

## Behavior

| Entry point | Swipe range |
|---|---|
| Vocab list (system filter active, e.g. Cardiovascular) | Only words in that system |
| Vocab list (no filter) | All words in current domain |
| Vocab list (search results) | Search result words only |
| Notebook | Notebook entries only |
| Direct URL / deep link (no extra) | Single-word view, no swipe |

## Data Flow

Navigation passes a lightweight `extra` map — only IDs, not full objects:

```dart
context.push(
  '/vocabulary/${vocabs[i].id}',
  extra: {'ids': vocabs.map((v) => v.id).toList(), 'index': i},
);
```

`VocabDetailScreen` receives `vocabIds: List<int>?` and `initialIndex: int`. Each page of the `PageView` lazily loads its word via the existing `vocabDetailProvider(id)` — no new providers or DB queries needed at navigation time.

## Component Changes

### `VocabDetailScreen`

- Change from `ConsumerWidget` to `ConsumerStatefulWidget`
- New params: `vocabIds: List<int>?`, `initialIndex: int` (defaults to 0)
- When `vocabIds != null && vocabIds.length > 1`:
  - Build a `PageView.builder` with `PageController(initialPage: initialIndex)`
  - Each page renders the existing `_VocabDetailBody` for `vocabIds[page]`
  - AppBar title shows `"${currentPage + 1} / ${vocabIds.length}"` (updates as user swipes)
  - Uses a `ValueNotifier<int>` or `setState` to track current page
- When `vocabIds == null` or `vocabIds.length == 1`: render single-word view (current behavior, unchanged)

### `router.dart`

Extract `ids` and `index` from `state.extra` and pass to `VocabDetailScreen`:

```dart
GoRoute(
  path: ':vocabId',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    final ids = (extra?['ids'] as List?)?.cast<int>();
    final index = (extra?['index'] as int?) ?? 0;
    return VocabDetailScreen(
      vocabId: int.parse(state.pathParameters['vocabId']!),
      vocabIds: ids,
      initialIndex: index,
    );
  },
),
```

### `vocab_list_screen.dart`

Change navigation from:
```dart
context.push('/vocabulary/${vocabs[i].id}');
```
To:
```dart
context.push(
  '/vocabulary/${vocabs[i].id}',
  extra: {'ids': vocabs.map((v) => v.id).toList(), 'index': i},
);
```

### `notebook_list_screen.dart`

Change navigation from:
```dart
context.push('/vocabulary/${filtered[i].vocabId}');
```
To:
```dart
context.push(
  '/vocabulary/${filtered[i].vocabId}',
  extra: {
    'ids': filtered.map((e) => e.vocabId).toList(),
    'index': i,
  },
);
```

## AppBar Page Counter

When in swipe mode, replace the default AppBar title with a page counter:

```
← 12 / 48
```

- Updates in real-time via `PageController` listener
- The back button (auto-provided by GoRouter) remains functional

## Edge Cases

- **Single word in list** (e.g. search matched 1 result): no PageView, single-word view
- **Notebook filter active**: `filtered` list (not all notebook entries) is passed — swiping stays within the filtered subset
- **No extra passed** (deep link or future entry point): falls back to single-word view, word still displays correctly

## Files Changed

| File | Change |
|---|---|
| `lib/features/vocabulary/presentation/screens/vocab_detail_screen.dart` | ConsumerStatefulWidget, PageView, PageController, page counter in AppBar |
| `lib/app/router.dart` | Extract ids/index from extra, pass to VocabDetailScreen |
| `lib/features/vocabulary/presentation/screens/vocab_list_screen.dart` | Pass ids+index extra on navigation |
| `lib/features/notebook/presentation/screens/notebook_list_screen.dart` | Pass ids+index extra on navigation |

## Out of Scope

- Updating the URL as the user swipes between pages
- Preloading adjacent pages' data
- Swipe navigation in flashcard or knowledge article screens
