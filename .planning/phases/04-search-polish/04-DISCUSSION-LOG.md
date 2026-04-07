# Phase 4: Search & Polish - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-07
**Phase:** 4-search-polish
**Areas discussed:** Search UI placement, Search behavior, Filter UI design, Results presentation, Accessibility implementation

---

## Search UI placement

| Option | Description | Selected |
|--------|-------------|----------|
| App bar search icon | Tap icon to expand search bar in current screen's app bar (standard Material pattern, keeps context) | |
| Dedicated search screen | Navigate to separate search screen with full-featured search interface (more space for filters, clean focus) | ✓ |
| Floating search widget | Persistent search bar floating over task list (always visible, no navigation needed) | |
| Tab in bottom navigation | Add search as 6th tab alongside Calendar, Tasks, Week, Day, Analytics (equal prominence with other views) | |

**User's choice:** Dedicated search screen
**Notes:** User wanted full-featured interface with space for comprehensive search and filtering controls

---

## Search navigation method

| Option | Description | Selected |
|--------|-------------|----------|
| App bar search icon | Tap search icon in any screen's app bar to navigate to dedicated search screen (consistent entry point from anywhere) | ✓ |
| Floating action button | Add search FAB to main screens that opens search screen (prominent but takes screen space) | |
| Menu option | Include "Search Tasks" in app drawer or overflow menu (discoverable but requires more taps) | |
| Swipe gesture | Swipe down from top of task list to reveal search screen (gesture-based, fast for power users) | |

**User's choice:** App bar search icon
**Notes:** Standard Material Design pattern providing consistent entry point from any screen

---

## Search screen behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Empty state first | Show search screen with empty search bar, filters collapsed, and "Start typing to search" message (clean start, user-driven) | |
| Auto-focus keyboard | Open search screen with keyboard automatically shown and cursor in search field (immediate typing, faster for intent-driven users) | ✓ |
| Recent searches | Show search screen with list of recent search terms or suggested searches (helpful for repeat searches, more complex) | |
| Quick filters prominently displayed | Show search bar plus expanded filter options (date range, completion status) immediately visible (comprehensive but potentially overwhelming) | |

**User's choice:** Auto-focus keyboard
**Notes:** Prioritizes speed for users ready to type immediately when accessing search

---

## Search timing

| Option | Description | Selected |
|--------|-------------|----------|
| Real-time search | Results update instantly as each character is typed (immediate feedback, leverages existing searchTasks backend) | |
| Debounced search | Wait for brief pause in typing (300ms) then search (real-time feel but fewer database queries) | |
| Search on submit | Only search when user hits enter/search button (explicit control, less resource intensive) | |
| Hybrid approach | Real-time for 3+ characters, submit button for shorter terms (balances performance with usability) | ✓ |

**User's choice:** Hybrid approach
**Notes:** Smart balance between immediate feedback for meaningful searches while avoiding too many queries on short terms

---

## Search field clear behavior

| Option | Description | Selected |
|--------|-------------|----------|
| Show all tasks | Return to showing all tasks from current date/context (familiar pattern, maintains task list context) | |
| Show empty state | Display "Enter search term" message with empty results (clean slate, encourages intentional searching) | ✓ |
| Show recent searches | Display list of previous search terms for quick re-selection (helpful for repeat searches) | |
| Maintain last results | Keep showing the last search results until new search is entered (avoids jarring transitions) | |

**User's choice:** Show empty state
**Notes:** Keeps search experience clean and focused, encouraging intentional searching

---

## Search scope

| Option | Description | Selected |
|--------|-------------|----------|
| Search all tasks | Search across all tasks regardless of date (comprehensive, finds tasks user might have forgotten) | ✓ |
| Search current date context | Only search tasks from currently selected date in other views (contextual, matches current task list scope) | |
| Search with date range filter | Default to all tasks but provide visible date range filter to narrow scope (flexible, user-controlled scope) | |
| Search recent tasks | Search only tasks from last 30 days to keep results relevant (focused on active tasks, avoids old irrelevant results) | |

**User's choice:** Search all tasks
**Notes:** Makes search truly powerful for finding tasks created weeks ago without remembering exact dates

---

## Search result ordering

| Option | Description | Selected |
|--------|-------------|----------|
| Most recent first | Sort by creation date descending (newest tasks appear first, matches typical expectation) | ✓ |
| Relevance scoring | Sort by text match quality, then by date (best matches first, more sophisticated search feel) | |
| Upcoming tasks first | Sort by start date ascending, showing future tasks before past ones (task-oriented, focuses on actionable items) | |
| Date grouping | Group results by date with most recent dates first, tasks within each date by start time (organized view, maintains temporal context) | |

**User's choice:** Most recent first
**Notes:** Intuitive ordering that matches user expectations for search results

---

## Empty search results handling

| Option | Description | Selected |
|--------|-------------|----------|
| Simple "No results" message | Clean message like "No tasks found for 'search term'" (straightforward, clear feedback) | ✓ |
| Search suggestions | Show "No results for 'search term'. Try searching for [common terms]" (helpful guidance for better searches) | |
| Create task prompt | Show "No tasks found. Create a new task with this title?" button (turns failed search into task creation opportunity) | |
| Search tips | Show "No results found" with tips like "Try different keywords" or "Check spelling" (educational, helps users search better) | |

**User's choice:** You decide (Claude's discretion)
**Notes:** User delegated to Claude to handle with simple, clear approach fitting the clean search experience

---

## Filter UI positioning

| Option | Description | Selected |
|--------|-------------|----------|
| Below search bar | Search field at top, then filter chips/buttons directly below (logical flow, always visible) | ✓ |
| Collapsible section | "Filters" button that expands to show date range and status controls (clean initial view, expandable when needed) | |
| Bottom sheet | "Filter" button opens bottom sheet with all filter options (material pattern, doesn't take permanent screen space) | |
| Horizontal scrolling chips | Search bar with scrollable filter chips below (compact, familiar pattern from other apps) | |

**User's choice:** You decide (Claude's discretion)
**Notes:** User delegated filter layout design to complement the focused search experience

---

## Search results presentation

| Option | Description | Selected |
|--------|-------------|----------|
| Same card layout | Use identical TaskCard component for consistency with task list screens (familiar, maintains design system consistency) | |
| Compact search results | Slimmer cards with just title, date, and completion status for faster scanning (space-efficient, search-optimized) | |
| Enhanced result format | Highlight matching text within task titles/descriptions, show snippet previews (search-specific, shows why task matched) | ✓ |
| Grouped by date | Same cards but group results under date headers (organized view, maintains temporal context despite all-time search scope) | |

**User's choice:** Auto-selected: Enhanced result format
**Notes:** Search-specific highlighting shows users why tasks matched their search terms

---

## Claude's Discretion

- Filter UI layout design that complements focused search experience
- Empty search results messaging approach (simple and clear)
- Search result snippet length and highlighting style
- Keyboard navigation patterns for search screen

## Deferred Ideas

None — all discussion remained within phase scope of search functionality and accessibility requirements.