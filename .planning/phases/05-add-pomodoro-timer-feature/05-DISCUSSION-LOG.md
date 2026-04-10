# Phase 5: Add Pomodoro Timer Feature - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-10
**Phase:** 05-add-pomodoro-timer-feature
**Areas discussed:** Timer UI & placement, Session flow & durations, Notifications & sounds, Theme system details, Penguin mascot details, Settings screen
**Status:** Partially complete — Data & storage still to discuss

---

## Timer UI & Placement

| Option | Description | Selected |
|--------|-------------|----------|
| New bottom nav tab | Add a 6th 'Timer' tab | |
| Floating overlay button | FAB that expands into mini timer overlay | ✓ |
| Integrated in task card | Timer shows inline on task card | |

**User's choice:** Floating overlay button
**Notes:** Accessible from any screen

| Option | Description | Selected |
|--------|-------------|----------|
| Circular countdown ring | Large ring with time in center | |
| Compact progress bar | Minimal horizontal bar | ✓ |
| You decide | Claude picks | |

**User's choice:** Compact progress bar

| Option | Description | Selected |
|--------|-------------|----------|
| Show time on FAB | FAB displays remaining time | |
| Pulsing icon | Animated indicator | |
| Static icon | Same icon always | ✓ |

**User's choice:** Static icon

| Option | Description | Selected |
|--------|-------------|----------|
| Bottom-right (standard) | Standard Material 3 FAB | ✓ |
| Bottom-center | Centered above nav | |
| Top-right corner | Persistent top corner | |

| Option | Description | Selected |
|--------|-------------|----------|
| Fixed position | Always expands to same spot | ✓ |
| Draggable | User can reposition | |

---

## Session Flow & Durations

| Option | Description | Selected |
|--------|-------------|----------|
| Classic fixed (25/5/15) | No customization | |
| Customizable durations | User sets own times | |
| Presets + custom | Preset profiles + custom | ✓ |

**Presets:** Classic (25/5/15), Deep Work (50/10/20), Sprint (15/3/10)

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-start next | Hands-free flow | |
| Manual start each | Full control | |
| Configurable | Toggle in settings | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Fixed at 4 | Classic interval | |
| Configurable (default 4) | User can change | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Persist sessions | Store in SQLite | ✓ |
| In-memory only | Resets on restart | |
| Basic count only | Lightweight | |

| Option | Description | Selected |
|--------|-------------|----------|
| Optional task link | Can optionally select task | |
| Required task link | Must select task | ✓ |
| No task linking | Standalone timer | |

| Option | Description | Selected |
|--------|-------------|----------|
| Both options | Task card button + dropdown | ✓ |
| Dropdown only | Timer panel selector | |
| Task card only | Start from card | |

| Option | Description | Selected |
|--------|-------------|----------|
| Locked once started | Cannot change task | |
| Can switch mid-session | Change linked task | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-stop timer | Task complete stops Pomodoro | ✓ |
| Keep timer running | Continue after task done | |
| Ask the user | Dialog prompt | |

| Option | Description | Selected |
|--------|-------------|----------|
| Background timer | Continues when backgrounded | ✓ |
| Pause when backgrounded | Stops in background | |

| Option | Description | Selected |
|--------|-------------|----------|
| No lock screen | Timer only inside app | ✓ |
| Persistent notification | Ongoing notification | |

| Option | Description | Selected |
|--------|-------------|----------|
| Allow skip breaks | Jump to next work | ✓ |
| Enforce breaks | Mandatory breaks | |

| Option | Description | Selected |
|--------|-------------|----------|
| Resume where left off | Persist timer state | |
| Reset session | Close = reset current | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| From task list too | Timer icon on cards in list | |
| Only from expanded card | Must open details | ✓ |

**Analytics decisions:**
- Add to existing Analytics tab: ✓
- Both daily totals AND per-task breakdown: ✓
- Weekly + monthly Pomodoro summary: ✓
- Daily count in timer panel: ✓
- Configurable daily goal: ✓
- Daily streak counter: ✓
- Show on day/week calendar: ✓
- Pomodoro count badge on task cards: ✓

**Other:**
- Timer-only (no manual logging): ✓
- No pause time limit: ✓
- Theme-adaptive colors (Material 3): ✓

---

## Notifications & Sounds (merged with Design brainstorm)

**Encouraging messages:**
- Combined progress-aware + motivational messages
- Display via SnackBar at bottom (auto-dismiss)

**Sound design:**
- Pre-recorded synthesizer sounds (Vital, Zebra3, PhasePlant style)
- Genre themes: neurofunk, dubstep, psytrance
- Each visual theme gets matching sound pack
- No ticking during work sessions
- Sound only (no haptics/vibration)
- Separate volume control in settings
- No sound preview in theme picker

**Penguin sounds:**
- Makes spontaneous sounds only during breaks (quiet during work)
- Frequency decreases when losing stages (streak broken)

---

## Theme System Details

**Themes (7 total):**
1. Futuristic/Neon — glowing neon lines, synthwave
2. Sci-Fi/Space — starfield, metallic, alien tech
3. Fantasy/Magic — crystals, arcane glyphs, particles
4. Gentoo/Linux — terminal-style, green-on-dark hacker
5. Cyberpunk — neon pink/cyan, glitch effects
6. Retro/8-bit — pixel art, chiptune-inspired
7. Nature/Zen — soft greens, water ripples, calming

**Scope:** Timer panel only (not whole app)
**Animations:** Per-theme unique animations
**Unlock:** Mix — some free, some earned at session count milestones
**Selection UI:** Grid of preview cards with lock icons

---

## Penguin Mascot Details

- **Art style:** Pixel art (retro)
- **Evolution:** Infinite procedurally-generated stages via random function
- **Randomized aspects:** Color palette, accessories, size/proportions, background/aura
- **Stage loss:** Streak-based (3+ days no activity)
- **Stage loss effect:** Fewer spontaneous sounds
- **Visibility:** Timer panel only
- **Idle animations:** Yes — waddle, blink, look around, dance
- **Sounds:** Only during breaks
- **Name:** Default "Tux", user-editable
- **Evolution celebration:** Subtle sparkle transition in panel

---

## Settings Screen

- **Layout:** Claude's Discretion
- **Theme picker:** Grid of previews with lock icons
- **Preset selector:** Claude's Discretion
- **Custom durations:** Sliders
- **Volume:** Separate slider for Pomodoro sounds

---

## Claude's Discretion

- Settings screen layout/organization
- Preset selector UI component
- Calendar Pomodoro block visualization
- Sound differentiation work-end vs break-end
- Which themes are free vs earned
- Penguin default name

## Deferred Ideas

None — discussion stayed within phase scope

## Remaining Areas (not yet discussed)

- **Data & storage design** — Session schema, settings storage, penguin state persistence
