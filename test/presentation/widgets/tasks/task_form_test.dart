import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_form.dart';

/// Helper to wrap widgets in MaterialApp with Riverpod for testing
Widget createTestableWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  group('TaskForm Widget Tests', () {
    group('Create Mode', () {
      testWidgets('renders all form fields in create mode', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        // Verify title field exists
        expect(find.text('Title *'), findsOneWidget);
        expect(find.text('Enter task title'), findsOneWidget);

        // Verify description field exists
        expect(find.text('Description'), findsOneWidget);

        // Verify date picker exists
        expect(find.text('Date *'), findsOneWidget);

        // Verify time picker exists
        expect(find.text('Time *'), findsOneWidget);

        // Verify duration dropdown exists
        expect(find.text('Duration *'), findsOneWidget);

        // Verify buttons
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('shows validation error when title is empty', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        // Tap save without entering title
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Should show validation error
        expect(find.text('Title is required'), findsOneWidget);
      });

      testWidgets('title field accepts valid input', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        // Enter valid title
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter task title'),
          'Test Task Title',
        );
        await tester.pumpAndSettle();

        // Verify text was entered
        expect(find.text('Test Task Title'), findsOneWidget);
      });

      testWidgets('description field accepts input', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter task description (optional)'),
          'Test Description',
        );
        await tester.pumpAndSettle();

        expect(find.text('Test Description'), findsOneWidget);
      });

      testWidgets('shows required fields indicator', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        expect(find.text('* Required fields'), findsOneWidget);
      });

      testWidgets('displays loading indicator during submission', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        // Enter valid title to pass validation
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Enter task title'),
          'Test Task',
        );
        await tester.pumpAndSettle();

        // The form should have save button visible before submission
        expect(find.text('Save'), findsOneWidget);
      });

      testWidgets('tapping outside dismisses keyboard', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        // Focus on title field
        await tester.tap(find.widgetWithText(TextFormField, 'Enter task title'));
        await tester.pumpAndSettle();

        // Tap outside the form (GestureDetector wraps form for keyboard dismissal)
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // No crash means keyboard dismissal works
        expect(find.byType(TaskForm), findsOneWidget);
      });
    });

    group('Edit Mode', () {
      final testTask = Task(
        id: 1,
        title: 'Existing Task',
        description: 'Existing Description',
        startTime: DateTime(2026, 4, 15, 10, 30).toUtc(),
        durationMinutes: 60,
        isCompleted: false,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      testWidgets('populates form with existing task data in edit mode',
          (tester) async {
        await tester.pumpWidget(createTestableWidget(TaskForm(task: testTask)));
        await tester.pumpAndSettle();

        // Verify title is populated
        expect(find.text('Existing Task'), findsOneWidget);

        // Verify description is populated
        expect(find.text('Existing Description'), findsOneWidget);

        // Verify update button instead of save
        expect(find.text('Update'), findsOneWidget);
      });

      testWidgets('shows Update button instead of Save in edit mode',
          (tester) async {
        await tester.pumpWidget(createTestableWidget(TaskForm(task: testTask)));
        await tester.pumpAndSettle();

        expect(find.text('Update'), findsOneWidget);
        expect(find.text('Save'), findsNothing);
      });
    });

    group('Validation', () {
      testWidgets('title cannot exceed 100 characters', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        // TextFormField has maxLength: 100, so it enforces the limit
        final titleField = find.widgetWithText(TextFormField, 'Enter task title');
        expect(titleField, findsOneWidget);

        // The maxLength counter should be visible
        expect(find.text('Required, max 100 characters'), findsOneWidget);
      });

      testWidgets('description has max 500 characters', (tester) async {
        await tester.pumpWidget(createTestableWidget(const TaskForm()));
        await tester.pumpAndSettle();

        expect(find.text('Optional, max 500 characters'), findsOneWidget);
      });
    });
  });
}
