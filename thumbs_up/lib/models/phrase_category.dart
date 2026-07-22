/// A named pool of phrases the user can pick before starting a run,
/// independent of [Difficulty].
///
/// Only Easy uses these today; Medium/Pro ("Speed Stream") are expected to
/// reuse the same packs once that mode ships (see `lib/data/phrase_packs.dart`).
enum PhraseCategory {
  everyday,
  punctuationNumbers;

  String get label => switch (this) {
    PhraseCategory.everyday => 'Everyday',
    PhraseCategory.punctuationNumbers => 'Punctuation & Numbers',
  };

  String get description => switch (this) {
    PhraseCategory.everyday => 'Casual, lowercase sentences',
    PhraseCategory.punctuationNumbers =>
      'Practice numbers, symbols and punctuation',
  };
}
