import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/calendar/month_calendar.dart';
import '../providers/calendar_providers.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDateTasksAsync = ref.watch(selectedDateTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          const MonthCalendarWidget(),
          const Divider(),
          Expanded(
            child: selectedDateTasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error loading tasks: $error'),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks for selected date'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: task.description != null
                            ? Text(task.description!)
                            : null,
                        trailing: Text('${task.durationMinutes}min'),
                        leading: Icon(
                          task.isCompleted
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: task.isCompleted
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}