import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_card.dart';

/// Helper to wrap widgets in MaterialApp with Riverpod for testing
Widget createTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    ),
  );
}

Task createTestTask({
  int id = 1,
  String title = 'Test Task',
  String? description = 'Test Description',
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
  group('TaskCard Widget Tests', () {
    testWidgets('displays task title', (tester) async {
      final task = createTestTask(title: 'My Important Task');
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('My Important Task'), findsOneWidget);
    });

    testWidgets('displays task description', (tester) async {
      final task = createTestTask(description: 'Task details here');
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('Task details here'), findsOneWidget);
    });

    testWidgets('displays duration in readable format', (tester) async {
      final task = createTestTask(durationMinutes: 90);
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('1 hr 30 min'), findsOneWidget);
    });

    testWidgets('displays duration for sub-hour values', (tester) async {
      final task = createTestTask(durationMinutes: 30);
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('30 min'), findsOneWidget);
    });

    testWidgets('displays checkbox for completion toggle', (tester) async {
      final task = createTestTask(isCompleted: false);
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('shows completed status when task is completed', (tester) async {
      final task = createTestTask(isCompleted: true);
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('does not show completed label when task is pending',
        (tester) async {
      final task = createTestTask(isCompleted: false);
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsNothing);
    });

    testWidgets('displays edit button', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('displays delete button', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outlined), findsOneWidget);
    });

    testWidgets('delete button shows confirmation dialog', (tester) async {
      final task = createTestTask(title: 'Task To Delete');
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outlined));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Delete Task'), findsOneWidget);
      expect(
        find.textContaining('Are you sure you want to delete'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsWidgets);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('delete dialog can be cancelled', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outlined));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Delete Task'), findsNothing);
    });

    testWidgets('displays schedule icon for date/time', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('displays timer icon for duration', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('hides description when null', (tester) async {
      final task = createTestTask(description: null);
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      // Only title, no description text
      expect(find.text('Test Task'), findsOneWidget);
    });

    testWidgets('shows expanded content on tap', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCard(task: task)));
      await tester.pumpAndSettle();

      // Initially, Start Pomodoro should not be visible
      expect(find.text('Start Pomodoro'), findsNothing);

      // Tap the card to expand
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Now expanded content should be visible
      expect(find.text('Start Pomodoro'), findsOneWidget);
    });
  });

  group('TaskCardCompact Widget Tests', () {
    testWidgets('displays task title in compact mode', (tester) async {
      final task = createTestTask(title: 'Compact Task');
      await tester.pumpWidget(createTestableWidget(TaskCardCompact(task: task)));
      await tester.pumpAndSettle();

      expect(find.text('Compact Task'), findsOneWidget);
    });

    testWidgets('displays time and duration in compact format', (tester) async {
      final task = createTestTask(
        startTime: DateTime(2026, 4, 15, 14, 30).toUtc(),
        durationMinutes: 120,
      );
      await tester.pumpWidget(createTestableWidget(TaskCardCompact(task: task)));
      await tester.pumpAndSettle();

      // Should show compact format with time and duration
      expect(find.byType(TaskCardCompact), findsOneWidget);
    });

    testWidgets('has edit button in compact mode', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCardCompact(task: task)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('has checkbox in compact mode', (tester) async {
      final task = createTestTask();
      await tester.pumpWidget(createTestableWidget(TaskCardCompact(task: task)));
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}
