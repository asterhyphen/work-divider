import 'package:flutter/material.dart';
import 'package:meowdabattery/theme/app_theme.dart';

class SketchBackground extends StatelessWidget {
  final Widget child;

  const SketchBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.bgSubtle),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _SketchBackgroundPainter()),
          child,
        ],
      ),
    );
  }
}

class _SketchBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.paperLine.withValues(alpha: 0.65)
      ..strokeWidth = 1;
    for (double y = 38; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final marginPaint = Paint()
      ..color = AppColors.accentRed.withValues(alpha: 0.20)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(26, 0), Offset(26, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
