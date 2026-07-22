import 'package:flutter/material.dart';
import 'package:thumbs_up/models/session_result.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/screens/widgets/result_stat_card.dart';

/// Shown after a Practice run finishes: WPM, accuracy, time and mistakes,
/// with actions to try again or return Home.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final SessionResult result;

  String _formatElapsed(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Nice work!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '${result.difficulty.label} · ${_formatElapsed(result.elapsed)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ResultStatCard(
                      label: 'WPM',
                      value: result.wpm.round().toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ResultStatCard(
                      label: 'Accuracy',
                      value: '${result.accuracyPercent.round()}%',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ResultStatCard(
                      label: 'Mistakes',
                      value: result.mistakes.toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ResultStatCard(
                      label: 'Backspaces',
                      value: result.backspaces.toString(),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      AppRouter.nextPhrase(context, result.difficulty),
                  child: const Text('Next phrase'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => AppRouter.repeatPhrase(
                    context,
                    result.difficulty,
                    result.phrase,
                  ),
                  child: const Text('Repeat'),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => AppRouter.toHome(context),
                  child: const Text('Change difficulty'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
