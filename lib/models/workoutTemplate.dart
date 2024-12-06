import 'package:gymdiary/models/workoutMovement.dart';

class WorkoutTemplate {
  String id;
  String userId;
  String name;
  List<WorkoutMovement> movements;

  WorkoutTemplate({
    required this.id,
    required this.userId,
    required this.name,
    required this.movements,
  });

  // Convert WorkoutTemplate to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
    };
  }

  // Convert Map to WorkoutTemplate
  factory WorkoutTemplate.fromMap(
      Map<String, dynamic> map, List<WorkoutMovement> movements) {
    final id = map['id']?.toString() ??
        'defaultId'; // Fallback to a default string if id is null

    return WorkoutTemplate(
      id: id,
      userId: map['userId'] ?? 'defaultUserId', // Handle null userId as well
      name: map['name'] ?? 'defaultName', // Handle null name if needed
      movements: movements,
    );
  }
}
