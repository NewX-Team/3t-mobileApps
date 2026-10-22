import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter that renders a geometric letter 'G'.
///
/// Handles both:
/// 1. Entrance: A precision kinetic head enters from the top-right opening and
///    draws the 'G' inward into the central crossbar.
/// 2. Exit: The kinetic head reverses direction at the crossbar and travels
///    backwards in the opposite direction, retracting/un-drawing the 'G'
///    until it completely exits at the top-right opening.
///
/// Designed with ultra-clean, professional civic-tech aesthetics (no green dots,
/// no cartoon elements, no gradients, no purple).
class GSnakePainter extends CustomPainter {
  final double entranceProgress;
  final double exitProgress;
  final bool isExiting;
  final Color strokeColor;
  final Color headColor;
  final Color trackColor;
  final double strokeWidth;

  const GSnakePainter({
    required this.entranceProgress,
    this.exitProgress = 0.0,
    this.isExiting = false,
    this.strokeColor = const Color(0xFFFFFFFF),
    this.headColor = const Color(0xFFFFFFFF),
    this.trackColor = const Color(0xFF1E293B),
    this.strokeWidth = 12.0,
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
    final double trackOpacity = isExiting
        ? (1.0 - exitProgress).clamp(0.0, 1.0)
        : 1.0;
    if (trackOpacity > 0.0) {
      final trackPaint = Paint()
        ..color = trackColor.withAlpha((trackOpacity * 255).round().clamp(0, 255))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, trackPaint);
    }

    if (!isExiting) {
      // -----------------------------------------------------------------
      // ENTRANCE ANIMATION (0.0 -> 1.0)
      // Head enters from top-right and draws G inward to the center
      // -----------------------------------------------------------------
      final clampedProgress = entranceProgress.clamp(0.0, 1.0);
      final currentDistance = totalLength * clampedProgress;

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

      if (clampedProgress > 0.001 && clampedProgress < 0.999) {
        final tangent = metric.getTangentForOffset(currentDistance);
        if (tangent != null) {
          final forwardVec = tangent.vector;
          final normalVec = Offset(-forwardVec.dy, forwardVec.dx);

          // Subtle kinetic wiggle that dampens as it finishes
          final wiggle = (clampedProgress < 0.90)
              ? math.sin(clampedProgress * math.pi * 14.0) * 1.8 * (1.0 - clampedProgress)
              : 0.0;
          final effectiveHeadPos = tangent.position + (normalVec * wiggle);

          canvas.save();
          canvas.translate(effectiveHeadPos.dx, effectiveHeadPos.dy);
          canvas.rotate(tangent.angle);

          _drawKineticHead(canvas);

          canvas.restore();
        }
      }
    } else {
      // -----------------------------------------------------------------
      // EXIT ANIMATION (Opposite direction: Center -> Top-Right)
      // Head starts at the center crossbar and moves in the reverse direction,
      // un-drawing the stroke until it exits at the top-right opening.
      // -----------------------------------------------------------------
      final clampedExit = exitProgress.clamp(0.0, 1.0);
      final remainingDistance = totalLength * (1.0 - clampedExit);

      if (remainingDistance > 0.0) {
        final solidStrokePaint = Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final drawnPath = metric.extractPath(0.0, remainingDistance);
        canvas.drawPath(drawnPath, solidStrokePaint);
      }

      // During exit, the kinetic head leads the retraction at remainingDistance,
      // facing the REVERSE direction (tangent.angle + pi)
      if (clampedExit > 0.001 && clampedExit < 0.999 && remainingDistance > 0.0) {
        final tangent = metric.getTangentForOffset(remainingDistance);
        if (tangent != null) {
          final forwardVec = tangent.vector;
          // Normal vector for reverse movement
          final normalVec = Offset(forwardVec.dy, -forwardVec.dx);

          final wiggle = math.sin(clampedExit * math.pi * 12.0) * 1.6 * (1.0 - clampedExit);
          final effectiveHeadPos = tangent.position + (normalVec * wiggle);

          canvas.save();
          canvas.translate(effectiveHeadPos.dx, effectiveHeadPos.dy);
          // Rotate 180 degrees so head faces the direction of reverse travel
          canvas.rotate(tangent.angle + math.pi);

          _drawKineticHead(canvas);

          canvas.restore();
        }
      }
    }
  }

  /// Draws a clean, professional geometric kinetic head.
  /// (Strictly no green, no cartoon eyes, no tongue).
  void _drawKineticHead(Canvas canvas) {
    // 1. Sleek aerodynamic capsule head in solid white
    final headPaint = Paint()
      ..color = headColor
      ..style = PaintingStyle.fill;

    final headRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(1.0, 0), width: 17.0, height: 12.0),
      const Radius.circular(6.0),
    );
    canvas.drawRRect(headRect, headPaint);

    // 2. High-precision dark inset core for a mature, executive look
    final coreOuterPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(2.0, 0), 2.2, coreOuterPaint);

    final coreCenterPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(2.0, 0), 0.9, coreCenterPaint);
  }

  @override
  bool shouldRepaint(covariant GSnakePainter oldDelegate) {
    return oldDelegate.entranceProgress != entranceProgress ||
        oldDelegate.exitProgress != exitProgress ||
        oldDelegate.isExiting != isExiting ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.headColor != headColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
