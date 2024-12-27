import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';



class DatabaseHelper {
  // Open the database and create tables if not exist
  Future<Database> openDatabaseConnection() async {
    Directory directory;

    if (Platform.isIOS || Platform.isAndroid) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    final path = '${directory.path}/gym_database.db';

    final db = await openDatabase(
      path,
      version: 4,
      onCreate: (Database db, int version) async {
        await initDatabase(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS workout_templates (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL
            )
          ''');
        }
      },
    );
    return db;
  }

  Future<void> initDatabase(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // Create workouts table
    await db.execute('''
      CREATE TABLE workouts (
        workoutId INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutTemplateId INTEGER NOT NULL,
        name TEXT NOT NULL,
        date INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_performance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutId INTEGER NOT NULL,
        movement TEXT NOT NULL,
        sets INTEGER NOT NULL,
        reps TEXT NOT NULL,
        weights TEXT NOT NULL,
        FOREIGN KEY (workoutId) REFERENCES workouts(workoutId) ON DELETE CASCADE
      )
    ''');

    // Create workout_movements table
    await db.execute('''
      CREATE TABLE workout_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        template_id INTEGER NOT NULL,
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
