import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/data/datasources/local/pomodoro_settings_datasource.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_settings.dart';
import 'pomodoro_session_providers.dart';

// =============================================================================
// Settings State Management
// =============================================================================

/// AsyncNotifierProvider for Pomodoro settings with load/save operations
final pomodoroSettingsProvider =
    AsyncNotifierProvider<PomodoroSettingsNotifier, PomodoroSettings>(
  () => PomodoroSettingsNotifier(),
);

/// Notifier managing Pomodoro settings state.
/// Loads from SharedPreferences on build, persists on every update.
class PomodoroSettingsNotifier extends AsyncNotifier<PomodoroSettings> {
  PomodoroSettingsDatasource get _datasource =>
      ref.read(pomodoroSettingsDatasourceProvider);

  @override
  FutureOr<PomodoroSettings> build() async {
    return await _datasource.loadSettings();
  }

  /// Update all settings and persist to SharedPreferences
  Future<void> updateSettings(PomodoroSettings settings) async {
    state = const AsyncValue.loading();
    try {
      await _datasource.saveSettings(settings);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Apply a preset configuration (classic/deep_work/sprint)
  Future<void> applyPreset(String preset) async {
    final PomodoroSettings presetSettings;
    switch (preset) {
      case 'deep_work':
        presetSettings = PomodoroSettings.deepWork();
      case 'sprint':
        presetSettings = PomodoroSettings.sprint();
      case 'classic':
      default:
        presetSettings = PomodoroSettings.classic();
    }

    // Preserve user's personal settings (volume, theme, penguin name, daily goal)
    final current = state.valueOrNull ?? const PomodoroSettings();
    final merged = presetSettings.copyWith(
      volume: current.volume,
      themeId: current.themeId,
      penguinName: current.penguinName,
      dailyGoal: current.dailyGoal,
      autoStartBreaks: current.autoStartBreaks,
      autoStartWork: current.autoStartWork,
    );

    await updateSettings(merged);
  }

  /// Update volume setting
  Future<void> updateVolume(double volume) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await updateSettings(current.copyWith(volume: volume));
  }

  /// Update theme setting
  Future<void> updateTheme(String themeId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await updateSettings(current.copyWith(themeId: themeId));
  }

  /// Update penguin name
  Future<void> updatePenguinName(String name) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await updateSettings(current.copyWith(penguinName: name));
  }
}
