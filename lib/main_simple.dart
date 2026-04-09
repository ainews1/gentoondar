import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'presentation/widgets/common/larry_logo.dart';

void main() {
  runApp(const TaskCalendarApp());
}

class TaskCalendarApp extends StatelessWidget {
  const TaskCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gentoondar',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF54487A), // Gentoo purple
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Task> _tasks = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    _tasks = [
      Task(
        id: '1',
        title: 'Larry Team Meeting',
        description: 'Weekly Gentoo development standup with Larry',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 10, 0),
      ),
      Task(
        id: '2',
        title: 'Emerge @Larry-world',
        description: 'Update Larry\'s Gentoo system components',
        startTime: DateTime(now.year, now.month, now.day, 14, 0),
        endTime: DateTime(now.year, now.month, now.day, 15, 0),
      ),
      Task(
        id: '3',
        title: 'Complete Larry Calendar',
        description: 'Finish the Larry-themed Gentoo productivity app',
        startTime: DateTime(now.year, now.month, now.day + 1, 10, 0),
        isCompleted: false,
      ),
      Task(
        id: '4',
        title: 'Study Larry\'s Legacy',
        description: 'Read about Larry the Gentoo mascot history',
        startTime: DateTime(now.year, now.month, now.day + 2, 16, 0),
        isCompleted: true,
      ),
    ];
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasks.where((task) {
      return isSameDay(task.startTime, day);
    }).toList();
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8E4F3), // Very light lavender
              Color(0xFFD4CEEB), // Light purple-grey
              Color(0xFFB8A9DB), // Medium light purple
            ],
          ),
        ),
        child: Stack(
          children: [
            // Gentoo cow background
            Positioned(
              bottom: 20,
              right: 20,
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF54487A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: LarryLogo(size: 120),
                  ),
                ),
              ),
            ),
            // Main content
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildCalendarView(),
                _buildTaskListView(),
                _buildAnalyticsView(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: const Color(0xFF54487A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarView() {
    return Column(
      children: [
        AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              LarryLogo.icon(color: Colors.white),
              SizedBox(width: 8),
              Text('Gentoondar • Larry Edition'),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF54487A),
          foregroundColor: Colors.white,
        ),
        TableCalendar<Task>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: _getTasksForDay,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            markersMaxCount: 3,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const Divider(),
        Expanded(
          child: _buildTaskListForSelectedDay(),
        ),
      ],
    );
  }

  Widget _buildTaskListForSelectedDay() {
    final tasks = _getTasksForDay(_selectedDay);
    
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No tasks for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskListView() {
    return Column(
      children: [
        AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              LarryLogo.icon(color: Colors.white),
              SizedBox(width: 8),
              Text('Larry\'s Tasks'),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF54487A),
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return _buildTaskCard(task);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsView() {
    final completedTasks = _tasks.where((task) => task.isCompleted).length;
    final totalTasks = _tasks.length;
    final completionRate = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Column(
      children: [
        AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              LarryLogo.icon(color: Colors.white),
              SizedBox(width: 8),
              Text('Larry\'s Productivity'),
            ],
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF54487A),
          foregroundColor: Colors.white,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const LarryLogo.icon(),
                            const SizedBox(width: 8),
                            Text(
                              'Larry\'s Task Overview',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$totalTasks',
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const Text('Total Tasks'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$completedTasks',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('Completed'),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${(completionRate * 100).toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text('Complete Rate'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚀 Recent Larry Activity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '📅 ${_tasks.length} tasks created',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '✅ $completedTasks tasks completed',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '⏰ ${_tasks.where((t) => !t.isCompleted).length} tasks pending',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) => _toggleTaskCompletion(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.startTime.hour.toString().padLeft(2, '0')}:${task.startTime.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (task.endTime != null) ...[
                  const Text(' - '),
                  Text(
                    '${task.endTime!.hour.toString().padLeft(2, '0')}:${task.endTime!.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDateTime = _selectedDay.copyWith(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            LarryLogo.icon(),
            SizedBox(width: 8),
            Text('Add New Task for Larry'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(
                'Start Time: ${selectedDateTime.day}/${selectedDateTime.month}/${selectedDateTime.year} ${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                  );
                  if (time != null) {
                    selectedDateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final task = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  startTime: selectedDateTime,
                );
                _addTask(task);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}