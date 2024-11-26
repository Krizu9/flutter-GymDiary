import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkoutTemplatePage extends StatelessWidget {
  const WorkoutTemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.workoutTemplatePage,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
