import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gymdiary/providers/workoutTemplateProvider.dart';
import 'package:provider/provider.dart';
import 'package:gymdiary/models/workoutMovement.dart';
import 'package:gymdiary/models/workoutTemplate.dart';

class WorkoutTemplatePage extends StatefulWidget {
  const WorkoutTemplatePage({super.key});

  @override
  _WorkoutTemplatePageState createState() => _WorkoutTemplatePageState();
}

class _WorkoutTemplatePageState extends State<WorkoutTemplatePage> {
  TextEditingController _templateNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _templateNameController.text = '';
    final workoutProvider =
        Provider.of<WorkoutTemplateProvider>(context, listen: false);
    workoutProvider.fetchWorkoutTemplates();
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutTemplateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutTemplatePage),
      ),
      body: _buildTemplateList(workoutProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildTemplateList(WorkoutTemplateProvider workoutProvider) {
    return FutureBuilder<List<WorkoutTemplate>>(
      future: workoutProvider.fetchWorkoutTemplates(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final templates = snapshot.data!;
          return SizedBox(
            //scaling height
            height: MediaQuery.of(context).size.height * 0.9,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  title: Text(template.name),
                  subtitle: Text(
                      '${AppLocalizations.of(context)!.movements}: ${template.movements.length}'),
                  onTap: () => _showAddMovementDialog(template),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      workoutProvider.deleteTemplate(template.id);
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _showAddTemplateDialog() async {
    return (showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addWorkoutTemplate),
          content: TextField(
            controller: _templateNameController,
            decoration: InputDecoration(
                hintText: (AppLocalizations.of(context)!.templateName)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                final workoutProvider = Provider.of<WorkoutTemplateProvider>(
                    context,
                    listen: false);
                workoutProvider.addWorkoutTemplate(WorkoutTemplate(
                  id: 0,
                  name: _templateNameController.text,
                  movements: [],
                ));
                Navigator.pop(context);
                _templateNameController.clear();
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    ));
  }

  Future<void> _showAddMovementDialog(WorkoutTemplate workoutTemplate) async {
    final workoutProvider =
        Provider.of<WorkoutTemplateProvider>(context, listen: false);
    final templates = await workoutProvider.fetchWorkoutTemplates();

    // Find the selected template by its ID
    final template = templates.firstWhere(
      (t) => t.id == workoutTemplate.id,
      orElse: () => WorkoutTemplate(id: 0, name: 'error', movements: []),
    );

    if (template == null) return; // If no template found, exit

    // Set up TextControllers for adding new movement
    final movementController = TextEditingController();
    final setsController = TextEditingController();

    // Show the dialog
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Movement for ${template.name}'),
          content: Column(
            children: [
              // Display existing movements in the template
              if (template.movements.isNotEmpty)
                SingleChildScrollView(
                  child: Column(
                    children: template.movements
                        .map(
                          (movement) => ListTile(
                            title: Text(movement.movement),
                            subtitle: Text(
                                '${(AppLocalizations.of(context)!.sets)}: ${movement.sets}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                workoutProvider.deleteMovementFromTemplate(
                                    workoutTemplate, movement);
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              TextField(
                controller: movementController,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.movementName),
              ),
              TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.sets)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                final movementName = movementController.text;
                final sets = int.tryParse(setsController.text) ?? 0;

                if (movementName.isNotEmpty && sets > 0) {
                  // Create a new movement
                  final newMovement = WorkoutMovement(
                    movement: movementName,
                    sets: sets,
                    reps: [],
                    weights: [],
                  );

                  // Save the updated template
                  workoutProvider.addMovementToTemplate(
                      workoutTemplate, newMovement);

                  // Close dialog after saving
                  Navigator.pop(context);
                } else {
                  // Show a validation error
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(AppLocalizations.of(context)!.validMovementAndSets)));
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
