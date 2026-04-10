import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_theme_providers.dart';
import '../../providers/pomodoro_settings_providers.dart';
import 'theme_preview_card.dart';

/// Grid of theme preview cards for selecting the Pomodoro timer theme (D-56).
/// 2-column layout showing all 7 themes with lock/unlock state.
/// Selecting an unlocked theme updates settings via pomodoroSettingsProvider.
class ThemePickerGrid extends ConsumerWidget {
  const ThemePickerGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedAsync = ref.watch(unlockedThemesProvider);
    final settingsAsync = ref.watch(pomodoroSettingsProvider);

    final unlocked = unlockedAsync.valueOrNull ?? {'neon', 'gentoo', 'retro'};
    final currentThemeId = settingsAsync.valueOrNull?.themeId ?? 'neon';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: allPomodoroThemes.map((theme) {
          final isLocked = !unlocked.contains(theme.id);
          final isSelected = theme.id == currentThemeId;

          return ThemePreviewCard(
            theme: theme,
            isSelected: isSelected,
            isLocked: isLocked,
            onTap: () {
              ref.read(pomodoroSettingsProvider.notifier).updateTheme(theme.id);
            },
          );
        }).toList(),
      ),
    );
  }
}
