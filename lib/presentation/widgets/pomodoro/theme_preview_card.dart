import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pomodoro_theme_providers.dart';

/// Preview card for a single Pomodoro theme in the theme picker grid (D-35).
/// Shows theme name, 3 color swatches, lock state overlay, and selection border.
/// Accessible with Semantics label describing theme state.
class ThemePreviewCard extends ConsumerWidget {
  final PomodoroTheme theme;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback? onTap;

  const ThemePreviewCard({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.isLocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semanticLabel = isLocked
        ? '${theme.name}. Locked, complete ${theme.unlockRequirement} sessions to unlock'
        : '${theme.name}. Unlocked${isSelected ? ', currently selected' : ''}';

    return Semantics(
      label: semanticLabel,
      button: !isLocked,
      child: GestureDetector(
        onTap: isLocked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Complete ${theme.unlockRequirement} sessions to unlock ${theme.name}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: theme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? theme.primary : Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: Stack(
              children: [
                // Theme content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Theme name
                      Text(
                        theme.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getTextColor(theme.secondary),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Color swatch circles
                      Row(
                        children: [
                          _ColorSwatch(color: theme.primary),
                          const SizedBox(width: 8),
                          _ColorSwatch(color: theme.secondary),
                          const SizedBox(width: 8),
                          _ColorSwatch(color: theme.glow),
                        ],
                      ),
                    ],
                  ),
                ),

                // Lock overlay
                if (isLocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock,
                            size: 32,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete ${theme.unlockRequirement} sessions',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Determine text color based on background luminance
  Color _getTextColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Small circular color swatch (16px) for theme preview
class _ColorSwatch extends StatelessWidget {
  final Color color;

  const _ColorSwatch({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }
}
