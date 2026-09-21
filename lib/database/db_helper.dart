import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fittrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id INTEGER PRIMARY KEY,
        step_goal INTEGER NOT NULL,
        calorie_goal INTEGER NOT NULL
      )
    ''');

    // Insert Default Goals
    await db.insert('goals', {'id': 1, 'step_goal': 10000, 'calorie_goal': 2000});
  }

  // Activity CRUD Operations
  Future<int> insertActivity(ActivityModel activity) async {
    final db = await instance.database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<ActivityModel>> getAllActivities() async {
    final db = await instance.database;
    final result = await db.query('activities', orderBy: 'date DESC');
    return result.map((json) => ActivityModel.fromMap(json)).toList();
  }

  Future<int> updateActivity(ActivityModel activity) async {
    final db = await instance.database;
    return await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await instance.database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goals Operations
  Future<Map<String, int>> getGoals() async {
    final db = await instance.database;
    final result = await db.query('goals', where: 'id = ?', whereArgs: [1]);
    if (result.isNotEmpty) {
      return {
        'step_goal': result.first['step_goal'] as int,
        'calorie_goal': result.first['calorie_goal'] as int,
      };
    }
    return {'step_goal': 10000, 'calorie_goal': 2000};
  }

  Future<void> updateGoals(int stepGoal, int calorieGoal) async {
    final db = await instance.database;
    await db.update(
      'goals',
      {'step_goal': stepGoal, 'calorie_goal': calorieGoal},
      where: 'id = ?',
      whereArgs: [1],
    );
  }
}