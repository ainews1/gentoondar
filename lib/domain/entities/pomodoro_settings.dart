/// Pomodoro timer settings with preset configurations.
/// Stores all user-configurable timer, UI, and companion preferences.
class PomodoroSettings {
  const PomodoroSettings({
    this.preset = 'classic',
    this.workDurationMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.longBreakInterval = 4,
    this.autoStartBreaks = false,
    this.autoStartWork = false,
    this.dailyGoal = 8,
    this.volume = 0.7,
    this.themeId = 'neon',
    this.penguinName = 'Tux',
  });

  /// Preset name: 'classic', 'deep_work', 'sprint', or 'custom'
  final String preset;

  /// Work session duration in minutes (default 25)
  final int workDurationMinutes;

  /// Short break duration in minutes (default 5)
  final int shortBreakMinutes;

  /// Long break duration in minutes (default 15)
  final int longBreakMinutes;

  /// Number of work sessions before a long break (default 4)
  final int longBreakInterval;

  /// Whether to automatically start breaks after work sessions
  final bool autoStartBreaks;

  /// Whether to automatically start work after breaks
  final bool autoStartWork;

  /// Daily pomodoro session goal (default 8)
  final int dailyGoal;

  /// Sound volume 0.0-1.0 (default 0.7)
  final double volume;

  /// Visual theme identifier (default 'neon')
  final String themeId;

  /// Companion penguin name (default 'Tux')
  final String penguinName;

  /// Classic preset: 25/5/15
  static PomodoroSettings classic() => const PomodoroSettings(
        preset: 'classic',
        workDurationMinutes: 25,
        shortBreakMinutes: 5,
        longBreakMinutes: 15,
      );

  /// Deep work preset: 50/10/20
  static PomodoroSettings deepWork() => const PomodoroSettings(
        preset: 'deep_work',
        workDurationMinutes: 50,
        shortBreakMinutes: 10,
        longBreakMinutes: 20,
      );

  /// Sprint preset: 15/3/10
  static PomodoroSettings sprint() => const PomodoroSettings(
        preset: 'sprint',
        workDurationMinutes: 15,
        shortBreakMinutes: 3,
        longBreakMinutes: 10,
      );

  /// Create a copy with updated fields
  PomodoroSettings copyWith({
    String? preset,
    int? workDurationMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? longBreakInterval,
    bool? autoStartBreaks,
    bool? autoStartWork,
    int? dailyGoal,
    double? volume,
    String? themeId,
    String? penguinName,
  }) {
    return PomodoroSettings(
      preset: preset ?? this.preset,
      workDurationMinutes: workDurationMinutes ?? this.workDurationMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      longBreakInterval: longBreakInterval ?? this.longBreakInterval,
      autoStartBreaks: autoStartBreaks ?? this.autoStartBreaks,
      autoStartWork: autoStartWork ?? this.autoStartWork,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      volume: volume ?? this.volume,
      themeId: themeId ?? this.themeId,
      penguinName: penguinName ?? this.penguinName,
    );
  }

  @override
  String toString() {
    return 'PomodoroSettings(preset: $preset, work: ${workDurationMinutes}m, '
        'shortBreak: ${shortBreakMinutes}m, longBreak: ${longBreakMinutes}m, '
        'goal: $dailyGoal)';
  }
}
