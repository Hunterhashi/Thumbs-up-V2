import 'package:thumbs_up/data/easy_phrases_en.dart';
import 'package:thumbs_up/data/easy_phrases_punctuation_numbers_en.dart';
import 'package:thumbs_up/models/phrase_category.dart';

/// Easy-difficulty phrase pool for each [PhraseCategory].
///
/// Kept as a plain map (rather than baking category into each screen) so
/// Medium/Pro ("Speed Stream") can index into the same packs once that mode
/// ships; only Easy is playable today.
const Map<PhraseCategory, List<String>> easyPhrasePacks = {
  PhraseCategory.everyday: easyPhrasesEn,
  PhraseCategory.punctuationNumbers: easyPhrasesPunctuationNumbersEn,
};
