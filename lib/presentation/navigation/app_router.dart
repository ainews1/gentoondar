import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_calendar_app/domain/entities/task.dart';
import 'package:task_calendar_app/presentation/screens/task_list_screen.dart';
import 'package:task_calendar_app/presentation/screens/search_screen.dart';
import 'package:task_calendar_app/presentation/widgets/tasks/task_form.dart';

/// Application routing configuration using GoRouter.
/// Provides navigation between task list and form screens.
class AppRouter {
  static const String home = '/';
  static const String newTask = '/task/new';
  static const String editTask = '/task/edit';
  static const String search = '/search';

  /// GoRouter configuration with all application routes
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Home route - Task List Screen
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const TaskListScreen(),
      ),

      // Create new task route
      GoRoute(
        path: newTask,
        name: 'new_task',
        pageBuilder: (context, state) {
          return MaterialPage(
            key: state.pageKey,
            child: const Scaffold(
              appBar: TaskFormAppBar(title: 'Add Task'),
              body: TaskForm(),
            ),
          );
        },
      ),

      // Edit existing task route
      GoRoute(
        path: editTask,
        name: 'edit_task',
        pageBuilder: (context, state) {
          final task = state.extra as Task?;
          if (task == null) {
            return MaterialPage(
              key: state.pageKey,
              child: const _ErrorScreen(
                message: 'Task not found',
              ),
            );
          }

          return MaterialPage(
            key: state.pageKey,
            child: Scaffold(
              appBar: const TaskFormAppBar(title: 'Edit Task'),
              body: TaskForm(task: task),
            ),
          );
        },
      ),

      // Search tasks route
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
    ],

    // Error handling for invalid routes
    errorBuilder: (context, state) => _ErrorScreen(
      message: 'Page not found: ${state.location}',
    ),

    // Custom redirect logic (if needed in future)
    redirect: (context, state) {
      // Can add authentication checks here in future
      return null; // No redirect needed
    },
  );
}

/// Custom AppBar for task form screens with consistent styling
class TaskFormAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TaskFormAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Cancel',
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Error screen for navigation failures and invalid routes
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRouter.home),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation helper methods for type-safe routing
class AppNavigation {
  /// Navigate to home screen (task list)
  static void goHome(BuildContext context) {
    context.go(AppRouter.home);
  }

  /// Navigate to new task form
  static void goToNewTask(BuildContext context) {
    context.push(AppRouter.newTask);
  }

  /// Navigate to edit task form with existing task data
  static void goToEditTask(BuildContext context, Task task) {
    context.push(AppRouter.editTask, extra: task);
  }

  /// Navigate to search screen
  static void goToSearch(BuildContext context) {
    context.push(AppRouter.search);
  }

  /// Go back to previous screen
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goHome(context);
    }
  }

  /// Replace current route with home (useful after form submission)
  static void replaceWithHome(BuildContext context) {
    context.go(AppRouter.home);
  }
}

/// Route information for analytics and debugging
class RouteInfo {
  static String getCurrentRoute(BuildContext context) {
    final router = GoRouter.of(context);
    return router.routerDelegate.currentConfiguration.location;
  }

  static bool isCurrentRoute(BuildContext context, String route) {
    return getCurrentRoute(context) == route;
  }
}