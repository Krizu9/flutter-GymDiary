import 'package:sqflite/sqflite.dart';
import 'package:gymdiary/models/workoutTemplate.dart';
import 'package:gymdiary/models/workoutMovement.dart';

class DatabaseHelper {
  static const String tableWorkoutTemplate = 'workout_template';
  static const String tableWorkoutMovement = 'workout_movement';

  // Open the database and create tables if not exist
  Future<Database> openDatabaseConnection() async {
    final db = await openDatabase(
      'gym_database.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await initDatabase(db); // Initialize tables during first creation
      },
    );
    return db;
  }

  // Create tables for WorkoutTemplate and WorkoutMovement
  Future<void> initDatabase(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableWorkoutTemplate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        name TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableWorkoutMovement (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workoutTemplateId INTEGER,
        movement TEXT,
        sets INTEGER,
        lowestReps INTEGER,
        highestReps INTEGER,
        FOREIGN KEY(workoutTemplateId) REFERENCES $tableWorkoutTemplate(id)
      );
    ''');
  }

  // Insert a new workout template into the database
  Future<void> insertWorkoutTemplate(Database db, String userId, String name,
      List<WorkoutMovement> movements) async {
    // Insert the template
    final templateId = await db.insert(
      tableWorkoutTemplate,
      {
        'userId': userId,
        'name': name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert each movement as a separate record in the workout_movement table
    for (var movement in movements) {
      await db.insert(
        tableWorkoutMovement,
        {
          'workoutTemplateId': templateId,
          ...movement.toMap(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Fetch all workout templates with their movements
  Future<List<WorkoutTemplate>> fetchWorkoutTemplatesWithMovements(
      Database db) async {
    final List<Map<String, dynamic>> templates =
        await db.query(tableWorkoutTemplate);

    print("Fetched templates: $templates"); // Log the entire result set

    List<WorkoutTemplate> workoutTemplates = [];

    for (var template in templates) {
      print("Template ID: ${template['id']}"); // Log the template ID

      final templateId = template['id']?.toString();
      final movementsMap = await db.query(
        tableWorkoutMovement,
        where: 'workoutTemplateId = ?',
        whereArgs: [templateId],
      );

      List<WorkoutMovement> movements = movementsMap.map((movementMap) {
        return WorkoutMovement.fromMap(movementMap);
      }).toList();

      workoutTemplates.add(WorkoutTemplate.fromMap(template, movements));
    }

    return workoutTemplates;
  }
}
