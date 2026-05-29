import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    return await openDatabase(
      p.join(await getDatabasesPath(), 'expenses.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE expenses (
          id       INTEGER PRIMARY KEY AUTOINCREMENT,
          amount   REAL    NOT NULL,
          category TEXT    NOT NULL,
          note     TEXT,
          date     TEXT    NOT NULL
        )
      '''),
    );
  }
}
