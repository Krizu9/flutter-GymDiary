import 'package:gymdiary/models/workoutMovement.dart';

class Workout {
  String workoutId;
  String workoutTemplateId;
  String name;
  DateTime date;
  List<WorkoutMovement> movements;

  Workout({
    required this.workoutId,
    this.workoutTemplateId = '',
    required this.name,
    required this.date,
    required this.movements,
  });
}
