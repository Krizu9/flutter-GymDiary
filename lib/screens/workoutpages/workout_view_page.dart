import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkoutViewPage extends StatelessWidget {
  const WorkoutViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.workoutViewPage),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [],
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)!.workoutViewPage,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
