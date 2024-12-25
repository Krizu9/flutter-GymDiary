import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:gymdiary/providers/workoutTemplateProvider.dart';
import 'package:gymdiary/models/workoutMovement.dart';
import 'package:gymdiary/providers/workoutProvider.dart';
import 'package:gymdiary/models/workoutTemplate.dart';
import 'package:gymdiary/models/workoutModel.dart';

class WorkoutAddPage extends StatefulWidget {
  final Workout? workout;

  const WorkoutAddPage({super.key, this.workout});

  @override
  _WorkoutAddPageState createState() => _WorkoutAddPageState();
}

class _WorkoutAddPageState extends State<WorkoutAddPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchPreviousWorkoutData() async {}

  Future<List<WorkoutTemplate>> _fetchWorkoutTemplates() async {
    try {
      final workoutProvider =
          Provider.of<WorkoutTemplateProvider>(context, listen: false);
      return await workoutProvider.fetchWorkoutTemplates();
    } catch (e) {
      throw Exception('Failed to fetch workout templates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)?.workoutAddPage ?? 'Add Workout'),
      ),
      body: _buildTemplateList(),
    );
  }

  Widget _buildTemplateList() {
    return FutureBuilder<List<WorkoutTemplate>>(
      future: _fetchWorkoutTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final templates = snapshot.data!;
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  title: Text(template.name),
                  onTap: () => _openWorkoutFormDialog(context, template),
                );
              },
            ),
          );
        }
      },
    );
  }

  void _openWorkoutFormDialog(BuildContext context, WorkoutTemplate template) {
    debugPrint('Opening workout form dialog');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              EdgeInsets.zero,
          child: _buildWorkoutForm(context, template),
        );
      },
    );
  }

  Widget _buildWorkoutForm(BuildContext context, WorkoutTemplate template) {
    // List to hold dynamic fields for reps and weights
    List<TextEditingController> repsControllers = [];
    List<TextEditingController> weightsControllers = [];

    // Initialize controllers for each movement and each set
    for (var movement in template.movements) {
      for (var i = 0; i < movement.sets; i++) {
        repsControllers.add(TextEditingController());
        weightsControllers.add(TextEditingController());
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          for (var movement in template.movements)
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.movement,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    // Loop to create input fields for each set
                    for (var i = 0; i < movement.sets; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: repsControllers[i],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Set ${i + 1} Reps',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: weightsControllers[i],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Set ${i + 1} Weight',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Are you sure you want to close?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text('Yes'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Close'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop();
                  },
                  child: Text('Save Workout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveWorkout(BuildContext context) {}
}
