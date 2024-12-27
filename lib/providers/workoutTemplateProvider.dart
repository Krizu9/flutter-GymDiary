import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'databaseHelper.dart';
import 'package:gymdiary/models/workoutTemplate.dart';
import 'package:gymdiary/models/workoutMovement.dart';

class WorkoutTemplateProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Database? _db;

  WorkoutTemplateProvider() {
    _databaseHelper.openDatabaseConnection().then((value) {
      _db = value;
    });
  }

  // Fetch workout templates from the database
  Future<List<WorkoutTemplate>> fetchWorkoutTemplates() async {
    // Fetch workout templates
    final fetchedTemplates = await _db?.query('workout_templates');
    final fetchedMovements = await _db?.query('template_movements');
    /*
    debugPrint("-------------------------------------------------------\n");
    debugPrint("info about fetched workout templates and movements");
    debugPrint("templates: $fetchedTemplates");
    debugPrint("movements: $fetchedMovements \n");
    debugPrint("-------------------------------------------------------\n");
    */
    if (fetchedTemplates == null) {
      return [];    
    }

    final List<WorkoutTemplate> results = [];

    for (final template in fetchedTemplates) {
      final List<Map<String, dynamic>> movements = fetchedMovements!
          .where((movement) => movement['templateId'] == template['id'])
          .toList();

      final List<WorkoutMovement> workoutMovements = movements.map((movement) {
        return WorkoutMovement(
          movement: movement['movement'],
          sets: movement['sets'],
          reps: [0],
          weights: [0],
        );
      }).toList();

      results.add(WorkoutTemplate(
        id: template['id'] as int,
        name: template['name'].toString(),
        movements: workoutMovements,
      ));
    }

    return results; // Return the list of WorkoutTemplates
  }


  // Add a new workout template with movements
  Future<void> addWorkoutTemplate(WorkoutTemplate template) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    await db.transaction((txn) async {
      // Insert the workout template
      final int templateId = await txn.insert(
        'workout_templates',
        {'name': template.name},
      );

      // Insert each movement associated with the template
      for (WorkoutMovement movement in template.movements) {
        // Insert movement into the template_movements table
        final int movementId = await txn.insert(
          'template_movements',
          {
            'templateId': templateId,
            'movement': movement.movement,
            'sets': movement.sets,
          },
        );

        // Insert each rep for the movement into the movement_reps table
        for (int rep in movement.reps) {
          await txn.insert(
            'movement_reps',
            {'movementId': movementId, 'rep': rep},
          );
        }

        // Insert each weight for the movement into the movement_weights table
        for (int weight in movement.weights) {
          await txn.insert(
            'movement_weights',
            {'movementId': movementId, 'weight': weight},
          );
        }
      }
    });

    // Notify listeners after database operations
    notifyListeners();
  }

  Future<void> deleteMovementFromTemplate(
      WorkoutTemplate template, WorkoutMovement movement) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    await db.transaction((txn) async {
      // Delete movement from the database
      await txn.delete(
        'template_movements',
        where: 'templateId = ? AND movement = ?',
        whereArgs: [template.id, movement.movement],
      );
    });

    // Notify listeners after database operations
    notifyListeners();
  }


  // Add movement to workoutTemplate
  Future<void> addMovementToTemplate(
      WorkoutTemplate template, WorkoutMovement movement) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    await db.transaction((txn) async {
      // Insert movement into the template_movements table
      final int movementId = await txn.insert(
        'template_movements',
        {
          'templateId': template.id,
          'movement': movement.movement,
          'sets': movement.sets,
        },
      );
      debugPrint("------------------------------------------------------- \n");
      debugPrint("movementId: $movementId");
      debugPrint("------------------------------------------------------- \n");

      // Insert each rep for the movement into the movement_reps table
      for (int rep in movement.reps) {
        await txn.insert(
          'movement_reps',
          {'movementId': movementId, 'rep': rep},
        );
      }

      // Insert each weight for the movement into the movement_weights table
      for (int weight in movement.weights) {
        await txn.insert(
          'movement_weights',
          {'movementId': movementId, 'weight': weight},
        );
      }
    });

    // Notify listeners after database operations
    notifyListeners();
  }

  // Delete a workout template by ID
  Future<void> deleteTemplate(int templateId) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    await db.transaction((txn) async {
      try {
        await txn.delete(
          'workout_templates',
          where: 'id = ?',
          whereArgs: [templateId],
        );
      } catch (e) {
        debugPrint('Error deleting template: $e');
      }

      try {
        await txn.delete(
          'template_movements',
          where: 'templateId = ?',
          whereArgs: [templateId],
        );
      } catch (e) {
        debugPrint('Error deleting movements: $e');
      }
    });
    notifyListeners();
  }
}
