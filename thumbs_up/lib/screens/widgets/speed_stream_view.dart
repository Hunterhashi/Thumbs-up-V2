import 'package:flutter/material.dart';
import 'package:thumbs_up/theme/app_theme.dart';
import 'package:thumbs_up/typing/char_status.dart';
import 'package:thumbs_up/typing/speed_stream_engine.dart';

/// Clipped horizontal Speed Stream strip: words scroll left, separated by
/// interpuncts (`·`). The active (leftmost) word shows per-character status.
class SpeedStreamView extends StatefulWidget {
  const SpeedStreamView({super.key, required this.engine});

  final SpeedStreamEngine engine;

  @override
  State<SpeedStreamView> createState() => _SpeedStreamViewState();
}

class _SpeedStreamViewState extends State<SpeedStreamView> {
  static const TextStyle _baseStyle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.2,
  );

  double _lastConfiguredWidth = 0;

  double _measureWidth(String word) {
    final painter = TextPainter(
      text: TextSpan(text: word, style: _baseStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  void _configureIfNeeded(double width) {
    if (width <= 0) return;
    if ((width - _lastConfiguredWidth).abs() < 0.5 &&
        widget.engine.tokens.isNotEmpty) {
      return;
    }
    _lastConfiguredWidth = width;
    widget.engine.configure(viewportWidth: width, measureWidth: _measureWidth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _configureIfNeeded(width);
        });

        return ListenableBuilder(
          listenable: widget.engine,
          builder: (context, _) {
            return SizedBox(
              height: 56,
              width: width,
              child: ClipRect(
                child: CustomPaint(
                  painter: _SpeedStreamPainter(
                    tokens: widget.engine.tokens,
                    activeStatuses: widget.engine.buildActiveCharStatuses(),
                    gapPx: widget.engine.gapPx,
                    baseStyle: _baseStyle,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  size: Size(width, 56),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SpeedStreamPainter extends CustomPainter {
  _SpeedStreamPainter({
    required this.tokens,
    required this.activeStatuses,
    required this.gapPx,
    required this.baseStyle,
    required this.isDark,
  });

  final List<StreamToken> tokens;
  final List<CharStatus> activeStatuses;
  final double gapPx;
  final TextStyle baseStyle;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final pendingColor = AppColors.appleGray.withValues(alpha: 0.4);
    final upcomingColor = AppColors.appleGray.withValues(alpha: 0.55);
    final ink = isDark ? AppColors.pureWhite : AppColors.matteBlack;
    final centerY = size.height / 2;

    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final isActive = i == 0;

      if (isActive) {
        _paintActiveWord(canvas, token, centerY, ink, pendingColor);
      } else {
        final painter = TextPainter(
          text: TextSpan(
            text: token.word,
            style: baseStyle.copyWith(color: upcomingColor),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        painter.paint(canvas, Offset(token.x, centerY - painter.height / 2));
      }

      if (i < tokens.length - 1) {
        final sep = TextPainter(
          text: TextSpan(
            text: '·',
            style: baseStyle.copyWith(
              color: pendingColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        final sepX = token.right + (gapPx - sep.width) / 2;
        sep.paint(canvas, Offset(sepX, centerY - sep.height / 2));
      }
    }
  }

  void _paintActiveWord(
    Canvas canvas,
    StreamToken token,
    double centerY,
    Color ink,
    Color pendingColor,
  ) {
    var x = token.x;
    for (var i = 0; i < token.word.length; i++) {
      final char = token.word[i];
      final status = i < activeStatuses.length
          ? activeStatuses[i]
          : CharStatus.pending;

      final TextStyle style;
      switch (status) {
        case CharStatus.correct:
          style = baseStyle.copyWith(
            color: AppColors.correctEmerald,
            fontWeight: FontWeight.w800,
          );
        case CharStatus.incorrect:
          style = baseStyle.copyWith(
            color: AppColors.typoCoral,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.typoCoral,
            decorationThickness: 2,
            backgroundColor: const Color(0x1AF43F5E),
          );
        case CharStatus.cursor:
          style = baseStyle.copyWith(
            color: ink,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.brandYellow,
            decorationThickness: 2,
          );
        case CharStatus.pending:
          style = baseStyle.copyWith(color: pendingColor);
      }

      final painter = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      painter.paint(canvas, Offset(x, centerY - painter.height / 2));
      x += painter.width;
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedStreamPainter oldDelegate) => true;
}
