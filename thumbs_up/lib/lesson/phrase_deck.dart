import 'dart:math';

/// Shuffles a phrase list once and hands out phrases sequentially, so the
/// same sentence does not repeat until the whole deck has been seen.
///
/// This is a lightweight placeholder for the persisted "deck index" planned
/// once the full sentence library ships.
class PhraseDeck {
  PhraseDeck(List<String> phrases, {Random? random})
      : _order = List<String>.from(phrases)..shuffle(random ?? Random());

  final List<String> _order;
  int _cursor = 0;

  String next() {
    if (_order.isEmpty) return '';
    final phrase = _order[_cursor % _order.length];
    _cursor++;
    return phrase;
  }
}
