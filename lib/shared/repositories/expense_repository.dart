import '../../core/services/database_service.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  static const _table = 'expenses';

  Future<Expense> addExpense(Expense expense) async {
    final db = await DatabaseService.database;
    final id = await db.insert(_table, expense.toMap());
    return expense.copyWith(id: id);
  }

  Future<void> updateExpense(Expense expense) async {
    final db = await DatabaseService.database;
    await db.update(
      _table,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await DatabaseService.database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getAll() async {
    final db = await DatabaseService.database;
    final rows = await db.query(_table, orderBy: 'date DESC');
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> getByMonth(int year, int month) async {
    final db = await DatabaseService.database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 1).toIso8601String();
    final rows = await db.query(
      _table,
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<List<Expense>> searchExpenses(String query) async {
    if (query.isEmpty) return getAll();
    final db = await DatabaseService.database;
    final rows = await db.query(
      _table,
      where: 'category LIKE ? OR note LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return rows.map(Expense.fromMap).toList();
  }

  Future<Map<int, double>> getMonthlyTotals(int year) async {
    final db = await DatabaseService.database;
    final start = DateTime(year, 1, 1).toIso8601String();
    final end = DateTime(year + 1, 1, 1).toIso8601String();
    final rows = await db.query(
      _table,
      where: 'date >= ? AND date < ?',
      whereArgs: [start, end],
    );
    final map = <int, double>{};
    for (final e in rows.map(Expense.fromMap)) {
      map[e.date.month] = (map[e.date.month] ?? 0) + e.amount;
    }
    return map;
  }
}
