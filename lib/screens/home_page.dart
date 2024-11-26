import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gymdiary/screens/workoutpages/workout_add_page.dart';
import 'package:gymdiary/screens/workoutpages/workout_view_page.dart';
import 'package:gymdiary/screens/workoutpages/workout_template_page.dart';

class WorkoutHomePage extends StatelessWidget {
  const WorkoutHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcome,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                _buildWorkoutButton(
                  context,
                  icon: Icons.add,
                  label: AppLocalizations.of(context)!.workoutAddPage,
                  description:
                      AppLocalizations.of(context)!.workoutAddDescription,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutAddPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                _buildWorkoutButton(
                  context,
                  icon: Icons.view_list,
                  label: AppLocalizations.of(context)!.workoutViewPage,
                  description:
                      AppLocalizations.of(context)!.workoutViewDescription,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutViewPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),

                _buildWorkoutButton(
                  context,
                  icon: Icons.list,
                  label: AppLocalizations.of(context)!.workoutTemplatePage,
                  description:
                      AppLocalizations.of(context)!.workoutTemplateDescription,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WorkoutTemplatePage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 30),
          label: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            minimumSize: const Size(200, 80),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 14,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
