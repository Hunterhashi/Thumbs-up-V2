import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/session_result.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/screens/widgets/result_stat_card.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Shown after a Practice run finishes: WPM, accuracy, time and mistakes,
/// with actions to try again or return Home.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result, this.isNewBest = false});

  final SessionResult result;

  /// Whether this run just set a new personal best WPM for its difficulty.
  final bool isNewBest;

  String _formatElapsed(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isStream = result.isSpeedStream;
    // Easy is now a timed phrase loop — same primary action as Speed Stream.
    final isTimedRun = isStream || result.difficulty == Difficulty.easy;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                l10n.resultHeadline,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.resultSummaryLine(
                  result.difficulty.label(l10n),
                  result.category.label(l10n),
                  _formatElapsed(result.elapsed),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (isNewBest) ...[
                const SizedBox(height: 12),
                _NewPersonalBestBadge(label: l10n.resultNewBestBadge),
              ],
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: ResultStatCard(
                      label: l10n.statsWpm,
                      value: result.wpm.round().toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ResultStatCard(
                      label: l10n.statsAccuracy,
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
                      label: isStream
                          ? l10n.resultStatCompleted
                          : l10n.resultStatMistakes,
                      value: isStream
                          ? result.completedWords.toString()
                          : result.mistakes.toString(),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ResultStatCard(
                      label: isStream
                          ? l10n.resultStatMissed
                          : l10n.resultStatBackspaces,
                      value: isStream
                          ? result.missedWords.toString()
                          : result.backspaces.toString(),
                    ),
                  ),
                ],
              ),
              if (isStream) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ResultStatCard(
                        label: l10n.resultStatMistakes,
                        value: result.mistakes.toString(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ResultStatCard(
                        label: l10n.resultStatBackspaces,
                        value: result.backspaces.toString(),
                      ),
                    ),
                  ],
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => AppRouter.nextPhrase(
                    context,
                    result.difficulty,
                    result.category,
                  ),
                  child: Text(
                    isTimedRun ? l10n.resultPlayAgain : l10n.resultNextPhrase,
                  ),
                ),
              ),
              if (!isTimedRun) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => AppRouter.repeatPhrase(
                      context,
                      result.difficulty,
                      result.category,
                      result.phrase,
                    ),
                    child: Text(l10n.resultRepeat),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => AppRouter.toHome(context),
                  child: Text(l10n.resultChangeDifficulty),
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

class _NewPersonalBestBadge extends StatelessWidget {
  const _NewPersonalBestBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandYellow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandYellow.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 16,
            color: AppColors.matteBlack,
          ),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
