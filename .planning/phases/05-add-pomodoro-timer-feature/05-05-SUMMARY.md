---
phase: 05-add-pomodoro-timer-feature
plan: 05
subsystem: themes-audio
tags: [flutter, riverpod, themes, audio, material3, pomodoro]

requires:
  - phase: 05-add-pomodoro-timer-feature
    provides: PomodoroTimerNotifier, settings providers, session providers, timer panel, FAB overlay
provides:
  - PomodoroTheme class with 7 theme definitions (3 free, 4 earned)
  - Theme unlock system based on total session count
  - ThemePreviewCard with lock overlay and accessibility
  - ThemePickerGrid for settings screen
  - PomodoroAudioService with volume control and theme-aware sound paths
  - Timer panel themed background using selected theme colors
  - FAB glow effect using theme glow color when active
affects: [05-06, 05-07, 05-08]

tech-stack:
  added: []
  patterns: [Theme-scoped color overrides via provider, placeholder asset pattern with silent error handling]

key-files:
  created:
    - lib/presentation/providers/pomodoro_theme_providers.dart
    - lib/presentation/providers/pomodoro_audio_providers.dart
    - lib/presentation/widgets/pomodoro/theme_preview_card.dart
    - lib/presentation/widgets/pomodoro/theme_picker_grid.dart
    - assets/sounds/neon/.gitkeep
  modified:
    - lib/presentation/screens/pomodoro_settings_screen.dart
    - lib/presentation/widgets/pomodoro/timer_panel.dart
    - lib/presentation/widgets/pomodoro/pomodoro_fab.dart
    - pubspec.yaml

key-decisions:
  - "Audio service uses rootBundle.load for asset verification with silent catch for placeholder phase"
  - "Theme colors applied only to timer panel background and FAB glow, not app-wide (D-04)"
  - "Free themes: Neon, Gentoo, Retro; earned at 25, 50, 100, 200 sessions (D-36)"
  - "ThemePreviewCard shows 3:2 aspect ratio with color swatches and lock overlay"

patterns-established:
  - "Theme provider pattern: currentPomodoroThemeProvider reads settings and maps to theme definition"
  - "Unlock system: FutureProvider reads total session count, compares to theme unlockRequirement"
  - "Audio placeholder pattern: catch asset load errors silently until real sound files are added"

requirements-completed: [D-31, D-32, D-33, D-34, D-35, D-36, D-37, D-38, D-39, D-40, D-41, D-42, D-52]

duration: 5min
completed: 2026-04-10
---

# Phase 5 Plan 05: Themes & Audio Summary

**7 visual themes with session-count unlock system, theme picker grid in settings, audio service with per-theme sound packs and volume control, themed timer panel and FAB glow**

## Performance

- **Duration:** 5 min
- **Started:** 2026-04-10T11:07:22Z
- **Completed:** 2026-04-10T11:12:31Z
- **Tasks:** 2/2
- **Files modified:** 9

## Accomplishments

### Task 1: Theme data definitions, unlock logic, and audio service
- Defined `PomodoroTheme` immutable class with id, name, primary/secondary/glow colors, unlockRequirement, soundPackPrefix
- Created 7 themes: Neon (free), Gentoo (free), Retro (free), Cyberpunk (25 sessions), Space (50), Magic (100), Zen (200)
- Built `currentPomodoroThemeProvider` that maps settings themeId to theme definition
- Built `unlockedThemesProvider` FutureProvider that reads total session count from repository
- Implemented `PomodoroAudioService` with play methods for all session events (work_complete, break_complete, timer_start, skip, stop, unlock, penguin_chirp)
- Volume control with mute at 0, theme-aware sound path resolution
- Created placeholder asset directory `assets/sounds/neon/.gitkeep`

### Task 2: Theme picker grid UI and timer panel theming
- Built `ThemePreviewCard` ConsumerWidget with theme name, 3 color swatches (16px circles), lock overlay with Icons.lock + unlock requirement text
- Added Semantics labels for accessibility describing theme state
- Built `ThemePickerGrid` with 2-column GridView showing all 7 themes
- Replaced placeholder text in settings screen with live ThemePickerGrid widget
- Updated TimerPanel to read `currentPomodoroThemeProvider` and apply theme.secondary as background
- Updated PomodoroFab with glow BoxShadow using theme.glow color when timer is active
- Registered `assets/sounds/` in pubspec.yaml flutter assets section

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Audio service without audioplayers dependency**
- **Found during:** Task 1
- **Issue:** Plan referenced AudioPlayer from audioplayers package which is not in pubspec.yaml
- **Fix:** Used rootBundle.load for asset verification with TODO comment for future audioplayers integration. Service is fully structured and will work once the package is added.
- **Files modified:** lib/presentation/providers/pomodoro_audio_providers.dart

## Known Stubs

| File | Line | Stub | Reason |
|------|------|------|--------|
| lib/presentation/providers/pomodoro_audio_providers.dart | ~82 | rootBundle.load placeholder instead of actual audio playback | audioplayers package not yet added to dependencies; sound files not yet created. Service structure is complete and will work when package + assets are added. |

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | 6f92729 | Theme data definitions, unlock logic, and audio service |
| 2 | 6834720 | Theme picker grid UI and timer panel theming |
