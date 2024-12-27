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

  final _formKey = GlobalKey<FormState>();

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
        title: Text(AppLocalizations.of(context)!.workoutAddPage),
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          child: FutureBuilder<Widget>(
            future: _buildWorkoutForm(context, template),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return snapshot.data!;
              }
            },
          ),
        );
      },
    );
  }

  Future<Widget> _buildWorkoutForm(
      BuildContext context, WorkoutTemplate template) async {
    // Fetch previous workout data
    final Workout? previousWorkout =
        await Provider.of<WorkoutProvider>(context, listen: false)
            .fetchPreviousWorkoutByTemplate(template);

    // Debug print previous workout details
    /*
    debugPrint("------------------------------------\n");
    if (previousWorkout != null) {
      for (var movement in previousWorkout.movements) {
        debugPrint("Movement: ${movement.movement}");
        debugPrint("Sets: ${movement.sets}");
        debugPrint("Reps: ${movement.reps}");
        debugPrint("Weights: ${movement.weights}");
      }
      debugPrint("------------------------------------\n");
    } else {
      debugPrint("No previous workout found.\n");
    }
    */

    // Initialize controllers for reps, weights, and movement names
    List<List<TextEditingController>> repsControllers =
        List.generate(template.movements.length, (_) => []);
    List<List<TextEditingController>> weightsControllers =
        List.generate(template.movements.length, (_) => []);
    List<TextEditingController> movementNameControllers = [];
    List<bool> isEditing = List.filled(template.movements.length, false);

    // Initialize the controllers based on the previous workout or template
    // Initialize the controllers based on the previous workout or template
    for (var index = 0; index < template.movements.length; index++) {
      var movement = template.movements[index];

      // Prefill movement name controller
      movementNameControllers
          .add(TextEditingController(text: movement.movement));

      // Get the corresponding previous movement data, or default to empty if not found
      var prevMovement = previousWorkout?.movements.firstWhere(
        (prevMovement) => prevMovement.movement == movement.movement,
        orElse: () => WorkoutMovement(
            movement: '',
            sets: 0,
            reps: [],
            weights: []), // Return default if not found
      );

      // Determine the number of sets to initialize
      int numberOfSets = prevMovement?.sets ??
          movement.sets; // Use previous workout's sets or fallback to template

      // Prefill the reps and weights controllers
      for (var i = 0; i < numberOfSets; i++) {
        // Prefill reps (check if previous movement data is available)
        repsControllers[index].add(TextEditingController(
          text: prevMovement != null && prevMovement.reps.length > i
              ? prevMovement.reps[i].toString()
              : '', // If prevMovement is null or doesn't have enough reps, use an empty string
        ));

        // Prefill weights (check if previous movement data is available)
        weightsControllers[index].add(TextEditingController(
          text: prevMovement != null && prevMovement.weights.length > i
              ? prevMovement.weights[i].toString()
              : '', // If prevMovement is null or doesn't have enough weights, use an empty string
        ));
      }

      // If the previous workout had fewer sets, fill in the remaining sets with empty controllers
      if (prevMovement != null && prevMovement.sets < movement.sets) {
        for (var i = prevMovement.sets; i < movement.sets; i++) {
          repsControllers[index].add(TextEditingController());
          weightsControllers[index].add(TextEditingController());
        }
      }
    }


    return StatefulBuilder(
      builder: (context, setState) {
        return SingleChildScrollView(
          child: Form(
            key: _formKey, // Attach the Form key here
            child: Column(
              children: [
                for (var index = 0; index < template.movements.length; index++)
                  Card(
                    margin: EdgeInsets.all(8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: isEditing[index]
                                    ? TextFormField(
                                        controller:
                                            movementNameControllers[index],
                                        decoration: InputDecoration(
                                          labelText:
                                              AppLocalizations.of(context)!
                                                  .movementName,
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return AppLocalizations.of(context)!
                                                .movementNameError;
                                          }
                                          return null;
                                        },
                                      )
                                    : Text(
                                        movementNameControllers[index].text,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                              ),
                              IconButton(
                                icon: Icon(isEditing[index]
                                    ? Icons.check
                                    : Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    isEditing[index] = !isEditing[index];
                                  });
                                },
                              ),
                            ],
                          ),
                          for (var i = 0;
                              i < repsControllers[index].length;
                              i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: repsControllers[index][i],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText:
                                            AppLocalizations.of(context)!.reps,
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .repsError;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: weightsControllers[index][i],
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)!
                                            .weight,
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppLocalizations.of(context)!
                                              .weightError;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setState(() {
                                        repsControllers[index].removeAt(i);
                                        weightsControllers[index].removeAt(i);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.add),
                                label:
                                    Text(AppLocalizations.of(context)!.addSet),
                                onPressed: () {
                                  setState(() {
                                    repsControllers[index]
                                        .add(TextEditingController());
                                    weightsControllers[index]
                                        .add(TextEditingController());
                                  });
                                },
                              ),
                            ],
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
                                title: Text(AppLocalizations.of(context)!
                                    .areYouSureClose),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child:
                                        Text(AppLocalizations.of(context)!.no),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child:
                                        Text(AppLocalizations.of(context)!.yes),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final workoutProvider =
                                Provider.of<WorkoutProvider>(context,
                                    listen: false);

                            List<WorkoutMovement> workoutMovements = [];

                            for (var index = 0;
                                index < template.movements.length;
                                index++) {
                              var movement = template.movements[index];
                              List<int> reps = [];
                              List<double> weights = [];

                              for (var i = 0;
                                  i < repsControllers[index].length;
                                  i++) {
                                reps.add(
                                    int.parse(repsControllers[index][i].text));
                                weights.add(double.parse(
                                    weightsControllers[index][i].text));
                              }

                              workoutMovements.add(WorkoutMovement(
                                movement: movementNameControllers[index].text,
                                sets: repsControllers[index].length,
                                reps: reps,
                                weights: weights
                                    .map((weight) => weight.toInt())
                                    .toList(),
                              ));
                            }

                            final workout = Workout(
                              workoutTemplateId: template.id,
                              workoutId: 0,
                              name: template.name,
                              date: DateTime.now(),
                              movements: workoutMovements,
                            );

                            workoutProvider.addWorkout(workout);

                            Navigator.of(context).pop();
                          } else {
                            // Handle invalid form
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    AppLocalizations.of(context)!.invalidInput),
                              ),
                            );
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
