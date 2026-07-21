/// Per-character render state for the Phrase Stream.
enum CharStatus {
  /// Not yet typed.
  pending,

  /// Typed and matches the target character at this position.
  correct,

  /// Typed and does not match the target character at this position.
  incorrect,

  /// The next character the user should type (caret position).
  cursor,
}
