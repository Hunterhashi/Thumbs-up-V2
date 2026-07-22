import 'package:thumbs_up/l10n/generated/app_localizations.dart';

/// A named pool of phrases the user can pick before starting a run,
/// independent of [Difficulty].
///
/// Only Easy uses these today; Medium/Pro ("Speed Stream") are expected to
/// reuse the same packs once that mode ships (see `lib/data/phrase_packs.dart`).
///
/// Display strings take [AppLocalizations] rather than being plain getters,
/// since they need to reflect the user's chosen language.
enum PhraseCategory {
  everyday,
  punctuationNumbers;

  String label(AppLocalizations l10n) => switch (this) {
    PhraseCategory.everyday => l10n.categoryEverydayLabel,
    PhraseCategory.punctuationNumbers => l10n.categoryPunctuationNumbersLabel,
  };

  String description(AppLocalizations l10n) => switch (this) {
    PhraseCategory.everyday => l10n.categoryEverydayDescription,
    PhraseCategory.punctuationNumbers =>
      l10n.categoryPunctuationNumbersDescription,
  };
}
