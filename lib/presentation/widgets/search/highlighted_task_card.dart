import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';
import 'package:task_calendar_app/presentation/navigation/app_router.dart';
import 'package:task_calendar_app/presentation/theme/app_theme.dart';

/// TaskCard variant with text highlighting for search results.
/// Extends existing TaskCard pattern with highlighted matching text per D-08, D-09.
class HighlightedTaskCard extends ConsumerWidget {
  final Task task;
  final String searchTerm;

  const HighlightedTaskCard({
    super.key, 
    required this.task, 
    required this.searchTerm,
  });

  /// Format date and time for display
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy at h:mm a').format(dateTime.toLocal());
  }

  /// Format duration for display
  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ${hours == 1 ? 'hr' : 'hrs'}';
    }
    return '$hours hr $remainingMinutes min';
  }

  /// Build highlighted text using RichText and TextSpan per RESEARCH.md pattern
  Widget _buildHighlightedText(
    String text, 
    String searchTerm, 
    TextStyle baseStyle,
  ) {
    // Handle empty search term gracefully
    if (searchTerm.trim().isEmpty) {
      return Text(text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    final matches = RegExp(
      RegExp.escape(searchTerm), 
      caseSensitive: false,
    ).allMatches(text);
    
    int lastIndex = 0;
    for (final match in matches) {
      // Add non-highlighted text before match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      
      // Add highlighted match text
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: baseStyle.copyWith(
          backgroundColor: Colors.yellow.shade200,
          fontWeight: FontWeight.w600,
        ),
      ));
      lastIndex = match.end;
    }
    
    // Add remaining non-highlighted text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }
    
    return RichText(
      text: TextSpan(children: spans),
      maxLines: baseStyle == AppTextStyles.taskTitle ? 2 : 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Create snippet preview for description matches per D-09
  String _createDescriptionSnippet(String description, String searchTerm) {
    if (searchTerm.trim().isEmpty || description.isEmpty) {
      return description;
    }

    final lowerDescription = description.toLowerCase();
    final lowerSearchTerm = searchTerm.toLowerCase();
    final matchIndex = lowerDescription.indexOf(lowerSearchTerm);
    
    if (matchIndex == -1) {
      // No match in description, return truncated version
      return description.length > 100 
          ? '${description.substring(0, 100)}...' 
          : description;
    }

    // Create snippet around the match
    const snippetLength = 80;
    final start = (matchIndex - 30).clamp(0, description.length);
    final end = (matchIndex + searchTerm.length + 30).clamp(0, description.length);
    
    String snippet = description.substring(start, end);
    
    // Add ellipsis if we truncated
    if (start > 0) snippet = '...$snippet';
    if (end < description.length) snippet = '$snippet...';
    
    return snippet;
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text(
          'Are you sure you want to delete "${task.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Handle task completion toggle
  void _toggleCompletion(WidgetRef ref) {
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now().toUtc(),
    );
    
    ref.read(updateTaskProvider.notifier).updateTask(updatedTask);
  }

  /// Handle task deletion
  void _deleteTask(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteDialog(context);
    if (confirmed == true) {
      ref.read(deleteTaskProvider.notifier).deleteTask(
        task.id,
        task.startTime,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine visual style based on completion status
    final isCompleted = task.isCompleted;
    final titleStyle = isCompleted 
        ? AppTextStyles.taskTitleCompleted 
        : AppTextStyles.taskTitle;
    
    final cardColor = isCompleted 
        ? colorScheme.surfaceVariant.withOpacity(0.5)
        : colorScheme.surface;

    // Create snippet for description if it contains search term
    final descriptionToShow = task.description?.isNotEmpty == true
        ? _createDescriptionSnippet(task.description!, searchTerm)
        : null;

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with checkbox and title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isCompleted,
                      onChanged: (_) => _toggleCompletion(ref),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and description with highlighting
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Highlighted title
                      _buildHighlightedText(
                        task.title, 
                        searchTerm, 
                        titleStyle,
                      ),
                      
                      // Highlighted description with snippet
                      if (descriptionToShow?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        _buildHighlightedText(
                          descriptionToShow!,
                          searchTerm,
                          AppTextStyles.taskDescription.copyWith(
                            color: isCompleted 
                                ? Colors.grey.shade500 
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Action buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      onPressed: () => AppNavigation.goToEditTask(context, task),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit task',
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      color: colorScheme.primary,
                    ),
                    
                    // Delete button
                    IconButton(
                      onPressed: () => _deleteTask(context, ref),
                      icon: const Icon(Icons.delete_outlined),
                      tooltip: 'Delete task',
                      iconSize: 20,
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      color: colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Task metadata row
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                // Date and time
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.startTime),
                      style: AppTextStyles.taskMetadata,
                    ),
                  ],
                ),
                
                // Duration
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(task.durationMinutes),
                      style: AppTextStyles.taskMetadata,
                    ),
                  ],
                ),
                
                // Completion status indicator
                if (isCompleted)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: AppTextStyles.taskMetadata.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}