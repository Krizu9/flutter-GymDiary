import 'package:flutter/material.dart';
import 'package:gymdiary/models/workoutModel.dart';
import 'package:gymdiary/providers/databaseHelper.dart';

class WorkoutProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<Workout> _workouts = [];
  List<Workout> get workouts => _workouts;

  // Save a new workout
  Future<void> saveWorkout() async {
    
  }

  // Fetch the latest workout by workout template ID
  Future<Workout?> fetchLatestWorkoutByTemplate() async {
    
  }

  // Update an existing workout
  Future<void> updateWorkout() async {
    
  }

  // Delete a workout
  Future<void> deleteWorkout() async {
    
  }

  // Fetch all workouts for a user
  Future<void> fetchWorkouts() async {
   
  }

  // Fetch all workouts (for template or general display)
  Future<List<Workout>> fetchAllWorkouts() async {
    return _workouts;
  }
}
