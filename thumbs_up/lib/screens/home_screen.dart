import 'package:flutter/material.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/progress/onboarding_store.dart';
import 'package:thumbs_up/progress/personal_best_store.dart';
import 'package:thumbs_up/screens/widgets/difficulty_card.dart';
import 'package:thumbs_up/screens/widgets/onboarding_tips_dialog.dart';

/// Lets the user pick a difficulty, then starts a Practice run.
///
/// Medium/Pro ("Speed Stream") are shown but not yet playable — they are a
/// later milestone (see plan: "Medium/Pro: Dynamic Phrase Stream").
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<Difficulty, double> _bestWpm = {};

  @override
  void initState() {
    super.initState();
    _loadPersonalBests();
    // Waits for the first frame so the dialog has a fully built Navigator
    // to attach to, matching the pattern used elsewhere for post-build work.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOnboardingTips();
    });
  }

  Future<void> _loadPersonalBests() async {
    for (final difficulty in Difficulty.values) {
      final best = await PersonalBestStore.load(difficulty);
      if (best == null || !mounted) continue;
      setState(() => _bestWpm[difficulty] = best.wpm);
    }
  }

  Future<void> _maybeShowOnboardingTips() async {
    final hasSeenTips = await OnboardingStore.hasSeenTips();
    if (hasSeenTips || !mounted) return;
    await showOnboardingTipsDialog(context);
    await OnboardingStore.markTipsSeen();
  }

  void _onSelectDifficulty(BuildContext context, Difficulty difficulty) {
    if (!difficulty.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${difficulty.label} (Speed Stream) is coming soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    AppRouter.toPractice(context, difficulty);
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
              const SizedBox(height: 24),
              Text(
                'Choose Your\nChallenge',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Pick a difficulty and start typing',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: Difficulty.values.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final difficulty = Difficulty.values[index];
                    return DifficultyCard(
                      difficulty: difficulty,
                      bestWpm: _bestWpm[difficulty],
                      onTap: () => _onSelectDifficulty(context, difficulty),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
