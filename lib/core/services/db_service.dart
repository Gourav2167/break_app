import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/usage_model.dart';

class DBService {
  static Database? _database;
  static const String tableName = 'usage_logs';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'have_a_break.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        app_name TEXT,
        package_name TEXT,
        duration_seconds INTEGER,
        timestamp TEXT
      )
    ''');
  }

  Future<int> insertUsage(UsageModel usage) async {
    final db = await database;
    return await db.insert(tableName, usage.toMap());
  }

  Future<List<UsageModel>> getAllUsage() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName, orderBy: 'timestamp DESC');
    return List.generate(maps.length, (i) => UsageModel.fromMap(maps[i]));
  }

  Future<void> clearLogs() async {
    final db = await database;
    await db.delete(tableName);
  }
}
