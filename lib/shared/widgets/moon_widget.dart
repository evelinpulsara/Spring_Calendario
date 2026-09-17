import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lunaflow/core/theme/app_colors.dart';

/// Minimal moon illustration. [progress] goes from 0 (new moon) through
/// 0.5 (full moon) back to 1 (new moon), mirroring a cycle.
class MoonWidget extends StatelessWidget {
  const MoonWidget({super.key, this.size = 120, required this.progress});

  final double size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MoonPainter(progress.clamp(0.0, 1.0).toDouble())),
    );
  }
}

class _MoonPainter extends CustomPainter {
  _MoonPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final moonRadius = radius * 0.9;

    // Soft glow behind the moon.
    canvas.drawCircle(
      center,
      radius * 0.95,
      Paint()
        ..color = AppColors.softPink.withAlpha(70)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.25),
    );

    final illumination = (1 - math.cos(2 * math.pi * progress)) / 2;
    final waxing = progress < 0.5;
    final shift = 2 * moonRadius * illumination;
    final shadowCenter = Offset(waxing ? center.dx - shift : center.dx + shift, center.dy);

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: moonRadius)));
    canvas.drawCircle(center, moonRadius, Paint()..color = AppColors.moonLight);
    canvas.drawCircle(shadowCenter, moonRadius, Paint()..color = AppColors.moonShadow);
    canvas.restore();

    canvas.drawCircle(
      center,
      moonRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.softPink.withAlpha(180),
    );
  }

  @override
  bool shouldRepaint(covariant _MoonPainter oldDelegate) => oldDelegate.progress != progress;
}
