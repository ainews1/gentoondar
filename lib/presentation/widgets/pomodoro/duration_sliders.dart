import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_settings_providers.dart';

/// Duration slider controls for custom Pomodoro timer settings.
/// Provides sliders for work duration, short break, and long break.
/// Only visible when preset is 'custom' -- parent wraps in AnimatedSize.
class DurationSliders extends ConsumerWidget {
  const DurationSliders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(pomodoroSettingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Work Duration slider: 5-90 min, step 5
              _DurationSliderTile(
                label: 'Work Duration',
                value: settings.workDurationMinutes.toDouble(),
                min: 5,
                max: 90,
                divisions: 17, // (90 - 5) / 5 = 17
                stepLabel: '${settings.workDurationMinutes} min',
                onChanged: (value) {
                  ref
                      .read(pomodoroSettingsProvider.notifier)
                      .updateSettings(settings.copyWith(
                        workDurationMinutes: value.round(),
                        preset: 'custom',
                      ));
                },
              ),

              const SizedBox(height: 12),

              // Short Break slider: 1-30 min, step 1
              _DurationSliderTile(
                label: 'Short Break',
                value: settings.shortBreakMinutes.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                stepLabel: '${settings.shortBreakMinutes} min',
                onChanged: (value) {
                  ref
                      .read(pomodoroSettingsProvider.notifier)
                      .updateSettings(settings.copyWith(
                        shortBreakMinutes: value.round(),
                        preset: 'custom',
                      ));
                },
              ),

              const SizedBox(height: 12),

              // Long Break slider: 5-60 min, step 1
              _DurationSliderTile(
                label: 'Long Break',
                value: settings.longBreakMinutes.toDouble(),
                min: 5,
                max: 60,
                divisions: 55,
                stepLabel: '${settings.longBreakMinutes} min',
                onChanged: (value) {
                  ref
                      .read(pomodoroSettingsProvider.notifier)
                      .updateSettings(settings.copyWith(
                        longBreakMinutes: value.round(),
                        preset: 'custom',
                      ));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Internal widget for a labeled slider with value display.
class _DurationSliderTile extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String stepLabel;
  final ValueChanged<double> onChanged;

  const _DurationSliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.stepLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              stepLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: stepLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
