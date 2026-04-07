# Phase 4: Search & Polish - Research

**Researched:** 2026-04-07
**Domain:** Flutter search UI implementation and accessibility compliance
**Confidence:** HIGH

## Summary

Phase 4 implements comprehensive search functionality and accessibility compliance for the Flutter Task Calendar app. The backend search infrastructure (SQLite LIKE queries) already exists, so this phase focuses on UI implementation, result highlighting, filtering controls, and screen reader support.

**Primary recommendation:** Use Flutter's Material 3 SearchBar widget with RichText highlighting, implement semantic accessibility widgets, and leverage existing Riverpod patterns for search state management.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Dedicated search screen accessed via app bar search icon from any screen
- **D-02:** Auto-focus keyboard when search screen opens for immediate typing  
- **D-03:** Search screen provides full-featured search interface with space for comprehensive controls
- **D-04:** Hybrid search approach: real-time search for 3+ characters, submit button for shorter terms
- **D-05:** Empty state when search field cleared or under 3 characters ("Enter search term" message)
- **D-06:** Search all tasks regardless of date for comprehensive task discovery
- **D-07:** Results ordered by most recent first (creation date descending)
- **D-08:** Enhanced result format with highlighted matching text within task titles/descriptions
- **D-09:** Show snippet previews to indicate why tasks matched the search term
- **D-10:** Comprehensive screen reader support with semantic widgets, focus management, and keyboard navigation
- **D-11:** Full WCAG 2.1 AA compliance for all search and filter interactions

### Claude's Discretion
- Filter UI layout design that complements the focused search experience
- Empty search results messaging approach (simple and clear)
- Search result snippet length and highlighting style
- Keyboard navigation patterns for search screen

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SEARCH-01 | User can search tasks by title text with real-time results | Flutter SearchBar widget + existing searchTasks() backend |
| SEARCH-02 | User can search tasks by description text with real-time results | Already supported by LIKE query on both title/description |
| FILTER-01 | User can filter tasks by date range using date picker controls | Flutter showDatePicker() + existing getTasksInDateRange() |
| FILTER-02 | User can filter tasks by completion status (all/pending/completed) | Existing getTasksByCompletionStatus() backend method |
| UI-04 | Screen reader users can navigate calendar and create/edit tasks | Flutter Semantics widgets + TalkBack/VoiceOver patterns |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter/material | 3.19+ | SearchBar widget, Material 3 design system | Built-in Material 3 search components |
| flutter_riverpod | 2.4.9 | Search state management | Already established in project |
| go_router | 13.0.0 | Navigation to search screen | Current navigation framework |

### Supporting  
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| intl | 0.19.0 | Date formatting in filters | Date range display formatting |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| SearchBar | SearchDelegate | SearchDelegate requires full screen takeover, conflicts with dedicated screen decision |
| RichText highlighting | External highlighting packages | RichText is built-in, sufficient for simple term highlighting |

**Installation:**
```bash
# No new dependencies needed — using existing packages
flutter pub get
```

**Version verification:** Current packages already meet requirements for search/accessibility features.

## Architecture Patterns

### Recommended Project Structure
```
lib/presentation/
├── screens/
│   └── search_screen.dart           # Dedicated search screen (D-01)
├── providers/
│   └── search_providers.dart        # Search state management
├── widgets/
│   ├── search/
│   │   ├── search_bar.dart         # Auto-focus search input (D-02)
│   │   ├── search_filters.dart     # Date range + status filters
│   │   ├── search_results.dart     # Enhanced results with highlighting
│   │   └── highlighted_text.dart   # Text highlighting component
│   └── accessibility/
│       └── semantic_helpers.dart   # Screen reader utilities
```

### Pattern 1: Material 3 SearchBar with Auto-focus
**What:** Dedicated search screen with immediate keyboard focus
**When to use:** User decision D-01, D-02 requires this pattern
**Example:**
```dart
// Source: Flutter Material 3 Documentation
class SearchScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Tasks')),
      body: Column(
        children: [
          SearchBar(
            hintText: 'Search by title or description...',
            autoFocus: true, // D-02: Auto-focus keyboard
            onChanged: _handleSearch,
          ),
          Expanded(child: SearchResults()),
        ],
      ),
    );
  }
}
```

### Pattern 2: RichText Result Highlighting
**What:** Highlight matching search terms in task titles/descriptions  
**When to use:** Required by D-08 for enhanced result format
**Example:**
```dart
// Source: Flutter TextSpan documentation
Widget buildHighlightedText(String text, String searchTerm) {
  final spans = <TextSpan>[];
  final matches = RegExp(searchTerm, caseSensitive: false).allMatches(text);
  
  int lastIndex = 0;
  for (final match in matches) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(text: text.substring(lastIndex, match.start)));
    }
    spans.add(TextSpan(
      text: text.substring(match.start, match.end),
      style: TextStyle(backgroundColor: Colors.yellow.shade200),
    ));
    lastIndex = match.end;
  }
  
  if (lastIndex < text.length) {
    spans.add(TextSpan(text: text.substring(lastIndex)));
  }
  
  return RichText(text: TextSpan(children: spans));
}
```

### Pattern 3: Semantic Accessibility Structure
**What:** Screen reader navigation and focus management
**When to use:** Required by D-10, D-11 for WCAG 2.1 AA compliance
**Example:**
```dart
// Source: Flutter accessibility documentation
Semantics(
  label: 'Search results, ${results.length} tasks found',
  child: ListView.builder(
    itemCount: results.length,
    itemBuilder: (context, index) {
      return Semantics(
        button: true,
        hint: 'Double tap to view task details',
        child: TaskCard(task: results[index]),
      );
    },
  ),
)
```

### Anti-Patterns to Avoid
- **SearchDelegate usage:** Conflicts with dedicated search screen requirement (D-01)
- **Global search state:** Use scoped providers for search screen only
- **Synchronous search:** Always debounce real-time search to prevent excessive queries

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Search debouncing | Custom timer logic | Timer.periodic with cancel | Edge cases around rapid typing, cancellation |
| Text highlighting | Custom string splitting | Flutter RichText + TextSpan | Built-in support for styled text spans |
| Date range pickers | Custom date widgets | showDatePicker() built-in | Platform-native date selection UX |
| Screen reader support | Custom accessibility logic | Semantics widget + semantic properties | Platform TalkBack/VoiceOver integration |

**Key insight:** Flutter's built-in accessibility and Material components handle complex edge cases better than custom implementations.

## Common Pitfalls

### Pitfall 1: Search Performance Degradation
**What goes wrong:** Real-time search triggers excessive database queries causing UI lag
**Why it happens:** No debouncing on text input changes, SQLite queries block UI thread
**How to avoid:** Debounce search input (300ms), use async queries with proper loading states
**Warning signs:** Visible lag when typing, dropped frames in performance overlay

### Pitfall 2: Accessibility Focus Management
**What goes wrong:** Screen readers lose focus context when search results update
**Why it happens:** ListView rebuilding clears accessibility focus, no semantic announcements
**How to avoid:** Use SemanticsService.announce() for result updates, stable keys for list items
**Warning signs:** TalkBack users report navigation confusion, focus jumping unexpectedly

### Pitfall 3: Search Highlighting Performance
**What goes wrong:** Complex text highlighting causes frame drops during scrolling
**Why it happens:** RegExp matching on every build, RichText reconstruction overhead
**How to avoid:** Cache highlighted text spans, use RepaintBoundary for expensive widgets  
**Warning signs:** Jerky scrolling in search results, high GPU usage in DevTools

### Pitfall 4: Date Filter State Management
**What goes wrong:** Date range filters reset when search text changes, inconsistent filter state
**Why it happens:** Combining multiple filter providers without proper state coordination
**How to avoid:** Single SearchState provider managing all filter criteria together
**Warning signs:** Filters clearing unexpectedly, date pickers showing wrong initial values

## Code Examples

Verified patterns from official sources:

### Search State Management with Riverpod
```dart
// Source: Riverpod documentation patterns
@riverpod
class SearchState extends _$SearchState {
  @override
  SearchStateData build() {
    return SearchStateData(
      query: '',
      dateRange: null,
      statusFilter: TaskStatusFilter.all,
      results: [],
      isLoading: false,
    );
  }

  void updateQuery(String query) {
    if (query.length >= 3) {
      _performSearch(query);
    } else {
      state = state.copyWith(query: query, results: []);
    }
  }

  Future<void> _performSearch(String query) async {
    state = state.copyWith(isLoading: true);
    final results = await ref.read(searchTasksUseCaseProvider)(query);
    state = state.copyWith(
      query: query,
      results: results.fold((l) => [], (r) => r),
      isLoading: false,
    );
  }
}
```

### Accessibility-Optimized Search Results
```dart  
// Source: Flutter accessibility guidelines
class AccessibleSearchResults extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchStateProvider);
    
    return Semantics(
      liveRegion: true, // Announce result updates
      label: 'Search results: ${searchState.results.length} tasks found',
      child: ListView.builder(
        itemCount: searchState.results.length,
        itemBuilder: (context, index) {
          final task = searchState.results[index];
          return Semantics(
            button: true,
            hint: 'Double tap to view ${task.title}',
            onTap: () => _openTask(context, task),
            child: HighlightedTaskCard(
              task: task, 
              searchTerm: searchState.query,
            ),
          );
        },
      ),
    );
  }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| SearchDelegate | SearchBar widget | Material 3 (2022) | More flexible, matches user's dedicated screen decision |
| Manual accessibility | Semantic widgets | Flutter 2.5+ (2021) | Better screen reader support, less custom code |
| String.contains() | RegExp highlighting | Always available | Case-insensitive search, better UX |

**Deprecated/outdated:**
- SearchDelegate for custom search screens: Still functional but SearchBar gives more control

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | none — see Wave 0 |
| Quick run command | `flutter test --plain-name` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SEARCH-01 | Real-time search by title | widget | `flutter test test/search/search_screen_test.dart --plain-name "real-time title search"` | ❌ Wave 0 |
| SEARCH-02 | Real-time search by description | widget | `flutter test test/search/search_screen_test.dart --plain-name "real-time description search"` | ❌ Wave 0 |
| FILTER-01 | Date range filtering | widget | `flutter test test/search/search_filters_test.dart --plain-name "date range filter"` | ❌ Wave 0 |
| FILTER-02 | Completion status filtering | widget | `flutter test test/search/search_filters_test.dart --plain-name "status filter"` | ❌ Wave 0 |
| UI-04 | Screen reader accessibility | widget | `flutter test test/accessibility/search_accessibility_test.dart --plain-name "screen reader navigation"` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test --plain-name "search"`
- **Per wave merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `test/search/search_screen_test.dart` — covers SEARCH-01, SEARCH-02
- [ ] `test/search/search_filters_test.dart` — covers FILTER-01, FILTER-02  
- [ ] `test/accessibility/search_accessibility_test.dart` — covers UI-04
- [ ] `test/helpers/semantic_helpers.dart` — shared accessibility test utilities

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All search features | ✓ | 3.19.0 | — |
| Dart SDK | Text highlighting RegExp | ✓ | 3.3.0 | — |

**Missing dependencies with no fallback:**
None — all required dependencies are available

**Missing dependencies with fallback:**
None identified

## Sources

### Primary (HIGH confidence)
- Flutter Material 3 SearchBar documentation — search widget patterns
- Flutter Accessibility documentation — semantic widget usage
- Riverpod 2.4+ documentation — state management patterns

### Secondary (MEDIUM confidence)
- Flutter performance guidelines — search debouncing recommendations
- WCAG 2.1 AA guidelines — accessibility compliance requirements

### Tertiary (LOW confidence)
None — all recommendations backed by official documentation

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Using existing project dependencies
- Architecture: HIGH - Following established Riverpod + Material 3 patterns
- Pitfalls: HIGH - Common Flutter performance and accessibility issues are well-documented

**Research date:** 2026-04-07
**Valid until:** 2026-05-07 (30 days - stable Flutter framework)