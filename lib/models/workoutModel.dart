import 'package:gymdiary/models/workoutMovement.dart';

class Workout {
  int workoutId;
  int workoutTemplateId;
  String name;
  DateTime date;
  List<WorkoutMovement> movements;

  Workout({
    required this.workoutId,
    required this.workoutTemplateId,
    required this.name,
    required this.date,
    required this.movements,
  });
}
