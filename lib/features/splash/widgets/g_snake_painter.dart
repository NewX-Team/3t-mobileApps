import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter that renders a geometric letter 'G'.
///
/// During the entrance animation, a stylized snake icon moves along the 'G' path,
/// drawing the letter stroke behind it. The snake undulates subtly while in motion,
/// flicking a tiny tongue, and cleanly settles once the 'G' path completes.
class GSnakePainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final Color snakeColor;
  final Color trackColor;
  final double strokeWidth;

  const GSnakePainter({
    required this.progress,
    this.strokeColor = const Color(0xFFFFFFFF),
    this.snakeColor = const Color(0xFF10B981),
    this.trackColor = const Color(0xFF1E293B),
    this.strokeWidth = 11.0,
  });

  /// Builds a clean, geometric uppercase 'G' path as a single continuous contour.
  static Path buildGPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    final path = Path();

    // The capital 'G' begins at the upper-right opening (around -35 degrees)
    const startAngle = -35.0 * (math.pi / 180.0);

    // Sweeps counter-clockwise across top, left, bottom, and up to 3 o'clock (0 degrees).
    // Total sweep: -325 degrees
    const sweepAngle = -325.0 * (math.pi / 180.0);

    final rect = Rect.fromCircle(center: center, radius: radius);
    path.addArc(rect, startAngle, sweepAngle);

    // From 3 o'clock, the crossbar cuts horizontally straight left into the center
    path.lineTo(center.dx + (radius * 0.08), center.dy);

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final path = buildGPath(size);
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final totalLength = metric.length;

    // 1. Draw subtle background track (guide path)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, trackPaint);

    final clampedProgress = progress.clamp(0.0, 1.0);
    final currentDistance = totalLength * clampedProgress;

    // 2. Draw the solid stroke laid down by the snake
    if (currentDistance > 0.0) {
      final solidStrokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final drawnPath = metric.extractPath(0.0, currentDistance);
      canvas.drawPath(drawnPath, solidStrokePaint);
    }

    // 3. Draw the active snake body & head while the animation is progressing
    if (clampedProgress > 0.001 && clampedProgress < 0.999) {
      final tangent = metric.getTangentForOffset(currentDistance);
      if (tangent != null) {
        final forwardVec = tangent.vector;
        final normalVec = Offset(-forwardVec.dy, forwardVec.dx);

        // Snake body segment trailing directly behind the head (last 36 pixels)
        final bodyStartDistance = math.max(0.0, currentDistance - 36.0);
        final snakeBodyPath = metric.extractPath(bodyStartDistance, currentDistance);

        final snakeBodyPaint = Paint()
          ..color = snakeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawPath(snakeBodyPath, snakeBodyPaint);

        // Gentle slither wiggle: subtle lateral oscillation that dampens to zero near end
        final wiggle = (clampedProgress < 0.90)
            ? math.sin(clampedProgress * math.pi * 14.0) * 2.2 * (1.0 - clampedProgress)
            : 0.0;
        final effectiveHeadPos = tangent.position + (normalVec * wiggle);

        // Draw the snake head icon aligned with the path's tangent angle
        canvas.save();
        canvas.translate(effectiveHeadPos.dx, effectiveHeadPos.dy);
        canvas.rotate(tangent.angle);

        _drawSnakeHead(canvas, clampedProgress);

        canvas.restore();
      }
    }
  }

  /// Draws a sleek, non-slop geometric snake head with eyes and tongue.
  void _drawSnakeHead(Canvas canvas, double p) {
    // 1. Head shape (solid rounded shield/oval)
    final headPaint = Paint()
      ..color = snakeColor
      ..style = PaintingStyle.fill;

    final headRect = RRect.fromRectAndRadius(
      const Rect.fromCenter(center: Offset(1.5, 0), width: 17.0, height: 13.0),
      const Radius.circular(6.5),
    );
    canvas.drawRRect(headRect, headPaint);

    // 2. Eyes (two sleek, high-contrast dots)
    final eyeBasePaint = Paint()
      ..color = const Color(0xFF0B132B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(3.5, -3.2), 1.7, eyeBasePaint);
    canvas.drawCircle(const Offset(3.5, 3.2), 1.7, eyeBasePaint);

    final eyePupilPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(4.0, -3.2), 0.7, eyePupilPaint);
    canvas.drawCircle(const Offset(4.0, 3.2), 0.7, eyePupilPaint);

    // 3. Snake tongue (subtle flick while in motion, retracts before arriving)
    if (p > 0.12 && p < 0.88) {
      final tongueCycle = math.sin(p * 45.0);
      if (tongueCycle > 0.0) {
        final tonguePaint = Paint()
          ..color = const Color(0xFFEF4444)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..strokeCap = StrokeCap.round;

        final tongueLength = 4.0 * tongueCycle;
        // Tongue stem
        canvas.drawLine(
          const Offset(10.0, 0),
          Offset(10.0 + tongueLength, 0),
          tonguePaint,
        );
        // Forked tips
        canvas.drawLine(
          Offset(10.0 + tongueLength, 0),
          Offset(10.0 + tongueLength + 2.0, -1.8),
          tonguePaint,
        );
        canvas.drawLine(
          Offset(10.0 + tongueLength, 0),
          Offset(10.0 + tongueLength + 2.0, 1.8),
          tonguePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GSnakePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.snakeColor != snakeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
