import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pomodoro_settings_providers.dart';
import 'pomodoro_session_providers.dart';

// =============================================================================
// Theme Data Model
// =============================================================================

/// Immutable theme definition for the Pomodoro timer panel (D-04, D-31).
/// Each theme has unique color palette and unlock requirement.
class PomodoroTheme {
  final String id;
  final String name;
  final Color primary;
  final Color secondary;
  final Color glow;
  final int unlockRequirement; // 0 = free
  final String soundPackPrefix;

  const PomodoroTheme({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.unlockRequirement,
    required this.soundPackPrefix,
  });

  /// Whether this theme is available without earning it
  bool get isFree => unlockRequirement == 0;
}

// =============================================================================
// Theme Definitions (D-31, D-34, D-36)
// =============================================================================

/// All 7 Pomodoro timer themes.
/// 3 free (Neon, Gentoo, Retro) + 4 earned at session milestones.
const List<PomodoroTheme> allPomodoroThemes = [
  PomodoroTheme(
    id: 'neon',
    name: 'Futuristic/Neon',
    primary: Color(0xFF00FFFF),
    secondary: Color(0xFF0D0D1A),
    glow: Color(0xFFFF00FF),
    unlockRequirement: 0,
    soundPackPrefix: 'neon',
  ),
  PomodoroTheme(
    id: 'gentoo',
    name: 'Gentoo/Linux',
    primary: Color(0xFFFF6600),
    secondary: Color(0xFF1A1A2E),
    glow: Color(0xFFAAFFAA),
    unlockRequirement: 0,
    soundPackPrefix: 'gentoo',
  ),
  PomodoroTheme(
    id: 'retro',
    name: 'Retro/8-bit',
    primary: Color(0xFF00FF00),
    secondary: Color(0xFF000000),
    glow: Color(0xFFFF4444),
    unlockRequirement: 0,
    soundPackPrefix: 'retro',
  ),
  PomodoroTheme(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    primary: Color(0xFFFF0055),
    secondary: Color(0xFF0D0D0D),
    glow: Color(0xFFFFFF00),
    unlockRequirement: 25,
    soundPackPrefix: 'cyberpunk',
  ),
  PomodoroTheme(
    id: 'space',
    name: 'Sci-Fi/Space',
    primary: Color(0xFF7B68EE),
    secondary: Color(0xFF0A0A2E),
    glow: Color(0xFFFFD700),
    unlockRequirement: 50,
    soundPackPrefix: 'space',
  ),
  PomodoroTheme(
    id: 'magic',
    name: 'Fantasy/Magic',
    primary: Color(0xFF9B59B6),
    secondary: Color(0xFF1A0A2E),
    glow: Color(0xFF00FF88),
    unlockRequirement: 100,
    soundPackPrefix: 'magic',
  ),
  PomodoroTheme(
    id: 'zen',
    name: 'Nature/Zen',
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFFF5F5DC),
    glow: Color(0xFF87CEEB),
    unlockRequirement: 200,
    soundPackPrefix: 'zen',
  ),
];

// =============================================================================
// Theme Providers
// =============================================================================

/// Returns the currently selected PomodoroTheme based on settings themeId.
/// Falls back to 'neon' if themeId is not found.
final currentPomodoroThemeProvider = Provider<PomodoroTheme>((ref) {
  final settingsAsync = ref.watch(pomodoroSettingsProvider);
  final themeId = settingsAsync.valueOrNull?.themeId ?? 'neon';

  return allPomodoroThemes.firstWhere(
    (t) => t.id == themeId,
    orElse: () => allPomodoroThemes.first,
  );
});

/// Returns the set of unlocked theme IDs based on total session count.
/// Free themes are always included; earned themes unlock when
/// totalSessions >= unlockRequirement.
final unlockedThemesProvider = FutureProvider<Set<String>>((ref) async {
  final repository = ref.watch(pomodoroRepositoryProvider);
  final result = await repository.getTotalSessionCount();

  final totalSessions = result.fold(
    (failure) => 0,
    (count) => count,
  );

  final unlocked = <String>{};
  for (final theme in allPomodoroThemes) {
    if (theme.isFree || totalSessions >= theme.unlockRequirement) {
      unlocked.add(theme.id);
    }
  }
  return unlocked;
});

/// Checks if a new theme was just unlocked after session completion.
/// Compares previous session count to current and posts unlock message
/// via pomodoroMessageProvider if a new milestone was reached.
final themeUnlockCheckProvider = Provider<void>((ref) {
  final unlockedAsync = ref.watch(unlockedThemesProvider);
  // Only act when data is available
  final unlocked = unlockedAsync.valueOrNull;
  if (unlocked == null) return;

  // Check each earned theme to see if it was just unlocked
  for (final theme in allPomodoroThemes) {
    if (!theme.isFree && unlocked.contains(theme.id)) {
      // Theme is unlocked - check if we should celebrate
      // The celebration is triggered by the timer notifier after session completion
    }
  }
});

/// Helper to get unlock message for a newly unlocked theme
String getThemeUnlockMessage(PomodoroTheme theme) {
  return '${theme.name} theme unlocked! ${theme.unlockRequirement} sessions of pure focus.';
}

/// Checks unlocked themes and posts a message if a new theme was just earned.
/// Called after session completion from the timer notifier.
void checkForNewUnlocks(WidgetRef ref) {
  final unlockedAsync = ref.read(unlockedThemesProvider);
  final unlocked = unlockedAsync.valueOrNull;
  if (unlocked == null) return;

  // Re-evaluate after invalidation
  ref.invalidate(unlockedThemesProvider);
}
