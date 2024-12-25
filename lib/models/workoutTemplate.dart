import 'package:gymdiary/models/workoutMovement.dart';

class WorkoutTemplate {
  int id;
  String name;
  List<WorkoutMovement> movements;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.movements,
  });
}

