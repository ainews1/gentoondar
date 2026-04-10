---
phase: 05-add-pomodoro-timer-feature
plan: 02
subsystem: state-management
tags: [riverpod, pomodoro, timer, state-machine, equatable, wall-clock, tdd]

requires:
  - phase: 05-add-pomodoro-timer-feature
    provides: PomodoroSession entity, PomodoroSettings entity, PomodoroRepository, datasources
provides:
  - PomodoroTimerNotifier state machine with wall-clock background resilience
  - PomodoroTimerState with Equatable (idle/ready/working/shortBreak/longBreak)
  - Session data providers (daily count, streak, task count, focus minutes)
  - Settings AsyncNotifier with preset management
  - Use cases (StartPomodoroSession, CompletePomodoroSession, GetPomodoroSessions, SavePomodoroSettings)
affects: [05-03, 05-04, 05-05, 05-06, 05-07, 05-08]

tech-stack:
  added: []
  patterns: [Wall-clock DateTime for timer background resilience, Notifier (not autoDispose) for tab persistence]

key-files:
  created:
    - lib/presentation/providers/pomodoro_timer_providers.dart
    - lib/presentation/providers/pomodoro_session_providers.dart
    - lib/presentation/providers/pomodoro_settings_providers.dart
    - lib/domain/usecases/start_pomodoro_session.dart
    - lib/domain/usecases/complete_pomodoro_session.dart
    - lib/domain/usecases/get_pomodoro_sessions.dart
    - lib/domain/usecases/save_pomodoro_settings.dart
    - test/presentation/providers/pomodoro_timer_providers_test.dart
  modified: []

key-decisions:
  - "Timer uses wall-clock DateTime.now() for targetEndTime rather than countdown seconds for background resilience"
  - "PomodoroTimerNotifier is NOT autoDispose to survive tab switches"
  - "Pause/resume adjusts targetEndTime by accumulated pause duration"
  - "Session saving deferred to CompletePomodoroSession use case (not inline in timer)"

patterns-established:
  - "Wall-clock timer pattern: store targetEndTime, recalculate remaining on each access"
  - "Non-autoDispose Notifier for long-lived state that survives navigation"
  - "PomodoroPhase enum for state machine transitions"

requirements-completed: [D-06, D-07, D-10, D-11, D-12, D-13, D-14, D-15, D-16]

duration: 10min
completed: 2026-04-10
---

# Phase 5 Plan 2: Pomodoro Timer State Machine Summary

**Riverpod timer state machine with wall-clock background resilience, pause/resume via targetEndTime adjustment, auto-stop on task completion, and session/settings providers with 16 passing TDD tests**

## Performance

- **Duration:** 10 min
- **Started:** 2026-04-10T10:40:39Z
- **Completed:** 2026-04-10T10:51:08Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Complete timer state machine: IDLE -> READY -> WORK -> BREAK cycle with PomodoroPhase enum
- Wall-clock DateTime approach for background resilience (remainingTime recalculates automatically)
- Pause/resume correctly adjusts targetEndTime by accumulated pause duration
- Auto-stop on task completion (D-11), skip break (D-14), switch task mid-session (D-10)
- 4 use cases following existing codebase patterns (Params class + call method + Either)
- Session data providers: daily count, streak, task count per task, daily focus minutes
- Settings AsyncNotifier with preset management (classic/deep_work/sprint)
- TDD: 16 unit tests all passing for state transitions, remainingTime, Equatable

## Task Commits

Each task was committed atomically:

1. **Task 1: Use cases and session/settings providers** - `94c4abe` (feat)
2. **Task 2: Timer state machine (TDD RED)** - `d8cbc3c` (test)
3. **Task 2: Timer state machine (TDD GREEN)** - `bf22fad` (feat)

## Files Created/Modified
- `lib/domain/usecases/start_pomodoro_session.dart` - Constructs PomodoroSession without DB save
- `lib/domain/usecases/complete_pomodoro_session.dart` - Saves completed/partial session via repository
- `lib/domain/usecases/get_pomodoro_sessions.dart` - Query sessions by date and task ID
- `lib/domain/usecases/save_pomodoro_settings.dart` - Persist settings via SharedPreferences datasource
- `lib/presentation/providers/pomodoro_session_providers.dart` - Repository, datasource, and data query providers
- `lib/presentation/providers/pomodoro_settings_providers.dart` - Settings AsyncNotifier with preset/volume/theme management
- `lib/presentation/providers/pomodoro_timer_providers.dart` - Core timer state machine Notifier
- `test/presentation/providers/pomodoro_timer_providers_test.dart` - 16 unit tests for timer state

## Decisions Made
- Wall-clock DateTime approach chosen over countdown seconds for automatic background resilience
- PomodoroTimerNotifier is NOT autoDispose so timer survives tab navigation
- Pause/resume uses targetEndTime adjustment (add pause duration) rather than storing remaining seconds
- Session saving delegated to CompletePomodoroSession use case for clean separation

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
- Cherry-picked plan 05-01 commits from parallel worktree since dependencies were needed (resolved cleanly)

## User Setup Required

None - no external service configuration required.

## Known Stubs

None - all providers return real data from repository/datasource layer.

## Next Phase Readiness
- Timer state machine ready for UI consumption in plans 05-03 through 05-08
- All providers wired and functional: timer, sessions, settings
- Session data query providers ready for analytics integration

---
*Phase: 05-add-pomodoro-timer-feature*
*Completed: 2026-04-10*
