import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseHelper.dart';
import 'package:gymdiary/models/workoutTemplate.dart';
import 'package:gymdiary/models/workoutMovement.dart';

class WorkoutTemplateProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Database? _db; // Database connection

  List<WorkoutTemplate> _workoutTemplates = [];

  List<WorkoutTemplate> get workoutTemplates => _workoutTemplates;

  // Initialize the database
  Future<void> initDatabase() async {
    _db = await _dbHelper.openDatabaseConnection();
    notifyListeners();
  }

  // Fetch workout templates from the database
  Future<void> fetchWorkoutTemplates() async {
    try {
      if (_db == null) {
        await initDatabase(); // Initialize if not already initialized
      }
      List<WorkoutTemplate> fetchedTemplates =
          await _dbHelper.fetchWorkoutTemplatesWithMovements(_db!);

      // Debugging print statement
      print("Fetched templates from DB: $fetchedTemplates");

      _workoutTemplates = fetchedTemplates;
      notifyListeners();
    } catch (e) {
      print("Error fetching workout templates: $e");
    }
  }

  void updateWorkoutTemplate(
      String templateId, String name, List<WorkoutMovement> movements) {
    final index =
        _workoutTemplates.indexWhere((template) => template.id == templateId);
    if (index != -1) {
      _workoutTemplates[index] = WorkoutTemplate(
        id: templateId,
        userId: _workoutTemplates[index].userId,
        name: name,
        movements: movements,
      );
      notifyListeners();
    }
  }

  // Add a new workout template with movements
  // Add a new workout template with movements
  Future<void> addWorkoutTemplate(
      String name, List<WorkoutMovement> movements) async {
    if (_db == null) {
      await initDatabase(); // Initialize if not already initialized
    }

    // Insert the workout template (without movements)
    final templateId = await _db!.insert(
      DatabaseHelper.tableWorkoutTemplate,
      {
        'name': name,
        
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );


    // Insert each movement related to this workout template
    for (var movement in movements) {
      await _db!.insert(
        DatabaseHelper.tableWorkoutMovement,
        {
          'workoutTemplateId':
              templateId.toString(), // Convert to String before inserting
          ...movement.toMap(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Fetch workout templates after insertion
    await fetchWorkoutTemplates(); // Ensure that the templates are refreshed

    // Optionally notify listeners
    notifyListeners();
  }


  // Delete a workout template by ID
  Future<void> deleteTemplate(String templateId) async {
    if (_db == null) {
      await initDatabase(); // Initialize if not already initialized
    }
    await _db!.delete(
      DatabaseHelper.tableWorkoutTemplate,
      where: 'id = ?',
      whereArgs: [templateId],
    );
    await fetchWorkoutTemplates(); // Refresh the list after deletion
  }
}
