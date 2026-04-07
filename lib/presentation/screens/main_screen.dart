import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_providers.dart';
import '../widgets/navigation/bottom_navigation.dart';
import '../widgets/calendar/month_calendar.dart';
import '../widgets/calendar/date_task_list.dart';
import '../widgets/calendar/week_calendar.dart';
import '../widgets/common/responsive_layout.dart';
import 'task_list_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({Key? key}) : super(key: key);

@override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return ResponsiveLayout(
      child: _buildMobileLayout(context, ref, currentTab),
      mediumChild: _buildTabletLayout(context, ref, currentTab),
      largeChild: _buildDesktopLayout(context, ref, currentTab),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref, AppTab currentTab) {
    return Scaffold(
      body: IndexedStack(
        index: currentTab.index,
        children: [
          _buildCalendarView(context),
          _buildTasksView(context),
          _buildWeekView(context),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref, AppTab currentTab) {
    return Scaffold(
      body: IndexedStack(
        index: currentTab.index,
        children: [
          _buildCalendarView(context),
          _buildTasksView(context),
          _buildWeekView(context),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref, AppTab currentTab) {
    // For desktop, show a side-by-side layout
    return Scaffold(
      body: Row(
        children: [
          // Navigation rail instead of bottom nav
          NavigationRail(
            selectedIndex: currentTab.index,
            onDestinationSelected: (index) {
              final tab = AppTab.values[index];
              ref.read(currentTabProvider.notifier).state = tab;
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calendar_month),
                label: Text('Calendar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.checklist),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_view_week),
                label: Text('Week'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main content
          Expanded(
            child: IndexedStack(
              index: currentTab.index,
              children: [
                _buildCalendarView(context, showAppBar: false),
                _buildTasksView(context, showAppBar: false),
                _buildWeekView(context, showAppBar: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Update these methods to accept showAppBar parameter:
  Widget _buildCalendarView(BuildContext context, {bool showAppBar = true}) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ) : null,
      body: Column(
        children: [
          if (!showAppBar)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Calendar',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          const MonthCalendarWidget(),
          const Divider(),
          Expanded(
            child: DateTaskListWidget(
              showHeader: true,
              onCreateTask: () {
                // TODO: Navigate to create task screen
              },
              onTaskTap: () {
                // TODO: Navigate to edit task screen
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksView(BuildContext context, {bool showAppBar = true}) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Tasks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create task screen
            },
            tooltip: 'Add new task',
          ),
        ],
      ) : null,
      body: Column(
        children: [
          if (!showAppBar)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tasks',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // TODO: Navigate to create task screen
                    },
                    tooltip: 'Add new task',
                  ),
                ],
              ),
            ),
          const Expanded(child: TaskListScreen()),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, {bool showAppBar = true}) {
    return Scaffold(
      appBar: showAppBar ? AppBar(
        title: const Text('Week View'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ) : null,
      body: Column(
        children: [
          if (!showAppBar)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Week View',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          const Expanded(child: WeekCalendarWidget()),
        ],
      ),
    );
  }
}