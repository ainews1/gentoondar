---
phase: 5
slug: add-pomodoro-timer-feature
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-10
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (built-in) + integration_test |
| **Config file** | `pubspec.yaml` (test dependencies already present) |
| **Quick run command** | `flutter test --tags pomodoro` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test --tags pomodoro`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 01 | 1 | D-19 | unit | `flutter test test/data/pomodoro_session_test.dart` | ❌ W0 | ⬜ pending |
| 05-01-02 | 01 | 1 | D-05,D-06,D-07 | unit | `flutter test test/domain/pomodoro_timer_test.dart` | ❌ W0 | ⬜ pending |
| 05-02-01 | 02 | 2 | D-01,D-02,D-03 | widget | `flutter test test/presentation/pomodoro_fab_test.dart` | ❌ W0 | ⬜ pending |
| 05-02-02 | 02 | 2 | D-08,D-09,D-10 | widget | `flutter test test/presentation/task_link_test.dart` | ❌ W0 | ⬜ pending |
| 05-03-01 | 03 | 3 | D-20,D-21,D-22 | widget | `flutter test test/presentation/pomodoro_analytics_test.dart` | ❌ W0 | ⬜ pending |
| 05-04-01 | 04 | 4 | D-31,D-32 | widget | `flutter test test/presentation/timer_theme_test.dart` | ❌ W0 | ⬜ pending |
| 05-05-01 | 05 | 5 | D-43,D-44,D-45 | unit | `flutter test test/domain/penguin_generator_test.dart` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/data/pomodoro_session_test.dart` — stubs for session CRUD
- [ ] `test/domain/pomodoro_timer_test.dart` — stubs for timer state machine
- [ ] `test/presentation/pomodoro_fab_test.dart` — stubs for FAB + panel UI
- [ ] `test/presentation/task_link_test.dart` — stubs for task linking
- [ ] `test/presentation/pomodoro_analytics_test.dart` — stubs for analytics charts
- [ ] `test/presentation/timer_theme_test.dart` — stubs for theme switching
- [ ] `test/domain/penguin_generator_test.dart` — stubs for procedural penguin generation

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Sound playback | D-37,D-38,D-39 | Audio output requires device/emulator | Play each theme's sounds, verify genre matches, no ticking during work |
| Background timer | D-12 | Background state requires manual app lifecycle | Start timer → switch app → return → verify time advanced |
| Pixel art rendering | D-43,D-44 | Visual quality assessment | Inspect rendered penguin at multiple evolution stages |
| Theme animations | D-32 | Visual animation quality | Observe unique animations per theme |
| Encouraging messages | D-29,D-30 | Context-aware message quality | Complete sessions and verify messages match progress |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
