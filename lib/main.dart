import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/navigation/app_router.dart';
import 'data/datasources/local/database_helper.dart';

void main() async {
  // Ensure Flutter binding is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize database on app startup
    final dbHelper = DatabaseHelper();
    final database = await dbHelper.database;
    
    print('✓ Database initialized successfully');
    print('Database path: ${database.path}');
    
    // Get and display database info
    final dbInfo = await dbHelper.getDatabaseInfo();
    print('Database info: $dbInfo');
    
  } catch (e) {
    print('✗ Failed to initialize database: $e');
    // Continue with app startup even if database fails
    // In production, you might want to show an error screen
  }
  
  runApp(const ProviderScope(child: TaskCalendarApp()));
}

class TaskCalendarApp extends StatelessWidget {
  const TaskCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Task Calendar App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}