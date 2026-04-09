import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/entities/task.dart';
import '../../providers/calendar_providers.dart';
import '../../theme/app_theme.dart';
import '../common/responsive_layout.dart';
import 'calendar_indicators.dart';

class MonthCalendarWidget extends ConsumerWidget {
  const MonthCalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);
    final monthTasksAsync = ref.watch(monthTasksProvider);

    return monthTasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading tasks: $error'),
      ),
      data: (tasks) {
        // Group tasks by date for quick lookup
        final tasksByDate = <DateTime, List<Task>>{};
        for (final task in tasks) {
          // Extract date from startTime
          final dateKey = DateTime(task.startTime.year, task.startTime.month, task.startTime.day);
          tasksByDate[dateKey] = (tasksByDate[dateKey] ?? [])..add(task);
        }

        return ResponsiveLayout(
          child: _buildMobileCalendar(
            context,
            ref,
            selectedDate,
            currentMonth,
            calendarFormat,
            tasksByDate,
          ),
          mediumChild: _buildTabletCalendar(
            context,
            ref,
            selectedDate,
            currentMonth,
            calendarFormat,
            tasksByDate,
          ),
          largeChild: _buildDesktopCalendar(
            context,
            ref,
            selectedDate,
            currentMonth,
            calendarFormat,
            tasksByDate,
          ),
        );
      },
    );
  }

  Widget _buildMobileCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    DateTime currentMonth,
    CalendarFormat calendarFormat,
    Map<DateTime, List<Task>> tasksByDate,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildTableCalendar(
        context,
        ref,
        selectedDate,
        currentMonth,
        calendarFormat,
        tasksByDate,
      ),
    );
  }

  Widget _buildTabletCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    DateTime currentMonth,
    CalendarFormat calendarFormat,
    Map<DateTime, List<Task>> tasksByDate,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: _buildTableCalendar(
        context,
        ref,
        selectedDate,
        currentMonth,
        calendarFormat,
        tasksByDate,
      ),
    );
  }

  Widget _buildDesktopCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    DateTime currentMonth,
    CalendarFormat calendarFormat,
    Map<DateTime, List<Task>> tasksByDate,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: _buildTableCalendar(
          context,
          ref,
          selectedDate,
          currentMonth,
          calendarFormat,
          tasksByDate,
        ),
      ),
    );
  }

  Widget _buildTableCalendar(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    DateTime currentMonth,
    CalendarFormat calendarFormat,
    Map<DateTime, List<Task>> tasksByDate,
  ) {
    return TableCalendar<Task>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: currentMonth,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      calendarFormat: calendarFormat,
      eventLoader: (day) {
        final dateKey = DateTime(day.year, day.month, day.day);
        return tasksByDate[dateKey] ?? [];
      },
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: const CalendarStyle(),
      headerStyle: const HeaderStyle(formatButtonVisible: false),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final dateKey = DateTime(day.year, day.month, day.day);
          final dayTasks = tasksByDate[dateKey] ?? [];
          return buildCalendarDay(
            context,
            day,
            focusedDay,
            dayTasks,
            false,
            false,
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          final dateKey = DateTime(day.year, day.month, day.day);
          final dayTasks = tasksByDate[dateKey] ?? [];
          return buildCalendarDay(
            context,
            day,
            focusedDay,
            dayTasks,
            true,
            isSameDay(day, DateTime.now()),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          final dateKey = DateTime(day.year, day.month, day.day);
          final dayTasks = tasksByDate[dateKey] ?? [];
          return buildCalendarDay(
            context,
            day,
            focusedDay,
            dayTasks,
            isSameDay(selectedDate, day),
            true,
          );
        },
        markerBuilder: (context, day, events) {
          final tasks = events.cast<Task>();
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buildEventMarkers(context, day, tasks),
          );
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(selectedDateProvider.notifier).state = selectedDay;
      },
      onFormatChanged: (format) {
        ref.read(calendarFormatProvider.notifier).state = format;
      },
      onPageChanged: (focusedDay) {
        ref.read(currentMonthProvider.notifier).state = focusedDay;
      },
      availableGestures: AvailableGestures.all,
    );
  }
}