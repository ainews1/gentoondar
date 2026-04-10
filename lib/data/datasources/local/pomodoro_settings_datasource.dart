import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_calendar_app/domain/entities/pomodoro_settings.dart';
import 'package:task_calendar_app/domain/entities/penguin_state.dart';

/// SharedPreferences-based storage for Pomodoro settings and penguin state.
/// All keys are prefixed with 'pomodoro_' to avoid collisions.
class PomodoroSettingsDatasource {
  // Settings keys
  static const String _keyPreset = 'pomodoro_preset';
  static const String _keyWorkDuration = 'pomodoro_work_duration';
  static const String _keyShortBreak = 'pomodoro_short_break';
  static const String _keyLongBreak = 'pomodoro_long_break';
  static const String _keyLongBreakInterval = 'pomodoro_long_break_interval';
  static const String _keyAutoStartBreaks = 'pomodoro_auto_start_breaks';
  static const String _keyAutoStartWork = 'pomodoro_auto_start_work';
  static const String _keyDailyGoal = 'pomodoro_daily_goal';
  static const String _keyVolume = 'pomodoro_volume';
  static const String _keyThemeId = 'pomodoro_theme_id';
  static const String _keyPenguinName = 'pomodoro_penguin_name';

  // Penguin state keys
  static const String _keyPenguinSeed = 'pomodoro_penguin_seed';
  static const String _keyPenguinEvolutionStage =
      'pomodoro_penguin_evolution_stage';
  static const String _keyPenguinTotalSessions =
      'pomodoro_penguin_total_sessions';
  static const String _keyPenguinCurrentStreak =
      'pomodoro_penguin_current_streak';
  static const String _keyLastActivityDate = 'pomodoro_last_activity_date';

  /// Load Pomodoro settings from SharedPreferences.
  /// Returns default PomodoroSettings values for any missing keys.
  Future<PomodoroSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const defaults = PomodoroSettings();

      return PomodoroSettings(
        preset: prefs.getString(_keyPreset) ?? defaults.preset,
        workDurationMinutes:
            prefs.getInt(_keyWorkDuration) ?? defaults.workDurationMinutes,
        shortBreakMinutes:
            prefs.getInt(_keyShortBreak) ?? defaults.shortBreakMinutes,
        longBreakMinutes:
            prefs.getInt(_keyLongBreak) ?? defaults.longBreakMinutes,
        longBreakInterval:
            prefs.getInt(_keyLongBreakInterval) ?? defaults.longBreakInterval,
        autoStartBreaks:
            prefs.getBool(_keyAutoStartBreaks) ?? defaults.autoStartBreaks,
        autoStartWork:
            prefs.getBool(_keyAutoStartWork) ?? defaults.autoStartWork,
        dailyGoal: prefs.getInt(_keyDailyGoal) ?? defaults.dailyGoal,
        volume: prefs.getDouble(_keyVolume) ?? defaults.volume,
        themeId: prefs.getString(_keyThemeId) ?? defaults.themeId,
        penguinName: prefs.getString(_keyPenguinName) ?? defaults.penguinName,
      );
    } catch (e) {
      throw Exception('Failed to load pomodoro settings: $e');
    }
  }

  /// Save all Pomodoro settings to SharedPreferences.
  Future<void> saveSettings(PomodoroSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyPreset, settings.preset);
      await prefs.setInt(_keyWorkDuration, settings.workDurationMinutes);
      await prefs.setInt(_keyShortBreak, settings.shortBreakMinutes);
      await prefs.setInt(_keyLongBreak, settings.longBreakMinutes);
      await prefs.setInt(_keyLongBreakInterval, settings.longBreakInterval);
      await prefs.setBool(_keyAutoStartBreaks, settings.autoStartBreaks);
      await prefs.setBool(_keyAutoStartWork, settings.autoStartWork);
      await prefs.setInt(_keyDailyGoal, settings.dailyGoal);
      await prefs.setDouble(_keyVolume, settings.volume);
      await prefs.setString(_keyThemeId, settings.themeId);
      await prefs.setString(_keyPenguinName, settings.penguinName);
    } catch (e) {
      throw Exception('Failed to save pomodoro settings: $e');
    }
  }

  /// Load penguin companion state from SharedPreferences.
  Future<PenguinState> loadPenguinState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final lastActivityMs = prefs.getInt(_keyLastActivityDate);

      return PenguinState(
        name: prefs.getString(_keyPenguinName) ?? 'Tux',
        totalSessions: prefs.getInt(_keyPenguinTotalSessions) ?? 0,
        currentStreak: prefs.getInt(_keyPenguinCurrentStreak) ?? 0,
        lastActivityDate: lastActivityMs != null
            ? DateTime.fromMillisecondsSinceEpoch(lastActivityMs, isUtc: true)
            : null,
      );
    } catch (e) {
      throw Exception('Failed to load penguin state: $e');
    }
  }

  /// Save penguin companion state to SharedPreferences.
  Future<void> savePenguinState(PenguinState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyPenguinName, state.name);
      await prefs.setInt(_keyPenguinTotalSessions, state.totalSessions);
      await prefs.setInt(_keyPenguinCurrentStreak, state.currentStreak);
      await prefs.setInt(_keyPenguinSeed, state.seed);
      await prefs.setInt(_keyPenguinEvolutionStage, state.evolutionStage);

      if (state.lastActivityDate != null) {
        await prefs.setInt(
          _keyLastActivityDate,
          state.lastActivityDate!.millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      throw Exception('Failed to save penguin state: $e');
    }
  }
}
