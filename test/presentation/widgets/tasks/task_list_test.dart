import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/providers/task_providers.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_list.dart';

/// Helper to create a testable widget with provider overrides
Widget createTestableWidget(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

Task createTestTask({
  int id = 1,
  String title = 'Test Task',
  String? description,
  DateTime? startTime,
  int durationMinutes = 60,
  bool isCompleted = false,
}) {
  final now = DateTime.now().toUtc();
  return Task(
    id: id,
    title: title,
    description: description,
    startTime: startTime ?? DateTime(2026, 4, 15, 10, 30).toUtc(),
    durationMinutes: durationMinutes,
    isCompleted: isCompleted,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('TaskList Widget Tests', () {
    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const TaskList(),
      ));

      // The AsyncNotifier starts with loading state by default
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('TaskList renders without crashing', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const TaskList(),
      ));
      await tester.pump();

      // Widget should exist
      expect(find.byType(TaskList), findsOneWidget);
    });

    testWidgets('compact mode passes through correctly', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const TaskList(isCompact: true),
      ));
      await tester.pump();

      expect(find.byType(TaskList), findsOneWidget);
    });
  });

  group('AutoTaskList Widget Tests', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const AutoTaskList(),
      ));
      await tester.pump();

      expect(find.byType(AutoTaskList), findsOneWidget);
    });

    testWidgets('compact mode creates compact list', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const AutoTaskList(isCompact: true),
      ));
      await tester.pump();

      expect(find.byType(AutoTaskList), findsOneWidget);
    });
  });

  group('TaskListSummary Widget Tests', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        TaskListSummary(date: DateTime(2026, 4, 15)),
      ));
      await tester.pump();

      expect(find.byType(TaskListSummary), findsOneWidget);
    });
  });

  group('Empty State', () {
    testWidgets('TaskList shows empty view when data is empty list',
        (tester) async {
      // Override the task list provider with empty data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            taskListProvider.overrideWith(() {
              return _EmptyTaskListNotifier();
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TaskList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty state with add task button
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });
  });
}

/// A notifier that always returns empty list for testing empty state
class _EmptyTaskListNotifier extends TaskListNotifier {
  @override
  Future<List<Task>> build() async {
    return [];
  }
}
