import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class WorkoutViewPage extends StatefulWidget {
  const WorkoutViewPage({super.key});

  @override
  _WorkoutViewPageState createState() => _WorkoutViewPageState();
}

class _WorkoutViewPageState extends State<WorkoutViewPage> {
 

  @override
  void initState() {
    super.initState();

  }

  Future<void> fetchTemplates() async {
   
  }

  Future<void> fetchWorkouts() async {
   
  }

  Future<void> deleteWorkout() async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.workoutViewPage ?? 'View Workouts'),
      ),
      body: Text("Workout View Page"),
    );
  }
}

