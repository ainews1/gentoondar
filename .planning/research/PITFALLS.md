# Pitfalls Research: Flutter Task Management Apps

*Research Domain: Common mistakes in Flutter task/calendar app development*
*Date: 2026-04-07*

## Critical Development Pitfalls

### 1. DateTime Handling Nightmares

**Problem**: Inconsistent timezone handling leads to tasks appearing on wrong dates, especially across daylight saving time transitions.

**Warning Signs**:
- Tasks created at 11 PM appear on next day
- Calendar views show different dates than task list
- User reports "tasks disappearing" seasonally

**Prevention Strategy**:
- **Use Local Time Consistently**: Store UTC timestamps but always display/edit in local time
- **Single Source of Truth**: One timezone conversion function used everywhere
- **Test DST Transitions**: Automated tests covering spring forward/fall back
- **Flutter Pattern**:
```dart
// GOOD: Consistent local time handling
DateTime localNow = DateTime.now();
DateTime utcStored = localNow.toUtc();
DateTime displayTime = utcStored.toLocal();

// BAD: Mixing timezone contexts
DateTime badTime = DateTime.parse("2024-03-10T14:30:00Z"); // UTC string
DateTime worseTime = DateTime(2024, 3, 10, 14, 30); // Local constructor
```

**Phase to Address**: Phase 1 (Foundation) — Build timezone handling correctly from start

### 2. Calendar Performance Collapse

**Problem**: Calendar views become sluggish with >100 tasks due to inefficient rendering and data loading.

**Warning Signs**:
- Calendar scrolling stutters or drops frames
- Month view takes >500ms to switch months
- App memory usage grows continuously during calendar navigation

**Prevention Strategy**:
- **Lazy Loading**: Only load tasks for visible date range
- **Efficient Widgets**: Use ListView.builder for calendar grids
- **Database Indexing**: Index queries by date/time columns
- **Caching Strategy**: Cache month data, invalidate intelligently
- **Flutter Pattern**:
```dart
// GOOD: Lazy loading with date range
Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) {
  return db.query(
    'tasks',
    where: 'start_time BETWEEN ? AND ?',
    whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
  );
}

// BAD: Loading all tasks always
Future<List<Task>> getAllTasks() {
  return db.query('tasks'); // Loads everything
}
```

**Phase to Address**: Phase 2 (Calendar Integration) — Implement efficient data loading patterns

### 3. State Management Chaos

**Problem**: Complex interactions between calendar dates, task lists, and forms lead to inconsistent UI state and data races.

**Warning Signs**:
- UI shows stale data after task creation/editing
- Calendar and task list show different information
- "Flashing" UI as multiple providers update sequentially
- Race conditions when rapidly switching dates

**Prevention Strategy**:
- **Single State Source**: One provider per data domain (tasks, calendar selection)
- **Proper Dependencies**: Clear provider dependency chain
- **Optimistic Updates**: Update UI immediately, rollback on failure
- **State Validation**: Assertions to catch inconsistent state early
- **Riverpod Pattern**:
```dart
// GOOD: Clear dependency chain
@riverpod
Future<List<Task>> tasksForDate(TasksForDateRef ref, DateTime date) async {
  final repository = ref.read(taskRepositoryProvider);
  return repository.getTasksForDate(date);
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();
  
  void selectDate(DateTime date) {
    state = date;
    // Automatically invalidates dependent providers
    ref.invalidate(tasksForDateProvider);
  }
}
```

**Phase to Address**: Phase 1 (Foundation) — Design state architecture correctly from start

### 4. Database Migration Hell

**Problem**: Schema changes break existing user data, causing crashes or data loss in production.

**Warning Signs**:
- App crashes on startup after updates
- User reports lost tasks after app updates
- Different app versions have incompatible data

**Prevention Strategy**:
- **Version-Based Migrations**: Incremental schema changes with version tracking
- **Backup Before Migration**: Always backup before schema changes
- **Rollback Strategy**: Ability to revert failed migrations
- **Testing**: Test migrations with real user data patterns
- **SQLite Pattern**:
```dart
// GOOD: Versioned migrations
Future<void> _createDb(Database db, int version) async {
  await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      -- Add new columns with defaults
      created_at INTEGER DEFAULT 0
    )
  ''');
}

Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE tasks ADD COLUMN duration_minutes INTEGER DEFAULT 0');
  }
  if (oldVersion < 3) {
    await db.execute('CREATE INDEX idx_tasks_date ON tasks(start_time)');
  }
}
```

**Phase to Address**: Phase 1 (Foundation) — Set up proper migration system early

### 5. Custom Calendar Widget Overengineering

**Problem**: Building custom calendar widgets from scratch instead of adapting existing solutions leads to months of complex layout math.

**Warning Signs**:
- Calendar layout calculation bugs (wrong week boundaries, leap years)
- Touch target calculation errors
- Accessibility problems with custom widgets
- Performance issues with custom scroll physics

**Prevention Strategy**:
- **Use Proven Libraries**: Start with table_calendar or similar
- **Customize, Don't Rebuild**: Override styling/behavior vs building from scratch
- **Progressive Enhancement**: Add custom views (week/day) after month view works
- **Test Edge Cases**: Month boundaries, leap years, different locales
- **Flutter Pattern**:
```dart
// GOOD: Customize existing widget
TableCalendar<Task>(
  calendarBuilders: CalendarBuilders(
    // Custom cell builder for task indicators
    defaultBuilder: (context, day, focusedDay) {
      final tasksForDay = ref.watch(tasksForDateProvider(day)).value ?? [];
      return CustomDayCell(day: day, tasks: tasksForDay);
    },
  ),
)

// BAD: Building calendar from scratch
CustomScrollView(
  slivers: [
    // Hundreds of lines of complex layout math
    SliverGrid(...) // Manual grid calculation
  ],
)
```

**Phase to Address**: Phase 2 (Calendar Integration) — Choose adaptation over custom building

### 6. Accessibility Afterthought

**Problem**: Calendar and time-based interfaces become unusable for screen reader users and users with motor impairments.

**Warning Signs**:
- Screen reader announces dates as "button button button"
- No keyboard navigation support
- Touch targets smaller than 44pt
- Color as only way to indicate task status

**Prevention Strategy**:
- **Semantic Labeling**: Proper labels for calendar cells and tasks
- **Keyboard Navigation**: Tab order and focus management
- **Sufficient Contrast**: Text readable in all conditions
- **Alternative Input Methods**: Voice input support for task creation
- **Flutter Pattern**:
```dart
// GOOD: Accessible calendar cell
Semantics(
  label: 'March 15, 2024, 3 tasks scheduled',
  button: true,
  onTap: () => selectDate(date),
  child: Container(
    constraints: BoxConstraints(minWidth: 44, minHeight: 44),
    child: CalendarCell(date: date, tasks: tasks),
  ),
)

// BAD: No accessibility
GestureDetector(
  onTap: () => selectDate(date),
  child: Container(
    width: 30, height: 30, // Too small
    child: Text(date.day.toString()), // No context
  ),
)
```

**Phase to Address**: All phases — Build accessibility in from start, not retrofitted

### 7. Time Zone Edge Case Disasters

**Problem**: Tasks scheduled during daylight saving transitions create impossible or duplicate time slots.

**Warning Signs**:
- Tasks scheduled for 2:30 AM on "spring forward" day (doesn't exist)
- Duplicate tasks appearing on "fall back" day
- Calendar shows 25-hour or 23-hour days incorrectly

**Prevention Strategy**:
- **UTC Storage**: Always store absolute time in UTC
- **Local Display**: Convert to local time only for display
- **DST Validation**: Check if scheduled time actually exists
- **User Education**: Clear messaging about DST transitions
- **Dart Pattern**:
```dart
// GOOD: Safe time scheduling
DateTime scheduleTask(DateTime localTime, int durationMinutes) {
  // Convert to UTC for storage
  final utcTime = localTime.toUtc();
  
  // Validate the local time actually exists
  final backToLocal = utcTime.toLocal();
  if (backToLocal != localTime) {
    // Handle DST transition
    throw InvalidTimeException('Time does not exist due to DST transition');
  }
  
  return utcTime;
}
```

**Phase to Address**: Phase 1 (Foundation) — Build time handling correctly from start

## Testing Anti-Patterns

### 1. No Database Testing

**Problem**: SQLite queries work in simple cases but fail with real data volumes and edge cases.

**Prevention**: 
- Test with realistic data volumes (1000+ tasks)
- Test with edge case dates (leap years, DST transitions)
- Test concurrent database access
- **Phase**: Phase 1 (Foundation)

### 2. Widget Tests Without Data

**Problem**: UI tests pass but app crashes with real user scenarios.

**Prevention**:
- Mock realistic data scenarios in widget tests
- Test error states (network failures, empty data)
- Test accessibility with screen reader simulation
- **Phase**: Phase 2 (Calendar Integration)

### 3. No Performance Testing

**Problem**: App performs well in development but struggles with user data volumes.

**Prevention**:
- Integration tests with large datasets
- Memory usage monitoring during calendar navigation
- Frame rate monitoring during scrolling
- **Phase**: Phase 3 (Advanced Views)

## Common State Bugs

### 1. Calendar Date vs Task Date Mismatch

```dart
// BUG: Different date formats in different parts of app
final calendarDate = DateTime(2024, 3, 15); // Date only
final taskDate = DateTime.now(); // With time component

// FIX: Consistent date normalization
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
```

### 2. Provider Dependency Cycles

```dart
// BUG: Circular dependency between providers
@riverpod
DateTime selectedDate(SelectedDateRef ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.isNotEmpty ? tasks.first.date : DateTime.now();
}

@riverpod
List<Task> taskList(TaskListRef ref) {
  final date = ref.watch(selectedDateProvider);
  return getTasksForDate(date);
}
```

## Memory Leaks

### 1. Calendar Controller Disposal

```dart
// BUG: Not disposing calendar controllers
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarController controller;
  
  @override
  void dispose() {
    controller.dispose(); // CRITICAL: Must dispose
    super.dispose();
  }
}
```

### 2. Stream Subscription Management

```dart
// BUG: Stream subscriptions not cancelled
StreamSubscription? subscription;

void initState() {
  subscription = taskStream.listen((tasks) {
    setState(() => this.tasks = tasks);
  });
}

void dispose() {
  subscription?.cancel(); // CRITICAL: Cancel subscriptions
  super.dispose();
}
```

## Recovery Strategies

Each pitfall should have a recovery plan:

1. **Immediate**: Stop-gap fixes for critical issues
2. **Short-term**: Proper fixes that can be deployed quickly  
3. **Long-term**: Architectural changes to prevent recurrence

**Example Recovery Plan for DateTime Issues**:
- Immediate: Add timezone validation in critical paths
- Short-term: Audit all DateTime usage and standardize
- Long-term: Create DateTime utility class with enforced patterns

---
*Pitfalls identified from Flutter app post-mortems and production incident reports*