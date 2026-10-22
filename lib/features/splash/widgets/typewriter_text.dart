import 'package:flutter/material.dart';

/// A sleek, high-precision typewriter text widget.
///
/// Displays text character-by-character according to [progress] (0.0 to 1.0).
/// When [progress] increases, text is typed in.
/// When [progress] decreases, text is backspaced out.
/// Keeps a fixed container height to eliminate any vertical layout jumping.
class TypewriterText extends StatelessWidget {
  final String text;
  final double progress;
  final TextStyle style;
  final bool showCursor;
  final Color cursorColor;
  final double cursorHeight;
  final double cursorWidth;
  final double containerHeight;
  final bool cursorVisible;

  const TypewriterText({
    super.key,
    required this.text,
    required this.progress,
    required this.style,
    this.showCursor = true,
    this.cursorColor = const Color(0xFFFFFFFF),
    this.cursorHeight = 16.0,
    this.cursorWidth = 2.0,
    this.containerHeight = 24.0,
    this.cursorVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final charCount = (text.length * clamped).round().clamp(0, text.length);
    final visibleText = text.substring(0, charCount);

    final shouldRenderCursor = showCursor &&
        cursorVisible &&
        (charCount > 0 || clamped > 0.02);

    return SizedBox(
      height: containerHeight,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              visibleText,
              style: style,
            ),
            if (shouldRenderCursor) ...[
              const SizedBox(width: 3),
              Container(
                width: cursorWidth,
                height: cursorHeight,
                decoration: BoxDecoration(
                  color: cursorColor,
                  borderRadius: BorderRadius.circular(1.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
