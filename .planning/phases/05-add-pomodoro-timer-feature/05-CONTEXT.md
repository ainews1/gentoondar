# Phase 5: Add Pomodoro Timer Feature - Context

**Gathered:** 2026-04-10
**Status:** Partially gathered (Data & storage still to discuss)

<domain>
## Phase Boundary

Integrate a full-featured Pomodoro timer into the Flutter Task Calendar app. The timer connects to existing tasks, tracks focus sessions, includes a procedurally-generated Gentoo penguin mascot, customizable visual themes with matching synth sound packs, and Pomodoro analytics integrated into the existing analytics screen.

</domain>

<decisions>
## Implementation Decisions

### Timer UI & Placement
- **D-01:** Timer accessible via a **floating action button (FAB)** in bottom-right (standard Material 3 position), available from any screen
- **D-02:** FAB expands into a **compact progress bar panel** (fixed position, not draggable) showing: time remaining, session type (Work/Break), session count, and controls (Pause/Skip/Stop/Close)
- **D-03:** FAB icon is **static** — no countdown or animation on the button itself when timer is running
- **D-04:** Timer panel theme only affects the **timer panel and FAB**, not the rest of the app

### Session Flow & Durations
- **D-05:** **3 presets + custom**: Classic (25/5/15), Deep Work (50/10/20), Sprint (15/3/10), plus user-defined custom durations via sliders
- **D-06:** Auto-start behavior is **configurable** in settings — toggle for auto-start breaks and auto-start work sessions. Default: manual start
- **D-07:** Long break interval is **configurable** (default: every 4 work sessions)
- **D-08:** **Required task link** — user must select a task before starting a Pomodoro
- **D-09:** Task selection via **both options**: "Start Pomodoro" button on expanded task card detail view, OR dropdown task selector in the timer panel (shows today's tasks)
- **D-10:** User **can switch** the linked task mid-session
- **D-11:** Completing a linked task **auto-stops** the timer (session saved as partial)
- **D-12:** Timer **continues running** when app is in background (background timer)
- **D-13:** Closing/reopening the app **resets** the current session (only completed sessions are saved)
- **D-14:** User can **skip breaks** and start working immediately
- **D-15:** Pausing has **no time limit** — user can pause indefinitely
- **D-16:** Sessions are **timer-only** — no manual logging of past sessions
- **D-17:** "Start Pomodoro" only available from **expanded task card**, not from the task list/day view inline
- **D-18:** No lock screen or persistent notification — timer **only visible inside the app**

### Pomodoro Analytics & Tracking
- **D-19:** Pomodoro session history **persisted to SQLite** database
- **D-20:** Pomodoro data shown in **existing Analytics tab** with new charts
- **D-21:** Analytics includes **both** daily totals chart AND per-task breakdown chart
- **D-22:** **Weekly + monthly** Pomodoro summary views (sessions/day trends, average focus time, goal completion rate)
- **D-23:** Timer panel shows **daily count**: "Today: X sessions | Xh Xm focused"
- **D-24:** **Configurable daily goal** for number of Pomodoro sessions, with progress visible in timer panel and analytics
- **D-25:** **Daily streak counter** showing consecutive days with completed Pomodoro sessions
- **D-26:** Completed Pomodoro sessions **appear on day/week calendar views** as colored segments/markers on task blocks

### Calendar Visualization
- **D-27:** Pomodoro blocks on calendar — **Claude's Discretion** on visual approach (colored overlay, small markers, etc.) that fits with existing calendar widgets

### Task Card Integration
- **D-28:** Task cards display a **Pomodoro count badge** showing completed sessions for that task

### Encouraging Messages
- **D-29:** On Pomodoro session completion, show a **SnackBar** at the bottom with encouraging messages
- **D-30:** Messages combine **progress-aware + motivational** content (e.g., "Session 3/4 done — almost at your long break! Keep crushing it!")

### Visual Themes
- **D-31:** **7 customizable themes** for the timer panel: Futuristic/Neon, Sci-Fi/Space, Fantasy/Magic, Gentoo/Linux, Cyberpunk, Retro/8-bit, Nature/Zen
- **D-32:** Each theme has **unique animations** (particles, glows, transitions specific to the theme aesthetic)
- **D-33:** Each theme has a **matching sound pack** with synthesizer-designed sounds
- **D-34:** Theme unlock system: **mix of free and earned** — 2-3 free from start, rest unlock at session count milestones (e.g., 25, 50, 100, 200 sessions)
- **D-35:** Theme selection via **grid of preview cards** in settings — locked themes show lock icon + unlock requirement
- **D-36:** **Claude's Discretion** on which themes are free vs earned

### Sound Design
- **D-37:** Sound packs with **pre-recorded synthesizer sounds** (Vital, Zebra3, PhasePlant style) — genres: neurofunk, dubstep, psytrance per theme
- **D-38:** Each theme gets its **own matching sound pack**
- **D-39:** **No ticking sound** during work sessions — silent focus
- **D-40:** **Sound only** — no haptic/vibration feedback
- **D-41:** **Separate volume control** for Pomodoro sounds in settings (independent of system volume)
- **D-42:** Break sounds vs work-end sounds — **Claude's Discretion** on differentiation approach

### Gentoo Penguin Mascot
- **D-43:** **Pixel art** style Gentoo penguin mascot
- **D-44:** **Infinite procedurally-generated evolution stages** via random function generator
- **D-45:** Random generator varies: **color palette, accessories, size/proportions, background/aura**
- **D-46:** Stage loss is **streak-based** — penguin loses stages after missing multiple consecutive days (e.g., 3 days with no activity)
- **D-47:** Stage loss manifests as **fewer spontaneous sounds** — penguin becomes quieter
- **D-48:** Penguin visible in **timer panel only** (not on FAB or other screens)
- **D-49:** Penguin has **idle animations** — waddles, blinks, looks around, occasional dance (pixel art animations)
- **D-50:** Penguin makes **spontaneous sounds only during breaks** — stays quiet during work focus
- **D-51:** Default name **"Tux"**, user can edit the name in settings
- **D-52:** Evolution celebrations are **subtle transitions** — small sparkle effect in the timer panel, not full-screen

### Settings Screen
- **D-53:** Settings layout — **Claude's Discretion** (single scrollable page recommended given the settings count)
- **D-54:** Preset selector UI — **Claude's Discretion** (segmented control or radio buttons)
- **D-55:** Custom duration input via **sliders**
- **D-56:** Theme picker as **grid of preview cards** with lock icons for locked themes

### Claude's Discretion
- Settings screen overall layout and organization
- Preset selector UI component choice
- Calendar visualization approach for Pomodoro blocks
- Sound differentiation between work-end and break-end
- Which 2-3 themes are free vs earned
- Penguin default name (suggested "Tux")

### Data & Storage (TO BE DISCUSSED)
- Session data schema (what fields per Pomodoro session)
- Settings storage approach (SQLite vs SharedPreferences)
- Penguin state persistence model
- Still needs user input — resume with `/gsd:discuss-phase 5`

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

No external specs — requirements fully captured in decisions above.

### Existing Code
- `lib/domain/entities/task.dart` — Task entity with duration, completion status
- `lib/data/datasources/local/database_helper.dart` — SQLite singleton, schema patterns
- `lib/presentation/providers/task_providers.dart` — Riverpod provider patterns
- `lib/presentation/providers/analytics_providers.dart` — Analytics state management
- `lib/presentation/widgets/charts/productivity_charts.dart` — Existing chart patterns
- `lib/presentation/widgets/navigation/bottom_navigation.dart` — 5-tab nav (no new tab needed)
- `lib/presentation/navigation/app_router.dart` — GoRouter navigation patterns
- `lib/presentation/theme/app_theme.dart` — Material 3 theme configuration
- `lib/presentation/widgets/calendar/day_calendar.dart` — Day view for Pomodoro block display
- `lib/presentation/widgets/calendar/week_calendar.dart` — Week view for Pomodoro block display
- `lib/presentation/widgets/tasks/task_card.dart` — Task card for Pomodoro badge + start button

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- **Task entity** (`lib/domain/entities/task.dart`): Has `durationMinutes`, `isCompleted`, `startTime` — natural link point for Pomodoro sessions
- **Riverpod providers**: Established pattern with AsyncNotifier + AsyncValue for all state management
- **fl_chart integration**: Existing bar charts in analytics — can add Pomodoro charts following same pattern
- **Material 3 theme**: Light/dark mode support with `app_theme.dart` — timer themes layer on top
- **SQLite database helper**: Singleton with optimized indexes, WAL mode — extend with new tables
- **Clean architecture layers**: domain → use cases → repositories → data sources — follow for Pomodoro domain

### Established Patterns
- **Repository pattern**: Abstract data access via interfaces
- **Use case layer**: One use case per operation
- **GoRouter navigation**: Push-based routing with `extra` data passing
- **Equatable entities**: Immutable models with `copyWith`

### Integration Points
- **MainScreen**: FAB overlay wraps the existing Scaffold with bottom nav
- **TaskCard**: Add "Start Pomodoro" button to expanded card view
- **AnalyticsScreen**: Add Pomodoro chart section
- **DayCalendar/WeekCalendar**: Add Pomodoro session markers
- **DatabaseHelper**: New `pomodoro_sessions` and `pomodoro_settings` tables

</code_context>

<specifics>
## Specific Ideas

- **Tamagotchi-inspired mascot**: User specifically wants a virtual pet experience where the penguin's health/happiness reflects productivity
- **Sound design from synth plugins**: Not generic chimes — the sounds should feel like they were designed in Vital, Zebra3, PhasePlant. Electronic music production quality
- **Genre-matched themes**: Neurofunk sounds for Cyberpunk theme, psytrance for Sci-Fi, etc.
- **Procedural generation for penguin**: No fixed evolution path — each user's penguin is unique based on random seed + session history

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-add-pomodoro-timer-feature*
*Context gathered: 2026-04-10 (partially — Data & storage still to discuss)*
