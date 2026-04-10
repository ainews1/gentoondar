import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_calendar_app/presentation/screens/task_list_screen.dart';

void main() {
  group('TaskListScreen Widget Tests', () {
    testWidgets('renders with app bar and FAB', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      // Verify scaffold structure
      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows search button in app bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows add button in app bar', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.add), findsWidgets); // FAB + app bar button
    });

    testWidgets('shows date navigation arrows', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows Today label for current date', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      // Default selected date is today
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('shows calendar icon in app bar title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    });
  });

  group('CompactTaskListScreen Widget Tests', () {
    testWidgets('renders compact version', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CompactTaskListScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Tasks'), findsOneWidget);
    });
  });
}
