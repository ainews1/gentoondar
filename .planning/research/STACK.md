# Stack Research: Flutter Task Management App

*Research Domain: Cross-platform mobile task management with calendar integration*
*Date: 2026-04-07*

## Recommended 2025 Stack

### Core Framework
- **Flutter 3.19+** — Latest stable with Material 3 support and performance improvements
- **Dart 3.3+** — Sound null safety, records, patterns, enhanced async/await
- **Confidence: High** — Flutter is mature for mobile apps, excellent calendar widget ecosystem

### State Management
- **Riverpod 2.4+** — Modern reactive state management with compile-time safety
- **Alternative: Provider 6.1+** — Simpler option if team prefers traditional approach
- **Confidence: High** — Riverpod handles complex app state well, great for calendar/task coordination

### Local Storage
- **SQLite via `sqflite 2.3+`** — Structured data with relationships, ACID transactions
- **Alternative: Hive 4.0+** — NoSQL key-value store, faster for simple models
- **Recommendation: sqflite** — Better for relational task/calendar data
- **Confidence: High** — Battle-tested, excellent performance for local data

### Calendar/Time Widgets
- **`table_calendar 3.0+`** — Most popular Flutter calendar widget
- **`syncfusion_flutter_calendar 24.2+`** — Enterprise-grade calendar with advanced views
- **`flutter_week_view 1.3+`** — Specialized week/day view components
- **Recommendation: table_calendar + custom day view** — Good balance of features and customization
- **Confidence: Medium** — May need custom components for time-block visualization

### Charts/Analytics
- **`fl_chart 0.66+`** — Pure Flutter charts, highly customizable
- **`syncfusion_flutter_charts 24.2+`** — Professional charts with animations
- **Recommendation: fl_chart** — Better for simple bar charts, lighter dependency
- **Confidence: High** — Proven for productivity analytics visualizations

### Development Tools
- **`flutter_lints 3.0+`** — Official lint rules for code quality
- **`very_good_analysis 5.1+`** — Stricter linting from Very Good Ventures
- **`build_runner 2.4+`** — Code generation for data classes and JSON serialization
- **Confidence: High** — Standard development toolchain

### Testing
- **`flutter_test`** — Built-in unit and widget testing
- **`integration_test`** — Official integration testing
- **`mockito 5.4+`** — Mocking for unit tests
- **Confidence: High** — Mature testing ecosystem

### Platform-Specific
- **Android**: Target API 34 (Android 14), Gradle 8.4, Kotlin 1.9
- **iOS**: Target iOS 12+ for wider device support, Xcode 15+
- **Confidence: High** — Standard platform requirements

## Package Architecture

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.10
  
  # Local Storage
  sqflite: ^2.3.2
  path: ^1.8.3
  
  # Calendar & Time
  table_calendar: ^3.0.9
  intl: ^0.19.0
  
  # Charts
  fl_chart: ^0.66.2
  
  # UI Components
  material_color_utilities: ^0.8.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  mockito: ^5.4.4
```

## Architecture Decisions

### Data Layer
- **Repository Pattern** — Abstract data access, easier testing
- **SQL Schema** — Tasks table with indexed date/time columns
- **Data Classes** — Immutable models with copyWith methods

### Presentation Layer
- **MVVM Pattern** — ViewModels manage screen state, Views are purely reactive
- **Screen-per-file** — Clear navigation structure
- **Shared Components** — Reusable task cards, calendar cells

### Navigation
- **go_router 13.2+** — Declarative routing with type safety
- **Confidence: Medium** — Newer than Navigator 1.0 but more maintainable

## What NOT to Use

### Avoid These Packages
- **`calendar_timeline`** — Abandoned, poor performance
- **`charts_flutter`** — Google's deprecated chart package
- **`shared_preferences` for complex data** — Use sqflite for relational data
- **`get`** — GetX introduces too much magic, prefer explicit state management

### Anti-Patterns
- **Global state singletons** — Makes testing difficult
- **DateTime without timezone handling** — Use local time consistently
- **Blocking UI operations** — Always use async for database operations
- **Mixed navigation patterns** — Stick to one routing approach

## Performance Considerations

### Critical for Calendar Apps
- **ListView.builder for large date ranges** — Lazy loading prevents memory issues
- **Database indexing on date columns** — Fast task lookups by date
- **Image caching disabled** — No images in this app to avoid memory bloat
- **60fps animations** — Smooth calendar scrolling and task transitions

### Memory Management
- **Dispose controllers properly** — Prevent memory leaks in calendar views
- **Limit concurrent database connections** — Use connection pooling
- **Cache computed layouts** — Don't recalculate calendar layouts on every frame

## Rationale Summary

**Why Flutter**: Single codebase for iOS/Android, mature calendar widget ecosystem, excellent performance for scrolling interfaces.

**Why Riverpod**: Better developer experience than Provider, compile-time safety, scales well as app complexity grows.

**Why SQLite**: Task/calendar apps need relational queries (tasks by date range), ACID transactions for data integrity.

**Why table_calendar**: Most mature calendar widget, active maintenance, good customization options for month view.

**Why fl_chart**: Lightweight, pure Flutter implementation, perfect for simple productivity charts.

---
*Confidence levels: High (proven in production), Medium (good community adoption), Low (emerging/experimental)*