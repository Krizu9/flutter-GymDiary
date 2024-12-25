import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  
  // Open the database and create tables if not exist
  Future<Database> openDatabaseConnection() async {
    final db = await openDatabase(
      'gym_database.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await initDatabase(db); // Initialize tables during first creation
      }
    );
    return db;
  }

  Future<void> initDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // Create workouts table
    await db.execute('''
    CREATE TABLE workouts (
      workoutId TEXT PRIMARY KEY,
      workoutTemplateId TEXT DEFAULT '',
      name TEXT NOT NULL,
      date INTEGER NOT NULL
    )
  ''');

    // Create workout_movements table
    await db.execute('''
    CREATE TABLE workout_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      template_id INTEGER KEY NOT NULL,
      workoutId TEXT NOT NULL,
      movement TEXT NOT NULL,
      sets INTEGER NOT NULL,
      FOREIGN KEY (workoutId) REFERENCES workouts(workoutId) ON DELETE CASCADE
    )
  ''');

    // Create movement_reps table
    await db.execute('''
    CREATE TABLE movement_reps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      movementId INTEGER NOT NULL,
      rep INTEGER NOT NULL,
      FOREIGN KEY (movementId) REFERENCES workout_movements(id) ON DELETE CASCADE
    )
  ''');

    // Create movement_weights table
    await db.execute('''
    CREATE TABLE movement_weights (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      movementId INTEGER NOT NULL,
      weight INTEGER NOT NULL,
      FOREIGN KEY (movementId) REFERENCES workout_movements(id) ON DELETE CASCADE
    )
  ''');

    // Create workout_templates table
    await db.execute('''
    CREATE TABLE workout_templates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    // Create template_movements table
    await db.execute('''
    CREATE TABLE template_movements (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      templateId INTEGER NOT NULL,
      movement TEXT NOT NULL,
      sets INTEGER NOT NULL,
      FOREIGN KEY (templateId) REFERENCES workout_templates(id) ON DELETE CASCADE
    )
  ''');
  }
}
