import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/data/datasources/local/pomodoro_settings_datasource.dart';
import 'package:task_calendar_app/domain/entities/penguin_state.dart';
import 'pomodoro_session_providers.dart';

// =============================================================================
// Penguin State Management
// =============================================================================

/// AsyncNotifierProvider for penguin companion state.
/// Manages evolution, streak tracking, and procedural generation seed.
final penguinStateProvider =
    AsyncNotifierProvider<PenguinStateNotifier, PenguinState>(
  () => PenguinStateNotifier(),
);

/// Notifier managing penguin evolution, streaks, and persistence.
/// Loads initial state from SharedPreferences via [PomodoroSettingsDatasource],
/// recalculates evolution from session data on refresh.
class PenguinStateNotifier extends AsyncNotifier<PenguinState> {
  PomodoroSettingsDatasource get _datasource =>
      ref.read(pomodoroSettingsDatasourceProvider);

  @override
  FutureOr<PenguinState> build() async {
    return await _datasource.loadPenguinState();
  }

  /// Refresh penguin state from session data.
  /// Queries total session count, recalculates evolutionStage and seed, saves.
  Future<void> refreshFromSessions() async {
    final current = state.valueOrNull ?? const PenguinState();

    // Get total sessions from daily count provider (lifetime total from stored state)
    final repository = ref.read(pomodoroRepositoryProvider);
    final streakResult = await repository.getStreak();
    final streak = streakResult.fold((_) => current.currentStreak, (s) => s);

    // Get daily count to check if there was activity today
    final dailyResult =
        await repository.getDailySessionCount(DateTime.now());
    final dailyCount = dailyResult.fold((_) => 0, (c) => c);

    final updated = current.copyWith(
      currentStreak: streak,
      lastActivityDate:
          dailyCount > 0 ? DateTime.now().toUtc() : current.lastActivityDate,
    );

    await _datasource.savePenguinState(updated);
    state = AsyncValue.data(updated);
  }

  /// Update streak from session dates and persist.
  Future<void> updateStreak() async {
    final current = state.valueOrNull ?? const PenguinState();
    final repository = ref.read(pomodoroRepositoryProvider);
    final result = await repository.getStreak();

    final streak = result.fold((_) => current.currentStreak, (s) => s);
    final updated = current.copyWith(currentStreak: streak);

    await _datasource.savePenguinState(updated);
    state = AsyncValue.data(updated);
  }

  /// Record a completed session, incrementing totalSessions.
  /// Returns true if evolution stage changed (for sparkle trigger).
  Future<bool> checkEvolution() async {
    final current = state.valueOrNull ?? const PenguinState();
    final previousStage = current.evolutionStage;

    final updated = current.copyWith(
      totalSessions: current.totalSessions + 1,
      lastActivityDate: DateTime.now().toUtc(),
    );

    await _datasource.savePenguinState(updated);
    state = AsyncValue.data(updated);

    return updated.evolutionStage > previousStage;
  }

  /// Update the penguin name.
  Future<void> updateName(String name) async {
    final current = state.valueOrNull ?? const PenguinState();
    final updated = current.copyWith(name: name);
    await _datasource.savePenguinState(updated);
    state = AsyncValue.data(updated);
  }
}

// =============================================================================
// Animation Frame Provider
// =============================================================================

/// StateProvider for current animation frame (0-7).
/// Managed by PenguinWidget's AnimationController.
final penguinAnimationFrameProvider = StateProvider<int>((ref) => 0);
