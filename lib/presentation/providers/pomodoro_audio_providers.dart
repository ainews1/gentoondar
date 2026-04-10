import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pomodoro_settings_providers.dart';

// =============================================================================
// Audio Service (D-37 through D-42)
// =============================================================================

/// Handles Pomodoro sound playback with per-theme sound packs.
/// Each theme has a matching sound pack prefix used to locate assets.
/// Volume is independently controllable (D-41).
/// No ticking during work sessions (D-39). Sound only, no haptics (D-40).
class PomodoroAudioService {
  double _volume = 0.7;
  String _currentThemePrefix = 'neon';
  bool _isMuted = false;

  /// Play sound for work session completion (D-42: rising synth chord)
  Future<void> playWorkComplete() async {
    await _playSound('work_complete');
  }

  /// Play sound for break session completion (D-42: softer pad sound)
  Future<void> playBreakComplete() async {
    await _playSound('break_complete');
  }

  /// Play sound when timer starts
  Future<void> playTimerStart() async {
    await _playSound('timer_start');
  }

  /// Play sound when skipping a break
  Future<void> playSkip() async {
    await _playSound('skip');
  }

  /// Play sound when stopping the timer
  Future<void> playStop() async {
    await _playSound('stop');
  }

  /// Play sound for theme unlock celebration
  Future<void> playUnlock() async {
    await _playSound('unlock');
  }

  /// Play penguin chirp sound (spontaneous during breaks, D-50)
  Future<void> playPenguinChirp() async {
    await _playSound('penguin_chirp');
  }

  /// Set volume level (0.0 to 1.0). Mutes at 0 (D-41).
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _isMuted = _volume <= 0;
  }

  /// Set the current theme's sound pack prefix
  void setTheme(String themePrefix) {
    _currentThemePrefix = themePrefix;
  }

  /// Clean up resources
  void dispose() {
    // No persistent resources to clean up in placeholder implementation
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  /// Attempt to play a sound asset for the current theme.
  /// In placeholder phase, assets may not exist — errors are caught silently.
  Future<void> _playSound(String eventName) async {
    if (_isMuted) return;

    final assetPath = 'assets/sounds/$_currentThemePrefix/$eventName.ogg';

    try {
      // Verify asset exists before attempting playback.
      // In the placeholder phase, assets do not exist yet, so this will
      // throw and be caught silently. When real sound files are added,
      // this will load and play them via platform channels.
      await rootBundle.load(assetPath);
      // TODO: Integrate audioplayers package for actual playback
      // final player = AudioPlayer();
      // await player.setVolume(_volume);
      // await player.play(AssetSource('sounds/$_currentThemePrefix/$eventName.ogg'));
    } catch (_) {
      // Asset not found (placeholder phase) — silently ignore
    }
  }
}

// =============================================================================
// Provider
// =============================================================================

/// Provides the PomodoroAudioService singleton.
/// Reads volume and themeId from settings to keep audio in sync.
/// Disposes on ref.onDispose.
final pomodoroAudioServiceProvider = Provider<PomodoroAudioService>((ref) {
  final service = PomodoroAudioService();

  // Sync volume and theme from settings
  final settingsAsync = ref.watch(pomodoroSettingsProvider);
  final settings = settingsAsync.valueOrNull;
  if (settings != null) {
    service.setVolume(settings.volume);
    service.setTheme(settings.themeId);
  }

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
