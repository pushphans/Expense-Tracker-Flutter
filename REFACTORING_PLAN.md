# 🏗️ Folder Structure Refactoring Plan

## Current Structure (1 Feature - WRONG ❌)
```
lib/features/expenses/
  ├── data/
  │   ├── models/expense_model.dart
  │   └── repositories/expense_repository.dart
  ├── domain/
  │   ├── states/
  │   │   ├── expense_list_state.dart
  │   │   ├── expense_filter_state.dart
  │   │   ├── expense_form_state.dart
  │   │   └── expense_chart_state.dart
  │   └── notifiers/
  │       ├── monthly_expense_notifier.dart
  │       ├── filtered_expense_notifier.dart
  │       ├── expense_filter_notifier.dart
  │       ├── expense_form_notifier.dart
  │       └── expense_chart_notifier.dart
  └── presentation/
      ├── screens/
      │   ├── home_screen.dart
      │   ├── stats_screen.dart
      │   ├── history_screen.dart
      │   └── add_expense_screen.dart
      └── widgets/
          ├── expense_list_tile.dart
          ├── monthly_summary_card.dart
          ├── category_pie_chart.dart
          └── monthly_bar_chart.dart
```

---

## New Structure (4 Features - CORRECT ✅)

```
lib/
├── core/
│   ├── services/
│   │   └── database_service.dart       (Shared)
│   └── constants/
│       └── app_constants.dart          (Shared)
│
├── shared/
│   ├── models/
│   │   └── expense_model.dart          ← Moved (shared by all features)
│   ├── repositories/
│   │   └── expense_repository.dart     ← Moved (shared by all features)
│   └── widgets/
│       └── expense_list_tile.dart      ← Moved (used by home + history)
│
└── features/
    │
    ├── home/                           ← Feature 1: Dashboard
    │   ├── domain/
    │   │   ├── states/
    │   │   │   └── monthly_summary_state.dart
    │   │   └── notifiers/
    │   │       └── monthly_expense_notifier.dart
    │   └── presentation/
    │       ├── screens/
    │       │   └── home_screen.dart
    │       └── widgets/
    │           └── monthly_summary_card.dart
    │
    ├── stats/                          ← Feature 2: Analytics
    │   ├── domain/
    │   │   ├── states/
    │   │   │   └── expense_chart_state.dart
    │   │   └── notifiers/
    │   │       └── expense_chart_notifier.dart
    │   └── presentation/
    │       ├── screens/
    │       │   └── stats_screen.dart
    │       └── widgets/
    │           ├── category_pie_chart.dart
    │           └── monthly_bar_chart.dart
    │
    ├── expense_form/                   ← Feature 3: Add/Edit Expense
    │   ├── domain/
    │   │   ├── states/
    │   │   │   └── expense_form_state.dart
    │   │   └── notifiers/
    │   │       └── expense_form_notifier.dart
    │   └── presentation/
    │       └── screens/
    │           └── add_expense_screen.dart
    │
    └── expense_history/                ← Feature 4: List + Search
        ├── domain/
        │   ├── states/
        │   │   ├── expense_list_state.dart
        │   │   └── expense_filter_state.dart
        │   └── notifiers/
        │       ├── filtered_expense_notifier.dart
        │       └── expense_filter_notifier.dart
        └── presentation/
            └── screens/
                └── history_screen.dart
```

---

## Feature Breakdown

### **1. home (Dashboard)**
**Responsibility:** Monthly overview, summary card
- **Screen:** home_screen.dart
- **State:** monthly_summary_state.dart
- **Notifier:** monthly_expense_notifier.dart
- **Widget:** monthly_summary_card.dart

### **2. stats (Analytics)**
**Responsibility:** Charts, statistics, yearly overview
- **Screen:** stats_screen.dart
- **State:** expense_chart_state.dart
- **Notifier:** expense_chart_notifier.dart
- **Widgets:** category_pie_chart.dart, monthly_bar_chart.dart

### **3. expense_form (CRUD)**
**Responsibility:** Add, Edit, Delete expense
- **Screen:** add_expense_screen.dart
- **State:** expense_form_state.dart
- **Notifier:** expense_form_notifier.dart

### **4. expense_history (List + Search)**
**Responsibility:** All expenses, search, filters
- **Screen:** history_screen.dart
- **States:** expense_list_state.dart, expense_filter_state.dart
- **Notifiers:** filtered_expense_notifier.dart, expense_filter_notifier.dart

---

## Shared Components

### **shared/models/**
- expense_model.dart (used by all features)

### **shared/repositories/**
- expense_repository.dart (database access for all)

### **shared/widgets/**
- expense_list_tile.dart (used by home + history)

---

## Benefits

✅ **Clear Separation**
- Each feature has single responsibility
- Easy to understand what each feature does

✅ **Independent Development**
- Can work on stats without touching home
- Can modify form without breaking history

✅ **Easy to Scale**
- Add new feature = New folder
- Remove feature = Delete folder

✅ **Better Testing**
- Test each feature independently
- Mock shared dependencies

✅ **Team Collaboration**
- Different developers can work on different features
- No merge conflicts

---

## Migration Steps

1. Create new feature folders
2. Move files to appropriate features
3. Update import paths
4. Move shared code to shared/
5. Test each feature
6. Delete old expenses/ folder

---

Ready to refactor? This will make the codebase MUCH cleaner! 🚀
