import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gymdiary/providers/workoutTemplateProvider.dart';
import 'package:gymdiary/providers/workoutProvider.dart';
import 'package:gymdiary/models/workoutModel.dart';
import 'package:gymdiary/models/workoutMovement.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class WorkoutViewPage extends StatefulWidget {
  const WorkoutViewPage({super.key});

  @override
  _WorkoutViewPageState createState() => _WorkoutViewPageState();
}

class _WorkoutViewPageState extends State<WorkoutViewPage> {
  @override
  void initState() {
    super.initState();
    fetchWorkouts();
    fetchTemplates();
  }

  Future<void> fetchTemplates() async {
    final workoutTemplateProvider =
        Provider.of<WorkoutTemplateProvider>(context, listen: false);
    await workoutTemplateProvider.fetchWorkoutTemplates();
  }

  Future<void> fetchWorkouts() async {
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    await workoutProvider.fetchWorkouts();
  }

  Future<void> deleteWorkout(Workout workout) async {
    final workoutProvider =
        Provider.of<WorkoutProvider>(context, listen: false);
    await workoutProvider
        .deleteWorkout(workout); // Ensure you implement this in the provider
    fetchWorkouts(); // Refetch the workouts after deletion
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutViewPage),
      ),
      body: _buildWorkoutList(workoutProvider),
    );
  }

  Widget _buildWorkoutList(WorkoutProvider workoutProvider) {
    return FutureBuilder<List<Workout>>(
      future: workoutProvider.fetchWorkouts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final workouts = snapshot.data!;
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                return Card(
                  child: ListTile(
                    title: Text(workout.name),
                    onTap: () => showWorkoutDetails(context, workout),
                    subtitle:
                        Text(DateFormat('dd/MM/yyyy').format(workout.date)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => setState(
                        () {
                          deleteWorkout(workout);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<void> showWorkoutDetails(BuildContext context, Workout workout) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            workout.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 24, // Increase the font size for the title
                ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loop through each movement in the workout
                for (var index = 0; index < workout.movements.length; index++)
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Display movement name as a header with larger font
                          Text(
                            workout.movements[index].movement,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22, // Larger font for movement name
                                ),
                          ),
                          SizedBox(height: 8),
                          // Display each set's reps and weights with larger font
                          for (var i = 0;
                              i < workout.movements[index].sets;
                              i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  // Set number in bold and larger
                                  Expanded(
                                    child: Text(
                                      '${AppLocalizations.of(context)!.set} ${i + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  20), // Larger font for set number
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  // Display reps and weights with larger font
                                  Expanded(
                                    child: Text(
                                      '${i < workout.movements[index].reps.length ? workout.movements[index].reps[i] : 'N/A'} ${AppLocalizations.of(context)!.reps}, ${i < workout.movements[index].weights.length ? workout.movements[index].weights[i] : 'N/A'} kg',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontSize:
                                                  18), // Larger font for reps and weight
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                '${AppLocalizations.of(context)!.close}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 18), // Larger font for Close button
              ),
            ),
          ],
        );
      },
    );
  }
}
