import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_settings_providers.dart';

/// Segmented button widget for selecting Pomodoro timer presets.
/// Supports Classic (25/5/15), Deep Work (50/10/20), Sprint (15/3/10),
/// and Custom presets.
class PresetSelector extends ConsumerWidget {
  /// Callback fired when custom selection state changes.
  /// [isCustom] is true when the 'custom' preset is selected.
  final ValueChanged<bool>? onCustomSelected;

  const PresetSelector({
    super.key,
    this.onCustomSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(pomodoroSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Failed to load presets',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (settings) {
        final selectedPreset = settings.preset;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment<String>(
                value: 'classic',
                label: Text('Classic'),
                tooltip: '25/5/15 minutes',
              ),
              ButtonSegment<String>(
                value: 'deep_work',
                label: Text('Deep Work'),
                tooltip: '50/10/20 minutes',
              ),
              ButtonSegment<String>(
                value: 'sprint',
                label: Text('Sprint'),
                tooltip: '15/3/10 minutes',
              ),
              ButtonSegment<String>(
                value: 'custom',
                label: Text('Custom'),
                tooltip: 'Set your own durations',
              ),
            ],
            selected: {selectedPreset},
            onSelectionChanged: (Set<String> selection) {
              final value = selection.first;
              if (value == 'custom') {
                // For custom, update preset field but don't change durations
                final currentSettings = settings.copyWith(preset: 'custom');
                ref
                    .read(pomodoroSettingsProvider.notifier)
                    .updateSettings(currentSettings);
              } else {
                ref
                    .read(pomodoroSettingsProvider.notifier)
                    .applyPreset(value);
              }
              onCustomSelected?.call(value == 'custom');
            },
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(
                Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        );
      },
    );
  }
}
