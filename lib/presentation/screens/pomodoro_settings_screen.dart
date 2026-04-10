import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/presentation/providers/pomodoro_settings_providers.dart';
import 'package:task_calendar_app/presentation/widgets/pomodoro/preset_selector.dart';
import 'package:task_calendar_app/presentation/widgets/pomodoro/duration_sliders.dart';

/// Pomodoro settings screen with all configurable options.
/// Sections: Timer Presets, Session Behavior, Daily Goal, Sound, Theme, Penguin.
class PomodoroSettingsScreen extends ConsumerWidget {
  const PomodoroSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(pomodoroSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            'Failed to load settings: $error',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (settings) {
          final notifier = ref.read(pomodoroSettingsProvider.notifier);

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            children: [
              // ===== Section 1: Timer Presets =====
              const _SectionHeading(title: 'Timer Presets'),
              const PresetSelector(),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: settings.preset == 'custom'
                    ? const DurationSliders()
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 24),

              // ===== Section 2: Session Behavior =====
              const _SectionHeading(title: 'Session Behavior'),
              SwitchListTile(
                title: const Text('Auto-start breaks'),
                subtitle: const Text(
                  'Automatically start break timer after work session',
                ),
                value: settings.autoStartBreaks,
                onChanged: (value) {
                  notifier.updateSettings(
                    settings.copyWith(autoStartBreaks: value),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Auto-start work sessions'),
                subtitle: const Text(
                  'Automatically start work timer after break',
                ),
                value: settings.autoStartWork,
                onChanged: (value) {
                  notifier.updateSettings(
                    settings.copyWith(autoStartWork: value),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Long break interval',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${settings.longBreakInterval} sessions',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.longBreakInterval.toDouble(),
                      min: 2,
                      max: 8,
                      divisions: 6,
                      label: '${settings.longBreakInterval} sessions',
                      onChanged: (value) {
                        notifier.updateSettings(
                          settings.copyWith(longBreakInterval: value.round()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== Section 3: Daily Goal =====
              const _SectionHeading(title: 'Daily Goal'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target sessions per day',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${settings.dailyGoal} sessions',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.dailyGoal.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: '${settings.dailyGoal} sessions',
                      onChanged: (value) {
                        notifier.updateSettings(
                          settings.copyWith(dailyGoal: value.round()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== Section 4: Sound =====
              const _SectionHeading(title: 'Sound'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pomodoro volume',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          '${(settings.volume * 100).round()}%',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 20,
                      label: '${(settings.volume * 100).round()}%',
                      onChanged: (value) {
                        notifier.updateVolume(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== Section 5: Theme (Placeholder for Plan 05) =====
              const _SectionHeading(title: 'Theme'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Theme selection will be available in a future update.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== Section 6: Penguin =====
              const _SectionHeading(title: 'Penguin Companion'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: TextEditingController(
                        text: settings.penguinName,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Penguin Name',
                        hintText: 'Enter a name for your penguin',
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          notifier.updatePenguinName(value.trim());
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Placeholder for penguin preview (filled in Plan 06)
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Icon(
                          Icons.pets,
                          size: 40,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

/// Section heading widget with consistent styling.
class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
