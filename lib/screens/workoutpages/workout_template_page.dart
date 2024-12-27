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
          return ListView.builder(
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return ListTile(
                title: Text(template.name),
                subtitle: Text(
                    '${AppLocalizations.of(context)!.movements}: ${template.movements.length}'),
                onTap: () => _showTemplateDetailsDialog(template),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    workoutProvider.deleteTemplate(template.id);
                  },
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<void> _showAddTemplateDialog() async {
    return showDialog(
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
    );
  }

  Future<void> _showTemplateDetailsDialog(WorkoutTemplate template) async {
    final workoutProvider =
        Provider.of<WorkoutTemplateProvider>(context, listen: false);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${template.name}'),
          content: SingleChildScrollView(
            child: FutureBuilder<List<WorkoutTemplate>>(
              future: workoutProvider.fetchWorkoutTemplates(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context)!.noWorkoutTemplates));
                } else {
                  final templates = snapshot.data!;
                  final selectedTemplate = templates.firstWhere(
                    (item) => item.id == template.id,
                    orElse: () => template,
                  );
                  return Column(
                    children: selectedTemplate.movements.map((movement) {
                      return ListTile(
                        title: Text(movement.movement),
                        subtitle: Text(
                            '${AppLocalizations.of(context)!.sets}: ${movement.sets}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            workoutProvider.deleteMovementFromTemplate(
                                selectedTemplate, movement);
                            Navigator.pop(context);
                            _showTemplateDetailsDialog(template);
                          },
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.close),
            ),
            ElevatedButton(
              onPressed: () {
                _showAddMovementDialog(template);
              },
              child: Text(AppLocalizations.of(context)!.addMovement),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddMovementDialog(WorkoutTemplate template) async {
    final movementController = TextEditingController();
    final setsController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addMovement),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: movementController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.movementName,
                  ),
                ),
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.sets,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                final movementName = movementController.text;
                final sets = int.tryParse(setsController.text) ?? 0;

                if (movementName.isNotEmpty && sets > 0) {
                  final newMovement = WorkoutMovement(
                    movement: movementName,
                    sets: sets,
                    reps: [],
                    weights: [],
                  );

                  Provider.of<WorkoutTemplateProvider>(context, listen: false)
                      .addMovementToTemplate(template, newMovement);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  _showTemplateDetailsDialog(template);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.validMovementAndSets)));
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
