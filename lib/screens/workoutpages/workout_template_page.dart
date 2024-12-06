import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gymdiary/providers/workoutTemplateProvider.dart';
import 'package:provider/provider.dart';
import 'package:gymdiary/models/workoutMovement.dart';

class WorkoutTemplatePage extends StatefulWidget {
  const WorkoutTemplatePage({super.key});

  @override
  _WorkoutTemplatePageState createState() => _WorkoutTemplatePageState();
}

class _WorkoutTemplatePageState extends State<WorkoutTemplatePage> {
  @override
  void initState() {
    super.initState();
    final workoutProvider = Provider.of<WorkoutTemplateProvider>(context, listen: false);
    workoutProvider.fetchWorkoutTemplates();
  }
  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutTemplateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutTemplatePage),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: workoutProvider.workoutTemplates.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)!.noWorkoutTemplates,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            )
          : ListView.builder(
              itemCount: workoutProvider.workoutTemplates.length,
              itemBuilder: (context, index) {
                final template = workoutProvider.workoutTemplates[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Text(template.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: template.movements.map((movement) {
                        return Text(
                            '${movement.movement} - ${movement.sets} sets');
                      }).toList(),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        workoutProvider.deleteTemplate(template.id);
                      },
                    ),
                    onTap: () async {
                      await _showAddTemplateDialog(
                        context,
                        workoutProvider,
                        () {
                          workoutProvider.fetchWorkoutTemplates();
                        },
                        templateId: template.id.toString(),
                        initialName: template.name,
                        initialMovements: template.movements,
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showAddTemplateDialog(context, workoutProvider, () {
            workoutProvider.fetchWorkoutTemplates();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTemplateDialog(BuildContext context,
      WorkoutTemplateProvider workoutProvider, Function() onTemplateChanged,
      {String? templateId,
      String? initialName,
      List<WorkoutMovement>? initialMovements}) async {
    final TextEditingController nameController =
        TextEditingController(text: initialName ?? '');
    List<WorkoutMovement> movements = List.from(initialMovements ?? []);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(templateId == null
                  ? AppLocalizations.of(context)!.addWorkoutTemplate
                  : AppLocalizations.of(context)!.editWorkoutTemplate),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.templateName,
                      ),
                    ),
                    ...movements.map((movement) {
                      return ListTile(
                        title: Text(movement.movement),
                        subtitle: Text('${movement.sets} ${AppLocalizations.of(context)!.sets}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              movements.remove(movement);
                            });
                          },
                        ),
                      );
                    }).toList(),
                    ElevatedButton(
                      onPressed: () {
                        _showAddMovementDialog(
                          context,
                          movements,
                          () => setState(() {}),
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.addMovement),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();

                    if (name.isNotEmpty && movements.isNotEmpty) {
                      if (templateId == null) {
                        // Add new template
                        workoutProvider.addWorkoutTemplate(
                          name,
                          movements,
                        );
                      } else {
                        // Update existing template
                        workoutProvider.updateWorkoutTemplate(
                          templateId,
                          name,
                          movements,
                        );
                      }

                      onTemplateChanged();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddMovementDialog(
    BuildContext context,
    List<WorkoutMovement> movements,
    Function() onMovementAdded, // Callback to refresh state
  ) async {
    final TextEditingController movementNameController =
        TextEditingController();
    final TextEditingController setsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addMovement),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: movementNameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.movementName,
                ),
              ),
              TextField(
                controller: setsController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.sets,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final movementName = movementNameController.text.trim();
                final sets = int.tryParse(setsController.text.trim()) ?? 0;

                if (movementName.isNotEmpty && sets > 0) {
                  // Add new movement to the list
                  setState(() {
                    movements.add(WorkoutMovement(
                      movement: movementName,
                      sets: sets,
                      lowestReps: 0,
                      highestReps: 0,
                    ));
                  });

                  // Notify parent to refresh the state
                  onMovementAdded();

                  Navigator.pop(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
}
