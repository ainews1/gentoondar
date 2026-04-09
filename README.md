# Gentoondar — Task Calendar App 🐄📅

A cross-platform task management app with integrated calendar functionality, built with Flutter and themed after Gentoo Linux.

## Features

- **📅 Calendar Views** — Month, week, and day views with task indicators
- **✅ Task Management** — Full CRUD: create, edit, delete, and complete tasks
- **📊 Productivity Analytics** — Charts showing task counts and busy minutes per day
- **🔍 Search & Filter** — Real-time text search, date range filtering, completion status filters
- **♿ Accessibility** — WCAG 2.1 AA compliant with screen reader support
- **💾 Local Persistence** — SQLite database, works offline, data survives restarts

## Architecture

**Clean Architecture + MVVM** with clear layer separation:

```
lib/
├── core/           # Error handling, base use case
├── data/           # SQLite database, models, repository implementation
├── domain/         # Entities, repository interfaces, use cases
└── presentation/   # Widgets, screens, providers (Riverpod), theme, navigation
```

## Tech Stack

| Component | Library |
|-----------|---------|
| Framework | Flutter 3.19+ / Dart 3.3+ |
| State Management | Riverpod 2.4+ |
| Local Storage | sqflite 2.3+ (SQLite) |
| Calendar | table_calendar 3.0+ |
| Charts | fl_chart 0.66+ |
| Navigation | go_router 13.0+ |

## Quick Start

### Browser Demo

A standalone HTML demo is available:

```bash
python3 -m http.server 8080 --bind 0.0.0.0
# Open: http://localhost:8080/flutter_task_calendar_demo.html
```

### Flutter Development

```bash
flutter pub get
flutter run -d linux    # Desktop
flutter run -d chrome   # Web
flutter run              # Connected device
```

## Project Status: v1.0 Complete ✅

All 25 v1 requirements fulfilled across 4 phases:

| Phase | Description | Status |
|-------|-------------|--------|
| 1. Foundation | SQLite, clean architecture, Riverpod | ✅ Complete |
| 2. Calendar Integration | Month view, task indicators, Material 3 | ✅ Complete |
| 3. Advanced Views | Week/day calendars, analytics charts | ✅ Complete |
| 4. Search & Polish | Text search, filtering, accessibility | ✅ Complete |

## License

MIT
