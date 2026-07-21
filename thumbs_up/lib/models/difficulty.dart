/// Practice difficulty levels available from the home screen.
///
/// `easy` uses a static Phrase Stream (no time pressure besides the run
/// itself). `medium` and `pro` are the "Speed Stream" treadmill mode and are
/// implemented in a later milestone.
enum Difficulty {
  easy,
  medium,
  pro;

  String get label => switch (this) {
        Difficulty.easy => 'Easy',
        Difficulty.medium => 'Medium',
        Difficulty.pro => 'Pro',
      };

  String get subtitle => switch (this) {
        Difficulty.easy => 'Learn accuracy',
        Difficulty.medium => 'Speed Stream',
        Difficulty.pro => 'Speed Stream+',
      };

  String get description => switch (this) {
        Difficulty.easy => 'Short, static phrases · no time pressure',
        Difficulty.medium => 'Comfortable scrolling pace · build rhythm',
        Difficulty.pro => 'Fast scrolling pace · master speed',
      };

  /// Speed Stream (Medium/Pro) is implemented in a later milestone.
  bool get isAvailable => this == Difficulty.easy;
}
