class WorkoutMovement {
  String movement;
  int sets;
  int lowestReps;
  int highestReps;

  WorkoutMovement({
    required this.movement,
    required this.sets,
    required this.lowestReps,
    required this.highestReps,
  });

  // Convert a WorkoutMovement to a Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'movement': movement,
      'sets': sets,
      'lowestReps': lowestReps,
      'highestReps': highestReps,
    };
  }

  // Convert a Map to a WorkoutMovement
  factory WorkoutMovement.fromMap(Map<String, dynamic> map) {
    return WorkoutMovement(
      movement: map['movement'],
      sets: map['sets'],
      lowestReps: map['lowestReps'],
      highestReps: map['highestReps'],
    );
  }
}
