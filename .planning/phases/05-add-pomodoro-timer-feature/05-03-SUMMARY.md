---
phase: 05-add-pomodoro-timer-feature
plan: 03
subsystem: timer-ui
tags: [flutter, widgets, pomodoro, fab, countdown, material3, riverpod]

requires:
  - phase: 05-add-pomodoro-timer-feature
    provides: PomodoroTimerNotifier, PomodoroTimerState, session providers, settings providers
provides:
  - PomodoroFab overlay widget with SnackBar message handling
  - TimerCountdown circular progress ring with CustomPainter
  - TimerControls with Pause/Resume/Skip/Stop and confirmation dialog
  - TaskSelector dropdown for today's incomplete tasks
  - GoalProgress linear progress bar for daily session target
  - StreakCounter fire icon with consecutive day streak
  - TimerPanel assembly with compact/expanded modes
  - MainScreen integration wrapping all layouts with PomodoroFab
affects: [05-04, 05-05, 05-06]

tech-stack:
  added: []
  patterns: [ConsumerStatefulWidget with AnimationController, CustomPainter for progress ring, Timer.periodic for UI ticks]

key-files:
  created:
    - lib/presentation/widgets/pomodoro/pomodoro_fab.dart
    - lib/presentation/widgets/pomodoro/timer_countdown.dart
    - lib/presentation/widgets/pomodoro/timer_controls.dart
    - lib/presentation/widgets/pomodoro/task_selector.dart
    - lib/presentation/widgets/pomodoro/goal_progress.dart
    - lib/presentation/widgets/pomodoro/streak_counter.dart
    - lib/presentation/widgets/pomodoro/timer_panel.dart
  modified:
    - lib/presentation/screens/main_screen.dart

key-decisions:
  - "TimerCountdown uses Timer.periodic(1s) for UI rebuild and calls onTimerTick() for state machine"
  - "PomodoroFab uses SlideTransition with easeOut/easeIn for panel animation"
  - "TimerPanel uses surfaceContainerHighest at 95% opacity for background"
  - "GoalProgress reads dailyPomodoroCountProvider and settings for target calculation"

patterns-established:
  - "FAB overlay pattern: wrap Scaffold with Stack-based widget containing FAB and sliding panel"
  - "CustomPainter countdown ring: background ring + fill sweep angle = remaining/total * 2pi"

requirements-completed: [D-01, D-02, D-03, D-04, D-09, D-17, D-23, D-29, D-30]

duration: 6min
completed: 2026-04-10
---

# Phase 5 Plan 3: Timer UI Widgets Summary

**FAB overlay with animated timer panel containing countdown ring, controls, task selector, daily stats, goal progress bar, and streak counter, integrated into MainScreen on all layouts**

## Performance

- **Duration:** 6 min
- **Started:** 2026-04-10T10:56:00Z
- **Completed:** 2026-04-10T11:02:31Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- PomodoroFab widget wraps child in Stack, positions FAB at bottom-right with active badge colored by phase
- FAB listens to pomodoroMessageProvider and shows floating SnackBar on session completion
- TimerCountdown uses CustomPainter for circular progress ring with counterclockwise sweep animation
- MM:SS display with FontFeature.tabularFigures for monospaced digits, phase label below
- TimerControls with Pause/Resume toggle, Skip (break-only), Stop with AlertDialog confirmation
- TaskSelector dropdown loads today's incomplete tasks via getTasksByDateProvider
- GoalProgress shows linear progress bar with completed/target from providers
- StreakCounter displays fire icon with streak count or "Start a streak today!" for zero
- TimerPanel assembles all components in compact (200px) / expanded (280px) modes
- Settings gear navigates to /pomodoro-settings, close button hides panel without stopping timer
- MainScreen wraps mobile, tablet, and desktop layouts with PomodoroFab for FAB on all screens

## Task Commits

Each task was committed atomically:

1. **Task 1: FAB, countdown ring, and controls widgets** - `4396a4a` (feat)
2. **Task 2: Timer panel assembly and main_screen integration** - `0119040` (feat)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed ConsumerState build method signature**
- **Found during:** Task 1
- **Issue:** Generated build methods used `(BuildContext, WidgetRef)` signature but ConsumerState provides `ref` as property, build only takes `(BuildContext)`
- **Fix:** Changed all ConsumerStatefulWidget build methods to `build(BuildContext context)` with `ref` accessed via `this.ref`
- **Files modified:** pomodoro_fab.dart, timer_countdown.dart
- **Commit:** 4396a4a

**2. [Rule 1 - Bug] Fixed deprecated API usage**
- **Found during:** Task 1
- **Issue:** `withOpacity()` deprecated in favor of `withValues(alpha:)`, `value:` deprecated for `initialValue:` on DropdownButtonFormField
- **Fix:** Updated all instances to use non-deprecated APIs
- **Files modified:** timer_countdown.dart, goal_progress.dart, timer_panel.dart, task_selector.dart
- **Commit:** 4396a4a

## Known Stubs

- **TimerPanel expanded mode penguin placeholder**: Timer panel reserves space for penguin widget in expanded mode (280px), but penguin is intentionally deferred to Plan 06 per the plan spec.
- **Timer total seconds estimation**: TimerCountdown._getTotalSeconds uses hardcoded defaults (25/5/15 min) rather than reading settings provider for ring progress calculation. This is a simplification that will be refined when settings integration matures.

## Self-Check: PASSED

- All 8 files verified present on disk
- Commits 4396a4a and 0119040 verified in git log
- dart analyze reports no errors on Pomodoro widget files
