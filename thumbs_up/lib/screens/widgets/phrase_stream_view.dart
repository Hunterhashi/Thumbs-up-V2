import 'package:flutter/material.dart';
import 'package:thumbs_up/theme/app_theme.dart';
import 'package:thumbs_up/typing/char_status.dart';

/// Renders the target phrase with per-character coloring:
/// - pending: muted gray
/// - correct: emerald
/// - incorrect: coral, underlined
/// - cursor: underlined caret marker on the next character
///
/// This is the Easy-mode (static) Phrase Stream. Medium/Pro use
/// `SpeedStreamView` instead.
class PhraseStreamView extends StatelessWidget {
  const PhraseStreamView({
    super.key,
    required this.phrase,
    required this.statuses,
  });

  final String phrase;
  final List<CharStatus> statuses;

  @override
  Widget build(BuildContext context) {
    final baseStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          height: 1.5,
          letterSpacing: 0.3,
        );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: baseStyle,
        children: List<InlineSpan>.generate(phrase.length, (i) {
          final char = phrase[i];
          final status = statuses[i];

          switch (status) {
            case CharStatus.correct:
              return TextSpan(
                text: char,
                style: const TextStyle(
                  color: AppColors.correctEmerald,
                  fontWeight: FontWeight.w600,
                ),
              );
            case CharStatus.incorrect:
              return TextSpan(
                text: char,
                style: const TextStyle(
                  color: AppColors.typoCoral,
                  fontWeight: FontWeight.w600,
                  backgroundColor: Color(0x1AF43F5E),
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.typoCoral,
                  decorationThickness: 2,
                ),
              );
            case CharStatus.cursor:
              return TextSpan(
                text: char,
                style: const TextStyle(
                  color: AppColors.matteBlack,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.brandYellow,
                  decorationThickness: 2,
                ),
              );
            case CharStatus.pending:
              return TextSpan(
                text: char,
                style: TextStyle(
                  color: AppColors.appleGray.withValues(alpha: 0.45),
                ),
              );
          }
        }),
      ),
    );
  }
}
