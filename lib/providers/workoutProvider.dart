import 'package:flutter/material.dart';
import 'package:gymdiary/models/workoutModel.dart';
import 'package:gymdiary/providers/databaseHelper.dart';
import 'package:gymdiary/models/workoutMovement.dart';
import 'package:gymdiary/models/workoutTemplate.dart';
import 'databaseHelper.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  Database? _db;

  WorkoutProvider() {
    _databaseHelper.openDatabaseConnection().then((value) {
      _db = value;
    });
  }

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  // Save a new workout
  Future<void> addWorkout(Workout workout) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");
    /*
    debugPrint("------------------------------------\n");
    for (var movement in workout.movements) {
      debugPrint("Movement: ${movement.movement}");
      debugPrint("Sets: ${movement.sets}");
      debugPrint("Reps: ${movement.reps}");
      debugPrint("Weights: ${movement.weights}");
    }
    debugPrint("------------------------------------\n");
    */
    // Start a transaction to ensure data consistency.
    await db.transaction((txn) async {
      // Insert the workout into the workouts table.
      final workoutId = await txn.insert('workouts', {
        'workoutTemplateId': workout.workoutTemplateId,
        'name': workout.name,
        'date': workout.date.millisecondsSinceEpoch,
      });

      // Insert each movement and its performance details.
      for (var movement in workout.movements) {
        /*
        debugPrint("-----------------------------\n");
        debugPrint("Inserting movement: $movement");
        debugPrint("Workout ID: $workoutId");
        debugPrint("Movement: ${movement.movement}");
        debugPrint("Sets: ${movement.sets}");
        debugPrint("Reps: ${movement.reps}");
        debugPrint("Weights: ${movement.weights}");
        */
        debugPrint("-----------------------------\n");
        await txn.insert('workout_performance', {
          'workoutId': workoutId,
          'movement': movement.movement,
          'sets': movement.sets,
          'reps': movement.reps.join(','), // Save as a comma-separated string.
          'weights':
              movement.weights.join(','), // Save as a comma-separated string.
        });
      }
    });
  }

  // Fetch the latest workout by workout template ID
  Future<Workout?> fetchPreviousWorkoutByTemplate(
      WorkoutTemplate workoutTemplate) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    try {
      // Fetch the latest workout by workout template ID
      final List<Map<String, dynamic>> fetchedWorkouts = await db.query(
        'workouts',
        where: 'workoutTemplateId = ?',
        whereArgs: [workoutTemplate.id],
        orderBy: 'date DESC',
        limit: 1,
      );

      // If no workouts are found, return null
      if (fetchedWorkouts.isEmpty) {
        return null;
      }

      // Fetch the movements for the latest workout
      final List<Map<String, dynamic>> fetchedMovements = await db.query(
        'workout_performance',
        where: 'workoutId = ?',
        whereArgs: [fetchedWorkouts[0]['workoutId']],
      );

      // Process the movements
      final List<WorkoutMovement> movements = fetchedMovements.map((movement) {
        final movementName = movement['movement'].toString();
        final setsCount = movement['sets'] as int;

        // Parse reps and weights from comma-separated strings
        final repsList = (movement['reps'] as String)
            .split(',')
            .map((e) =>
                int.tryParse(e) ?? 0) // Use tryParse to handle invalid inputs
            .toList();
        final weightsList = (movement['weights'] as String)
            .split(',')
            .map((e) =>
                int.tryParse(e) ?? 0) // Use tryParse to handle invalid inputs
            .toList();

        return WorkoutMovement(
          movement: movementName,
          sets: setsCount,
          reps: repsList,
          weights: weightsList,
        );
      }).toList();

      // Return the latest workout
      return Workout(
        workoutId: fetchedWorkouts[0]['workoutId'],
        workoutTemplateId: fetchedWorkouts[0]['workoutTemplateId'],
        name: fetchedWorkouts[0]['name'],
        date: DateTime.fromMillisecondsSinceEpoch(fetchedWorkouts[0]['date']),
        movements: movements,
      );
    } catch (e) {
      // Handle any errors gracefully
      debugPrint("Error fetching previous workout: $e");
      return null;
    }
  }

  // Update an existing workout
  Future<void> updateWorkout() async {}

  // Delete a workout
  Future<void> deleteWorkout(Workout workout) async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    // Start a transaction to ensure data consistency.
    await db.transaction((txn) async {
      // Delete the workout from the workouts table.
      await txn.delete('workouts',
          where: 'workoutId = ?', whereArgs: [workout.workoutId]);

      // Delete the movements from the workout_performance table.
      await txn.delete('workout_performance',
          where: 'workoutId = ?', whereArgs: [workout.workoutId]);
    });
  }

  // Fetch all workouts for a user
  Future<List<Workout>> fetchWorkouts() async {
    final db = _db;
    if (db == null) throw Exception("Database not initialized");

    // Fetch workouts and their performance details
    final List<Map<String, dynamic>> fetchedWorkouts =
        await db.query('workouts');
    final List<Map<String, dynamic>> fetchedPerformance =
        await db.query('workout_performance');

    debugPrint("-------------------------------------------------------\n");
    debugPrint("info about saved workouts and movements");
    debugPrint("workouts: $fetchedWorkouts");
    debugPrint("movements: $fetchedPerformance\n");
    debugPrint("-------------------------------------------------------\n");

    // List to store the result
    late List<Workout> results = [];

    // Process each workout and its corresponding movements
    for (final workout in fetchedWorkouts) {
      final List<Map<String, dynamic>> movements = fetchedPerformance
          .where((movement) => movement['workoutId'] == workout['workoutId'])
          .toList();

      final List<WorkoutMovement> workoutMovements = movements.map((movement) {
        // Extract values directly from the movement map and convert them to the required types
        final movementName = movement['movement'].toString();
        final setsCount = movement['sets'] as int;

        // Parse reps and weights from comma-separated strings
        final repsList = (movement['reps'] as String)
            .split(',')
            .map((e) => int.parse(e))
            .toList();
        final weightsList = (movement['weights'] as String)
            .split(',')
            .map((e) => int.parse(e))
            .toList();

        return WorkoutMovement(
          movement: movementName, // String type
          sets: setsCount, // int type
          reps: repsList,
          weights: weightsList,
        );
      }).toList();

      results.add(Workout(
        workoutId: workout['workoutId'],
        workoutTemplateId: workout['workoutTemplateId'],
        name: workout['name'],
        date: DateTime.fromMillisecondsSinceEpoch(
            workout['date']), // Correct date parsing
        movements: workoutMovements,
      ));
    }

    // Debug prints for logging
    /*
    debugPrint("-------------------------------------------------------\n");
    debugPrint("info about fetched workouts and movements");
    debugPrint("workouts: $fetchedWorkouts");
    debugPrint("movements: $fetchedPerformance \n");
    debugPrint("-------------------------------------------------------\n");
    */
    // Return the list of workouts

    //reverse the list
    results = results.reversed.toList();

    return results;
  }
}
