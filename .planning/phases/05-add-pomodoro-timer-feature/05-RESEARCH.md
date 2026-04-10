# Phase 5: Add Pomodoro Timer Feature - Research

**Researched:** 2026-04-10
**Domain:** Flutter Pomodoro timer with audio, pixel art mascot, theming, analytics
**Confidence:** MEDIUM

## Summary

This phase adds a Pomodoro timer feature to the existing Flutter Task Calendar app. The feature spans multiple technical domains: timer state management with background awareness, audio playback for themed sound packs, procedural pixel art generation via CustomPainter, SQLite schema extension for session tracking, and integration with existing analytics charts. The app already has a mature clean architecture (domain/data/presentation layers), Riverpod state management, SQLite via sqflite, and fl_chart analytics -- all of which should be extended, not replaced.

The largest technical risks are: (1) background timer accuracy across iOS/Android lifecycle differences, (2) the procedural penguin generation system requiring careful CustomPainter optimization, and (3) sound asset management across 7 themes with multiple sound events each. The CONTEXT.md has 56 locked decisions with extensive detail, plus a comprehensive UI spec. Data schema and settings storage approach are marked as "TO BE DISCUSSED" but can be resolved with Claude's discretion given the patterns are straightforward.

**Primary recommendation:** Extend the existing clean architecture with a `pomodoro` domain, use `audioplayers 6.x` for sound playback, store session data in SQLite (new table, database version 2 migration), store settings in `shared_preferences`, and implement the timer as a Riverpod `StateNotifier` that tracks wall-clock timestamps for background resilience.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions
- D-01: Timer accessible via FAB in bottom-right, available from any screen
- D-02: FAB expands into compact progress bar panel (fixed position, not draggable)
- D-03: FAB icon is static -- no countdown animation on button
- D-04: Timer panel theme only affects timer panel and FAB, not rest of app
- D-05: 3 presets + custom: Classic (25/5/15), Deep Work (50/10/20), Sprint (15/3/10)
- D-06: Auto-start behavior configurable, default: manual start
- D-07: Long break interval configurable (default: every 4 work sessions)
- D-08: Required task link before starting Pomodoro
- D-09: Task selection via "Start Pomodoro" on expanded task card OR dropdown in timer panel
- D-10: User can switch linked task mid-session
- D-11: Completing linked task auto-stops timer (saves as partial)
- D-12: Timer continues running in background
- D-13: Closing/reopening app resets current session (only completed sessions saved)
- D-14: User can skip breaks
- D-15: Pausing has no time limit
- D-16: Sessions are timer-only, no manual logging
- D-17: "Start Pomodoro" only on expanded task card
- D-18: No lock screen or persistent notification
- D-19: Pomodoro session history persisted to SQLite
- D-20: Pomodoro data shown in existing Analytics tab
- D-21: Analytics includes daily totals AND per-task breakdown charts
- D-22: Weekly + monthly Pomodoro summary views
- D-23: Timer panel shows daily count
- D-24: Configurable daily goal
- D-25: Daily streak counter
- D-26: Completed sessions appear on day/week calendar views
- D-27: Calendar visualization approach -- Claude's Discretion
- D-28: Task cards display Pomodoro count badge
- D-29: SnackBar encouraging messages on completion
- D-30: Progress-aware + motivational messages
- D-31: 7 customizable themes for timer panel
- D-32: Each theme has unique animations
- D-33: Each theme has matching sound pack
- D-34: Theme unlock system: 2-3 free, rest earned at milestones
- D-35: Theme selection via grid of preview cards
- D-36: Which themes are free vs earned -- Claude's Discretion
- D-37: Sound packs with pre-recorded synthesizer sounds
- D-38: Each theme gets its own matching sound pack
- D-39: No ticking sound during work
- D-40: Sound only, no haptic/vibration
- D-41: Separate volume control for Pomodoro sounds
- D-42: Break vs work-end sound differentiation -- Claude's Discretion
- D-43: Pixel art style Gentoo penguin mascot
- D-44: Infinite procedurally-generated evolution stages
- D-45: Random generator varies color palette, accessories, size/proportions, background/aura
- D-46: Stage loss is streak-based (3 days no activity)
- D-47: Stage loss = fewer spontaneous sounds
- D-48: Penguin visible in timer panel only
- D-49: Penguin has idle animations
- D-50: Penguin makes spontaneous sounds only during breaks
- D-51: Default name "Tux", user-editable
- D-52: Evolution celebrations are subtle transitions
- D-53: Settings layout -- Claude's Discretion (single scrollable page recommended)
- D-54: Preset selector UI -- Claude's Discretion
- D-55: Custom duration input via sliders
- D-56: Theme picker as grid of preview cards

### Claude's Discretion
- Settings screen overall layout and organization
- Preset selector UI component choice
- Calendar visualization approach for Pomodoro blocks
- Sound differentiation between work-end and break-end
- Which 2-3 themes are free vs earned
- Penguin default name (suggested "Tux")

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope

### Unresolved (TO BE DISCUSSED but resolvable)
- Session data schema (fields per Pomodoro session)
- Settings storage approach (SQLite vs SharedPreferences)
- Penguin state persistence model

</user_constraints>

## Project Constraints (from CLAUDE.md)

- **Platform**: Flutter with Dart, cross-platform mobile
- **Storage**: Local persistence only (sqflite or Hive), no cloud
- **UI Framework**: Material Design with platform-adaptive widgets
- **State Management**: Riverpod 2.4+ (established in codebase)
- **Architecture**: Clean Architecture + MVVM with Repository pattern
- **Performance**: 60fps scrolling and animations
- **Accessibility**: WCAG 2.1 AA standards
- **Avoid**: GetX, global state singletons, DateTime without timezone handling, blocking UI ops
- **Charts**: fl_chart (already integrated)
- **Navigation**: go_router (already integrated)

## Standard Stack

### Core (already in project)
| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| flutter_riverpod | ^2.4.9 | State management | Already installed |
| sqflite | ^2.3.0 | SQLite database | Already installed |
| fl_chart | ^0.66.0 | Charts/analytics | Already installed |
| equatable | ^2.0.5 | Immutable models | Already installed |
| dartz | ^0.10.1 | Functional error handling | Already installed |
| go_router | ^13.0.0 | Navigation | Already installed |
| intl | ^0.19.0 | Date/number formatting | Already installed |

### New Dependencies
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| audioplayers | ^6.6.0 | Sound playback for theme sounds | Most popular Flutter audio package, supports asset playback, volume control, multi-platform |
| shared_preferences | ^2.5.5 | Pomodoro settings persistence | Best practice for key-value settings, lighter than SQLite for preferences |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| audioplayers | just_audio | just_audio has more features but heavier; audioplayers is simpler for short sound effects |
| shared_preferences | SQLite for settings | SQLite is overkill for flat key-value settings; shared_preferences is the Flutter standard |

**Installation:**
```bash
flutter pub add audioplayers shared_preferences
```

## Architecture Patterns

### Recommended Project Structure (new files)
```
lib/
├── domain/
│   ├── entities/
│   │   ├── pomodoro_session.dart        # Session entity
│   │   ├── pomodoro_settings.dart       # Settings value object
│   │   └── penguin_state.dart           # Penguin evolution state
│   ├── repositories/
│   │   └── pomodoro_repository.dart     # Abstract repository
│   └── usecases/
│       ├── start_pomodoro_session.dart
│       ├── complete_pomodoro_session.dart
│       ├── get_pomodoro_sessions.dart
│       ├── get_pomodoro_analytics.dart
│       ├── get_daily_streak.dart
│       └── save_pomodoro_settings.dart
├── data/
│   ├── datasources/local/
│   │   ├── pomodoro_local_datasource.dart
│   │   └── pomodoro_settings_datasource.dart  # shared_preferences
│   ├── models/
│   │   └── pomodoro_session_model.dart
│   └── repositories/
│       └── pomodoro_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── pomodoro_timer_providers.dart    # Timer state machine
    │   ├── pomodoro_session_providers.dart  # Session data
    │   ├── pomodoro_settings_providers.dart # Settings state
    │   ├── penguin_providers.dart           # Penguin state
    │   └── pomodoro_theme_providers.dart    # Theme selection
    ├── screens/
    │   └── pomodoro_settings_screen.dart
    └── widgets/
        ├── pomodoro/
        │   ├── pomodoro_fab.dart
        │   ├── timer_panel.dart
        │   ├── timer_countdown.dart
        │   ├── timer_controls.dart
        │   ├── task_selector.dart
        │   ├── penguin_widget.dart
        │   ├── penguin_renderer.dart
        │   ├── theme_picker_grid.dart
        │   ├── theme_preview_card.dart
        │   ├── preset_selector.dart
        │   ├── duration_sliders.dart
        │   ├── pomodoro_badge.dart
        │   ├── streak_counter.dart
        │   └── goal_progress.dart
        ├── calendar/
        │   └── pomodoro_marker.dart
        └── charts/
            └── pomodoro_charts.dart
```

### Pattern 1: Timer State Machine (Riverpod StateNotifier)

**What:** The timer is a finite state machine managed by a Riverpod `Notifier` (or `StateNotifier`). States: IDLE, READY, WORK_ACTIVE, WORK_PAUSED, BREAK_PENDING, BREAK_ACTIVE, BREAK_PAUSED, WORK_PENDING.

**When to use:** For any stateful UI that has well-defined transitions and needs to survive widget rebuilds.

**Key insight:** Store the `targetEndTime` as a wall-clock `DateTime`, not a remaining-seconds counter. This makes background resilience trivial -- when the app resumes, compare `DateTime.now()` to `targetEndTime` to calculate remaining time or detect completion.

```dart
// Timer state - stores wall-clock target, not countdown
class PomodoroTimerState extends Equatable {
  final PomodoroPhase phase; // idle, ready, working, shortBreak, longBreak
  final bool isPaused;
  final DateTime? targetEndTime;  // Wall-clock when session ends
  final DateTime? pausedAt;       // When pause started (to adjust targetEndTime)
  final int completedSessions;    // Sessions in current cycle
  final int? linkedTaskId;
  final Duration totalPausedDuration; // Accumulated pause time
  
  const PomodoroTimerState({...});
  // ...
}
```

### Pattern 2: Background Timer Resilience (WidgetsBindingObserver)

**What:** Use `WidgetsBindingObserver` to detect app lifecycle changes. On `paused` (backgrounded), record time. On `resumed`, recalculate timer state from wall-clock target.

**When to use:** Any timer that must track real time across app backgrounding.

**Critical per D-12/D-13:** Timer "continues" in background (time passes) but if app is killed and reopened, session resets. This means:
- Store `targetEndTime` in memory only (not persisted)
- On `AppLifecycleState.resumed`: check if `DateTime.now() >= targetEndTime` -- if so, session completed while backgrounded, save it
- On app cold start: no timer state to restore (D-13)

```dart
class TimerLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recalculate remaining time from targetEndTime
      // If session completed while backgrounded, trigger completion
    }
  }
}
```

### Pattern 3: Procedural Penguin Generation (CustomPainter + Seed)

**What:** Generate penguin appearance from a deterministic seed derived from session history. Use `Random(seed)` to produce consistent but unique variations.

**When to use:** For the Tamagotchi-style evolving mascot (D-43 through D-52).

**Key design:**
- Seed = hash of (total completed sessions + streak data)
- Each "evolution" stage adds complexity: more accessories, richer colors, background aura
- Rendering via `CustomPainter` drawing filled rectangles on a pixel grid (80x80 display, ~16x16 logical pixel grid)
- Idle animations: cycle through sprite frames using `AnimationController`
- Cache `shouldRepaint` to avoid re-rendering static frames

```dart
class PenguinRenderer extends CustomPainter {
  final PenguinState state;
  final int animationFrame;
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(state.seed);
    final pixelSize = size.width / 16; // 16x16 grid in 80x80 area
    // Draw body, head, eyes, beak, accessories based on random params
    _drawBody(canvas, pixelSize, random);
    _drawAccessories(canvas, pixelSize, random, state.evolutionStage);
  }
  
  @override
  bool shouldRepaint(PenguinRenderer old) =>
    old.state != state || old.animationFrame != animationFrame;
}
```

### Pattern 4: Database Migration (Version 1 -> 2)

**What:** Extend the existing `DatabaseHelper` with `onUpgrade` to add Pomodoro tables. Current version is 1.

**When to use:** Adding new tables to an existing SQLite schema.

```dart
// In DatabaseHelper._onUpgrade:
if (oldVersion < 2) {
  await db.execute('''
    CREATE TABLE pomodoro_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      task_id INTEGER NOT NULL,
      session_type TEXT NOT NULL CHECK(session_type IN ('work', 'short_break', 'long_break')),
      started_at INTEGER NOT NULL,
      ended_at INTEGER NOT NULL,
      duration_seconds INTEGER NOT NULL,
      planned_duration_seconds INTEGER NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 1,
      created_at INTEGER NOT NULL,
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('CREATE INDEX idx_pomodoro_task ON pomodoro_sessions(task_id)');
  await db.execute('CREATE INDEX idx_pomodoro_date ON pomodoro_sessions(started_at)');
}
```

### Pattern 5: Theme System (Scoped to Timer Panel)

**What:** Define theme data as immutable value objects, not Flutter ThemeData. The timer panel reads its theme from a Riverpod provider and applies colors/animations locally.

**When to use:** Per D-04, themes affect only the timer panel and FAB, not the whole app.

```dart
class PomodoroTheme extends Equatable {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color glow;
  final int unlockRequirement; // 0 = free
  final String soundPackPrefix; // asset path prefix
  
  const PomodoroTheme({...});
}

// Predefined themes list
const pomodoroThemes = [
  PomodoroTheme(id: 'neon', name: 'Futuristic/Neon', primary: Color(0xFF00FFFF), ...),
  // ...7 total
];
```

### Anti-Patterns to Avoid
- **Global Timer singleton:** Use Riverpod provider, not a static singleton. Makes testing impossible and violates CLAUDE.md.
- **Storing remaining seconds instead of target end time:** Breaks completely when app is backgrounded. Always use wall-clock DateTime.
- **Building full ThemeData for timer themes:** Overkill. Timer themes are just color/animation configs, not Material ThemeData.
- **Blocking audio loading on main thread:** Pre-cache audio assets in an init provider, not during timer start.
- **Re-generating penguin on every frame:** Use `shouldRepaint` and cache the pixel grid. Only regenerate when evolution stage changes.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Audio playback | Custom platform channel audio | `audioplayers` package | Cross-platform audio is complex, volume control, asset management |
| Key-value settings storage | Custom file-based settings | `shared_preferences` | Platform-native backing, async API, well-tested |
| SQLite database | Raw SQL strings everywhere | Extend existing `DatabaseHelper` | Already has error handling, connection management, WAL mode |
| State machine | Manual boolean flags | Enum-based state with `Notifier` | Prevents impossible states, clear transitions |
| Pixel grid rendering | Image assets for each evolution | `CustomPainter` with procedural generation | Infinite variations from seed, smaller app size |

**Key insight:** The biggest hand-rolling temptation will be building a custom audio system or trying to manage timer state with scattered boolean flags. The state machine pattern and audioplayers package eliminate entire categories of bugs.

## Common Pitfalls

### Pitfall 1: Timer Drift in Background
**What goes wrong:** Using `Timer.periodic` with remaining seconds causes timer to "freeze" when app is backgrounded, showing incorrect remaining time on resume.
**Why it happens:** Dart timers don't fire when the app is suspended by the OS.
**How to avoid:** Store `targetEndTime` as wall-clock `DateTime`. On every tick and on resume, calculate remaining = `targetEndTime.difference(DateTime.now())`.
**Warning signs:** Timer shows wrong time after switching away from app and back.

### Pitfall 2: SQLite Migration on Existing Installs
**What goes wrong:** Incrementing `_databaseVersion` without proper `onUpgrade` handler causes crash or data loss.
**Why it happens:** `sqflite` calls `onUpgrade` when version changes. If handler is missing or incomplete, database may not open.
**How to avoid:** Implement incremental migration in `_onUpgrade`. Test with version 1 database, then upgrade to version 2. Never drop+recreate tables.
**Warning signs:** App crashes on first launch after update.

### Pitfall 3: Audio Player Resource Leaks
**What goes wrong:** Creating new `AudioPlayer` instances per sound effect without disposing them leaks native resources.
**Why it happens:** Each `AudioPlayer` allocates native audio session resources.
**How to avoid:** Create a pool of reusable `AudioPlayer` instances (one per concurrent sound needed). Dispose in provider's `onDispose`.
**Warning signs:** Audio stops working after playing many sounds, memory usage creeps up.

### Pitfall 4: CustomPainter Performance
**What goes wrong:** Penguin widget causes jank because `paint()` is called every frame and does expensive work.
**Why it happens:** `shouldRepaint` returns true too often, or paint allocates objects.
**How to avoid:** Cache `Paint` objects as fields. Use `shouldRepaint` to compare only relevant state. Separate animation frame index from evolution state.
**Warning signs:** Dropped frames visible in DevTools performance overlay when timer panel is open.

### Pitfall 5: Riverpod Provider Lifecycle with FAB Overlay
**What goes wrong:** Timer state is lost when navigating between tabs because provider is scoped to a widget that gets disposed.
**Why it happens:** Using `autoDispose` on the timer provider, or scoping it under a widget that rebuilds.
**How to avoid:** Make the timer provider a top-level `NotifierProvider` (not autoDispose). The FAB and timer panel are overlaid on the Scaffold, not inside tab views.
**Warning signs:** Timer resets when switching tabs.

### Pitfall 6: Sound Asset Size
**What goes wrong:** App size balloons because each theme has multiple audio files in uncompressed format.
**Why it happens:** 7 themes x 7 sound events = 49 audio files, WAV format is large.
**How to avoid:** Use OGG Vorbis or MP3 format for sound assets. Keep sounds short (200ms-3s). Target < 50KB per file, total audio assets < 3MB.
**Warning signs:** APK/IPA size increases by > 10MB.

## Code Examples

### Example 1: Timer State with Background Resilience
```dart
enum PomodoroPhase { idle, ready, working, shortBreak, longBreak }

class PomodoroTimerState extends Equatable {
  final PomodoroPhase phase;
  final bool isPaused;
  final DateTime? targetEndTime;
  final DateTime? pausedAt;
  final int completedSessions;
  final int? linkedTaskId;
  
  const PomodoroTimerState({
    this.phase = PomodoroPhase.idle,
    this.isPaused = false,
    this.targetEndTime,
    this.pausedAt,
    this.completedSessions = 0,
    this.linkedTaskId,
  });
  
  Duration get remainingTime {
    if (targetEndTime == null) return Duration.zero;
    if (isPaused && pausedAt != null) {
      return targetEndTime!.difference(pausedAt!);
    }
    final remaining = targetEndTime!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  bool get isCompleted => remainingTime == Duration.zero && phase != PomodoroPhase.idle;
  
  @override
  List<Object?> get props => [phase, isPaused, targetEndTime, pausedAt, completedSessions, linkedTaskId];
}
```

### Example 2: Audio Service with Pooling
```dart
class PomodoroAudioService {
  final AudioPlayer _effectPlayer = AudioPlayer();
  double _volume = 0.7;
  String _currentThemePrefix = 'neon';
  
  Future<void> playWorkComplete() async {
    await _effectPlayer.setVolume(_volume);
    await _effectPlayer.play(AssetSource('sounds/$_currentThemePrefix/work_complete.ogg'));
  }
  
  Future<void> playBreakComplete() async {
    await _effectPlayer.setVolume(_volume);
    await _effectPlayer.play(AssetSource('sounds/$_currentThemePrefix/break_complete.ogg'));
  }
  
  void setVolume(double volume) => _volume = volume;
  void setTheme(String themePrefix) => _currentThemePrefix = themePrefix;
  
  void dispose() {
    _effectPlayer.dispose();
  }
}
```

### Example 3: Pomodoro Session Entity (Schema Design)
```dart
class PomodoroSession extends Equatable {
  final int id;
  final int taskId;
  final String sessionType; // 'work', 'short_break', 'long_break'
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final int plannedDurationSeconds;
  final bool isCompleted; // false for partial sessions (D-11 auto-stop)
  final DateTime createdAt;
  
  const PomodoroSession({...});
  
  @override
  List<Object?> get props => [id, taskId, sessionType, startedAt, endedAt, 
    durationSeconds, plannedDurationSeconds, isCompleted, createdAt];
}
```

### Example 4: Settings via shared_preferences
```dart
class PomodoroSettingsDatasource {
  static const _keyPreset = 'pomodoro_preset';
  static const _keyWorkDuration = 'pomodoro_work_duration';
  static const _keyShortBreakDuration = 'pomodoro_short_break';
  static const _keyLongBreakDuration = 'pomodoro_long_break';
  static const _keyLongBreakInterval = 'pomodoro_long_break_interval';
  static const _keyAutoStartBreaks = 'pomodoro_auto_start_breaks';
  static const _keyAutoStartWork = 'pomodoro_auto_start_work';
  static const _keyDailyGoal = 'pomodoro_daily_goal';
  static const _keyVolume = 'pomodoro_volume';
  static const _keyThemeId = 'pomodoro_theme_id';
  static const _keyPenguinName = 'pomodoro_penguin_name';
  
  Future<PomodoroSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return PomodoroSettings(
      preset: prefs.getString(_keyPreset) ?? 'classic',
      workDurationMinutes: prefs.getInt(_keyWorkDuration) ?? 25,
      // ... etc
    );
  }
}
```

## Data Schema Design (Claude's Discretion Resolution)

The CONTEXT.md marks data schema as "TO BE DISCUSSED." Based on established patterns in the codebase, here is the recommended schema:

### pomodoro_sessions table
| Column | Type | Constraints | Purpose |
|--------|------|-------------|---------|
| id | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique session ID |
| task_id | INTEGER | NOT NULL, FK -> tasks(id) ON DELETE CASCADE | Linked task |
| session_type | TEXT | NOT NULL, CHECK IN ('work','short_break','long_break') | Session type |
| started_at | INTEGER | NOT NULL | UTC timestamp (milliseconds since epoch) |
| ended_at | INTEGER | NOT NULL | UTC timestamp |
| duration_seconds | INTEGER | NOT NULL | Actual duration |
| planned_duration_seconds | INTEGER | NOT NULL | Configured duration |
| is_completed | INTEGER | NOT NULL DEFAULT 1, CHECK IN (0,1) | Full or partial |
| created_at | INTEGER | NOT NULL | Record creation timestamp |

### Settings Storage
Use `shared_preferences` for all Pomodoro settings (D-05 through D-07, D-24, D-41, D-51, theme selection). Rationale: settings are flat key-value pairs, no relationships, no queries needed. This is the Flutter standard practice.

### Penguin State
Store in `shared_preferences`:
- `pomodoro_penguin_name` (String, default "Tux")
- `pomodoro_penguin_seed` (int, derived from session history hash)
- `pomodoro_penguin_evolution_stage` (int, calculated from total sessions)
- `pomodoro_last_activity_date` (String, ISO date, for streak calculation)

Evolution stage and seed are recomputed from session data; persisting them is a cache optimization. Streak data (D-25, D-46) is calculated from session dates in SQLite.

## Sound Asset Organization

```
assets/
└── sounds/
    ├── neon/           # Futuristic/Neon theme
    │   ├── work_complete.ogg
    │   ├── break_complete.ogg
    │   ├── timer_start.ogg
    │   ├── skip.ogg
    │   ├── stop.ogg
    │   ├── unlock.ogg
    │   └── penguin_chirp_1.ogg through penguin_chirp_6.ogg
    ├── space/          # Sci-Fi/Space
    ├── magic/          # Fantasy/Magic
    ├── gentoo/         # Gentoo/Linux
    ├── cyberpunk/      # Cyberpunk
    ├── retro/          # Retro/8-bit
    └── zen/            # Nature/Zen
```

**Format:** OGG Vorbis (good compression, wide platform support via audioplayers).
**Size budget:** ~30-50KB per sound file, ~2-3MB total for all themes.
**Note:** Sound files must be created externally (synthesizer-designed per D-37) and placed as assets. The code references them by path.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `Timer.periodic` for countdowns | Wall-clock target time + tick recalculation | Standard practice | Background resilience |
| `SharedPreferences.getInstance()` | `SharedPreferencesAsync` (new API) | shared_preferences 2.3+ | Better async handling, but classic API still works |
| audioplayers 4.x/5.x | audioplayers 6.x | 2025 | Breaking API changes, simpler `AudioPlayer` class |
| sqflite manual migrations | sqflite `onUpgrade` with version checks | Established pattern | Safe schema evolution |

## Open Questions

1. **Sound Asset Creation**
   - What we know: Sounds must be synth-designed (Vital/Zebra3/PhasePlant style) per theme genre
   - What's unclear: Who creates these sound assets? They cannot be code-generated.
   - Recommendation: Use placeholder/generic sounds initially, mark as TODO for professional sound design. Simple tones can be generated with `audioplayers` capabilities or sourced from free CC0 sound packs.

2. **Theme Animation Complexity**
   - What we know: D-32 says each theme has "unique animations" (particles, glows)
   - What's unclear: How complex should per-theme animations be? Full particle systems vs. simple color/opacity variations?
   - Recommendation: Start with color-based theming (background, ring color, glow) and simple particle effects using `AnimatedBuilder`. Avoid a full particle engine.

3. **Task Card "Expanded View"**
   - What we know: D-17 says "Start Pomodoro" is only on expanded task card
   - What's unclear: The current `TaskCard` widget does not have an expanded/collapsed state -- it's always fully shown.
   - Recommendation: Add an expandable state to `TaskCard` (tap to expand, showing action buttons including "Start Pomodoro"). This is a modification to existing code.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | Everything | Needs verification | >=3.19.0 required | -- |
| audioplayers | Sound playback | Not yet added | Target ^6.6.0 | Silent mode (no sounds) |
| shared_preferences | Settings storage | Not yet added | Target ^2.5.5 | Use SQLite for settings |
| sqflite | Session data | Already installed | ^2.3.0 | -- |
| fl_chart | Pomodoro analytics | Already installed | ^0.66.0 | -- |

**Missing dependencies with no fallback:**
- None (all are installable via pub)

**Missing dependencies with fallback:**
- Sound assets (placeholder tones can be used until professional sounds are created)

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (built-in) |
| Config file | None (uses pubspec.yaml test config) |
| Quick run command | `flutter test test/unit/` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map

Since this phase has no formal REQ-IDs, tests map to decision groups:

| Behavior Group | Behavior | Test Type | Automated Command | File Exists? |
|----------------|----------|-----------|-------------------|-------------|
| Timer State | State transitions (IDLE->READY->WORK->BREAK) | unit | `flutter test test/unit/domain/pomodoro/timer_state_test.dart` | No - Wave 0 |
| Timer Background | Wall-clock remaining time calculation | unit | `flutter test test/unit/domain/pomodoro/timer_background_test.dart` | No - Wave 0 |
| Session CRUD | Create/read/query Pomodoro sessions | unit | `flutter test test/unit/data/pomodoro/session_datasource_test.dart` | No - Wave 0 |
| Analytics | Daily totals, per-task breakdown, streak calc | unit | `flutter test test/unit/domain/pomodoro/analytics_test.dart` | No - Wave 0 |
| Settings | Load/save settings via shared_preferences | unit | `flutter test test/unit/data/pomodoro/settings_test.dart` | No - Wave 0 |
| Penguin Gen | Procedural generation determinism from seed | unit | `flutter test test/unit/presentation/pomodoro/penguin_test.dart` | No - Wave 0 |
| DB Migration | Version 1->2 upgrade path | integration | `flutter test test/integration/pomodoro_migration_test.dart` | No - Wave 0 |
| Theme Unlock | Unlock logic based on session count | unit | `flutter test test/unit/domain/pomodoro/theme_unlock_test.dart` | No - Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter test test/unit/`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before verification

### Wave 0 Gaps
- [ ] `test/unit/domain/pomodoro/timer_state_test.dart` -- state machine transitions
- [ ] `test/unit/domain/pomodoro/timer_background_test.dart` -- wall-clock calculations
- [ ] `test/unit/data/pomodoro/session_datasource_test.dart` -- session CRUD
- [ ] `test/unit/domain/pomodoro/analytics_test.dart` -- analytics calculations
- [ ] `test/unit/data/pomodoro/settings_test.dart` -- settings persistence
- [ ] `test/unit/presentation/pomodoro/penguin_test.dart` -- procedural generation
- [ ] `test/integration/pomodoro_migration_test.dart` -- DB migration
- [ ] `test/unit/domain/pomodoro/theme_unlock_test.dart` -- unlock logic

## Sources

### Primary (HIGH confidence)
- Existing codebase analysis: `database_helper.dart`, `task_providers.dart`, `task.dart`, `main_screen.dart`, `productivity_charts.dart`, `analytics_providers.dart`, `task_card.dart`
- CONTEXT.md: 56 locked decisions
- UI-SPEC.md: Comprehensive layout, color, animation, and interaction specifications
- [audioplayers pub.dev](https://pub.dev/packages/audioplayers) - version 6.6.0, asset playback API
- [shared_preferences pub.dev](https://pub.dev/packages/shared_preferences) - version 2.5.5

### Secondary (MEDIUM confidence)
- [Flutter background timer patterns](https://navinkumar0118.medium.com/flutter-countdown-timer-works-in-background-f87488b0ba4c) - wall-clock approach verified by multiple sources
- [Flutter CustomPainter for pixel art](https://vibe-studio.ai/insights/building-flutter-widgets-using-custompainter-for-dynamic-art) - standard approach
- [shared_preferences vs sqflite best practices](https://medium.com/@dobri.kostadinov/flutter-data-storage-sharedpreferences-room-and-datastore-compared-69bb529803de)

### Tertiary (LOW confidence)
- Sound asset size estimates (based on general OGG compression ratios, not measured)
- audioplayers 6.x API stability (version is recent, API may have minor changes)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - all packages are well-established, existing codebase patterns are clear
- Architecture: HIGH - clean architecture patterns are established in codebase, extension is straightforward
- Timer state machine: HIGH - wall-clock pattern is well-documented and verified
- Penguin procedural generation: MEDIUM - CustomPainter approach is sound but complexity of pixel art generation is hard to estimate
- Sound system: MEDIUM - audioplayers is standard but 7 theme sound packs require external asset creation
- Pitfalls: HIGH - well-known Flutter timer and audio pitfalls

**Research date:** 2026-04-10
**Valid until:** 2026-05-10 (stable domain, 30 days)
