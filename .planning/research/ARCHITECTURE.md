# Architecture Research: Flutter Task Management Apps

*Research Domain: Flutter app architecture for task/calendar management*
*Date: 2026-04-07*

## Recommended Architecture Patterns

### High-Level Architecture: Clean Architecture + MVVM

```
┌─────────────────┐
│   Presentation  │ ← UI (Widgets), ViewModels (Riverpod Providers)
├─────────────────┤
│     Domain      │ ← Business Logic, Entities, Use Cases
├─────────────────┤
│      Data       │ ← Repositories, Data Sources, Models
└─────────────────┘
```

**Rationale**: Clean separation allows testing business logic independently from UI. MVVM pattern fits Flutter's reactive nature.

### Component Structure

#### 1. Data Layer (Bottom)
**Responsibilities**: Data persistence, external data sources, caching

```
lib/data/
├── models/              # Data transfer objects
│   ├── task_model.dart
│   └── task_model.g.dart  # Generated JSON serialization
├── repositories/        # Repository implementations
│   └── task_repository_impl.dart
├── datasources/         # Concrete data access
│   ├── local/
│   │   ├── database_helper.dart
│   │   └── task_local_datasource.dart
│   └── remote/          # Future cloud sync
│       └── task_remote_datasource.dart
└── mappers/             # Convert between models and entities
    └── task_mapper.dart
```

**Key Patterns**:
- **Repository Pattern**: Abstract data access behind interfaces
- **Data Source Pattern**: Separate local and remote data handling
- **Mapper Pattern**: Convert between data models and domain entities

#### 2. Domain Layer (Middle)
**Responsibilities**: Business rules, entities, use cases (pure Dart, no Flutter dependencies)

```
lib/domain/
├── entities/            # Business objects
│   ├── task.dart
│   └── calendar_day.dart
├── repositories/        # Repository interfaces
│   └── task_repository.dart
├── usecases/           # Business logic operations
│   ├── create_task.dart
│   ├── get_tasks_by_date.dart
│   ├── update_task.dart
│   ├── delete_task.dart
│   └── get_productivity_stats.dart
└── failures/           # Error handling
    └── task_failures.dart
```

**Key Patterns**:
- **Entity Pattern**: Core business objects without framework dependencies
- **Use Case Pattern**: Single-responsibility business operations
- **Interface Segregation**: Repository abstractions for testability

#### 3. Presentation Layer (Top)
**Responsibilities**: UI widgets, state management, user interaction

```
lib/presentation/
├── providers/          # Riverpod providers (ViewModels)
│   ├── task_list_provider.dart
│   ├── calendar_provider.dart
│   └── chart_provider.dart
├── screens/            # Full-screen widgets
│   ├── calendar_screen.dart
│   ├── task_detail_screen.dart
│   └── analytics_screen.dart
├── widgets/            # Reusable UI components
│   ├── calendar/
│   │   ├── month_view.dart
│   │   ├── week_view.dart
│   │   └── day_view.dart
│   ├── tasks/
│   │   ├── task_card.dart
│   │   ├── task_form.dart
│   │   └── task_list.dart
│   └── charts/
│       ├── productivity_chart.dart
│       └── busy_day_chart.dart
├── navigation/         # Routing and navigation
│   └── app_router.dart
└── theme/             # Styling and theming
    └── app_theme.dart
```

**Key Patterns**:
- **Provider Pattern** (Riverpod): Reactive state management
- **Component Pattern**: Reusable widgets with single responsibility
- **Screen Pattern**: Top-level route widgets that compose smaller widgets

## Data Flow Architecture

### Task Management Flow
```
User Interaction → Provider → Use Case → Repository → Data Source → SQLite
                    ↓
UI Widget ← State Update ← Provider ← Use Case Response ← Repository ← Data Source
```

### Calendar View Flow
```
Date Selection → Calendar Provider → Get Tasks Use Case → Repository → Local DB
                      ↓
Calendar Widget ← Task List State ← Provider ← Task Entities ← Repository ← DB Results
```

### Chart Generation Flow
```
Analytics Request → Chart Provider → Analytics Use Case → Repository → Aggregated Queries
                        ↓
Chart Widget ← Chart Data State ← Provider ← Statistics Entity ← Repository ← Query Results
```

## State Management Strategy

### Riverpod Provider Architecture

#### 1. Data Providers (Repository Layer)
```dart
@Riverpod
TaskRepository taskRepository(TaskRepositoryRef ref) {
  return TaskRepositoryImpl(
    localDataSource: ref.read(taskLocalDataSourceProvider),
  );
}
```

#### 2. Use Case Providers (Business Logic)
```dart
@Riverpod
class CreateTask extends _$CreateTask {
  Future<Either<Failure, Task>> call(TaskCreationParams params) {
    return ref.read(taskRepositoryProvider).createTask(params);
  }
}
```

#### 3. UI State Providers (Presentation Logic)
```dart
@Riverpod
class TaskList extends _$TaskList {
  @override
  Future<List<Task>> build(DateTime date) {
    return ref.read(getTasksByDateProvider(date).future);
  }
  
  void addTask(Task task) {
    // Update state and trigger UI rebuild
    state = AsyncValue.data([...state.value!, task]);
  }
}
```

### Benefits of This Structure
- **Separation of Concerns**: Each layer has clear responsibilities
- **Testability**: Business logic isolated from UI framework
- **Maintainability**: Changes isolated to specific layers
- **Scalability**: Easy to add new features without breaking existing code

## Database Schema Design

### Core Tables

#### Tasks Table
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  start_time INTEGER NOT NULL,  -- Unix timestamp
  duration_minutes INTEGER NOT NULL,
  is_completed INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Indexes for performance
CREATE INDEX idx_tasks_date ON tasks(date(start_time, 'unixepoch', 'localtime'));
CREATE INDEX idx_tasks_start_time ON tasks(start_time);
CREATE INDEX idx_tasks_completed ON tasks(is_completed);
```

#### Calendar Cache Table (Optional Optimization)
```sql
CREATE TABLE calendar_cache (
  date TEXT PRIMARY KEY,  -- YYYY-MM-DD format
  task_count INTEGER DEFAULT 0,
  total_minutes INTEGER DEFAULT 0,
  last_updated INTEGER NOT NULL
);
```

### Query Patterns
- **Tasks by Date**: `SELECT * FROM tasks WHERE date(start_time, 'unixepoch', 'localtime') = ?`
- **Tasks by Date Range**: `SELECT * FROM tasks WHERE start_time BETWEEN ? AND ?`
- **Busy Day Analysis**: `SELECT date(...) as day, COUNT(*), SUM(duration_minutes) FROM tasks GROUP BY day`
- **Search Tasks**: `SELECT * FROM tasks WHERE title LIKE ? OR description LIKE ?`

## Navigation Architecture

### Go Router Setup
```dart
final appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/calendar',
          builder: (context, state) => CalendarScreen(),
          routes: [
            GoRoute(
              path: '/task/:id',
              builder: (context, state) => TaskDetailScreen(
                taskId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => AnalyticsScreen(),
        ),
      ],
    ),
  ],
);
```

**Navigation Patterns**:
- **Tab-based Main Navigation**: Calendar, Analytics, Settings
- **Stack-based Detail Navigation**: Calendar → Task Detail → Edit Task
- **Modal Navigation**: Add Task, Date Picker dialogs

## Build Order Recommendations

### Phase 1: Foundation (Data → Domain → Basic UI)
1. **Database Setup** — SQLite schema, helper classes
2. **Entity Models** — Task domain objects
3. **Repository Layer** — Data access abstraction
4. **Basic Providers** — Task CRUD operations
5. **Simple Task List** — Minimal UI to test data flow

### Phase 2: Calendar Integration (Calendar Views + Task Integration)
1. **Calendar Widgets** — Month view with table_calendar
2. **Calendar Provider** — Date selection and task loading
3. **Task Integration** — Show tasks on calendar dates
4. **Navigation** — Date selection → task list flow

### Phase 3: Advanced Views (Week/Day Views + Charts)
1. **Week View Widget** — Custom time-block calendar
2. **Day View Widget** — Hourly timeline with tasks
3. **Chart Widgets** — Productivity analytics
4. **Search/Filter** — Text search and date filtering

### Suggested Dependencies by Phase
**Phase 1**: sqflite, riverpod, json_annotation
**Phase 2**: table_calendar, intl, go_router
**Phase 3**: fl_chart, custom_scrollview optimization

## Testing Strategy

### Test Structure
```
test/
├── unit/
│   ├── domain/usecases/
│   ├── data/repositories/
│   └── data/datasources/
├── widget/
│   ├── calendar_widget_test.dart
│   └── task_form_test.dart
└── integration/
    └── app_test.dart
```

### Key Test Scenarios
- **Use Case Tests**: Business logic without UI dependencies
- **Repository Tests**: Data access with mocked data sources
- **Widget Tests**: UI components with mocked providers
- **Integration Tests**: Complete user journeys (create task → view on calendar)

## Performance Considerations

### Database Optimization
- **Index Strategy**: Date-based queries are most common
- **Connection Pooling**: Reuse database connections
- **Lazy Loading**: Only fetch tasks for visible date ranges
- **Background Queries**: Use isolates for heavy analytics queries

### UI Performance
- **ListView.builder**: For large task lists and calendar grids
- **Cached Widgets**: Reuse expensive calendar layouts
- **Debounced Search**: Limit search query frequency
- **Image-Free Design**: Avoid image loading delays

This architecture scales from simple MVP to complex productivity app while maintaining clean separation of concerns.

---
*Architecture patterns from successful Flutter apps with complex state management*