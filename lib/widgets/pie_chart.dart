import 'dart:math' as math;

import 'package:flutter/material.dart';

class PieSlice {
  final double value;
  final Color color;

  const PieSlice({required this.value, required this.color});
}

class PieChart extends StatelessWidget {
  final List<PieSlice> slices;
  final double size;
  final double thickness;
  final Color emptyColor;
  final Widget? center;

  const PieChart({
    super.key,
    required this.slices,
    this.size = 180,
    this.thickness = 26,
    required this.emptyColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PiePainter(
          slices: slices,
          thickness: thickness,
          emptyColor: emptyColor,
        ),
        child: center == null ? null : Center(child: center),
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<PieSlice> slices;
  final double thickness;
  final Color emptyColor;

  const _PiePainter({
    required this.slices,
    required this.thickness,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    final center = size.center(Offset.zero);
    final radius = (math.min(size.width, size.height) - thickness) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    if (total <= 0) {
      paint.color = emptyColor;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    const gap = 0.05;
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = (s.value / total) * (2 * math.pi);
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start + gap / 2,
        math.max(sweep - gap, 0),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter old) =>
      old.slices != slices ||
      old.thickness != thickness ||
      old.emptyColor != emptyColor;
}
