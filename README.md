# Expense Tracker

A fast, minimal, offline-first expense tracking app built with Flutter. Log, categorize, search, and visualize your daily spending with beautiful Material 3 charts.

## Features

- **Add / Edit / Delete Expenses** — Quick form with amount, category (7 types), optional note, and date picker
- **Month Navigation** — Browse expenses by month with chevron controls
- **Dashboard** — Monthly summary card with total spent and recent transactions
- **Expense History** — Full searchable, filterable list grouped by date with daily subtotals
- **Category Filter** — Filter expenses by category using chip filters
- **Statistics & Charts** — Interactive pie chart (category breakdown), yearly bar chart with tooltips, and detailed category-wise progress bars
- **Swipe to Delete** — Quick swipe gesture with confirmation dialog
- **Persistent Storage** — All data stored locally via SQLite (no internet required)
- **Material 3 Design** — Modern Material You theming with dynamic colors

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Riverpod** | State management (Notifier + Provider) |
| **sqflite** | Local SQLite database |
| **fl_chart** | Pie charts & bar charts |
| **intl** | Date formatting & currency |
| **path_provider** | Platform-specific directory paths |

## Architecture

Feature-first Clean Architecture with Riverpod state management:

```
lib/
├── core/               # Constants, theme, database service
│   ├── constants/
│   ├── services/
│   └── theme/
├── shared/             # Shared models, repositories, widgets
│   ├── models/
│   ├── repositories/
│   └── widgets/
└── features/           # Feature modules (home, expense_form, expense_history, stats)
    ├── home/
    ├── expense_form/
    ├── expense_history/
    └── stats/
```

Each feature follows a consistent structure:
- **`domain/states/`** — Immutable state classes
- **`domain/notifiers/`** — Riverpod notifiers with business logic
- **`presentation/screens/`** — UI screens
- **`presentation/widgets/`** — Feature-specific widgets

## Getting Started

### Prerequisites

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0

### Installation

```bash
git clone https://github.com/yourusername/expense-tracker.git
cd expense-tracker
flutter pub get
flutter run
```

To build for a specific platform:

```bash
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build windows      # Windows
flutter build linux        # Linux
flutter build macos        # macOS
```

## Dependencies

| Package | Version |
|---------|---------|
| flutter_riverpod | ^2.4.9 |
| sqflite | ^2.3.0 |
| fl_chart | ^0.68.0 |
| intl | ^0.19.0 |
| path_provider | ^2.1.2 |
| cupertino_icons | ^1.0.8 |

## Testing

```bash
flutter test
```

## License

This project is for personal/educational use.
