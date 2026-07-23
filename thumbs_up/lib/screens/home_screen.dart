import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/progress/onboarding_store.dart';
import 'package:thumbs_up/progress/personal_best_store.dart';
import 'package:thumbs_up/screens/widgets/difficulty_card.dart';
import 'package:thumbs_up/screens/widgets/onboarding_tips_dialog.dart';
import 'package:thumbs_up/screens/widgets/phrase_category_selector.dart';

/// Lets the user pick a difficulty, then starts a Practice run.
///
/// Easy uses a static Phrase Stream; Medium/Pro use Speed Stream.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<Difficulty, double> _bestWpm = {};
  PhraseCategory _selectedCategory = PhraseCategory.everyday;

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
    AppRouter.toPractice(context, difficulty, _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      l10n.homeHeadline,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => AppRouter.toSettings(context),
                    icon: const Icon(Icons.settings_rounded),
                    tooltip: l10n.settingsTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeSubtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              PhraseCategorySelector(
                selected: _selectedCategory,
                onChanged: (category) =>
                    setState(() => _selectedCategory = category),
              ),
              const SizedBox(height: 24),
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
