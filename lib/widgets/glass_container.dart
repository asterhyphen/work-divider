import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meowdabattery/theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Duration? duration;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.duration,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(14);
    final effectiveColor = color ?? AppColors.bgCard;
    final effectiveBorder = border is Border ? border as Border : null;
    final effectiveBorderColor =
        effectiveBorder?.top.color ?? AppColors.ink.withValues(alpha: 0.78);
    final effectiveBorderWidth = effectiveBorder?.top.width ?? 1.6;

    final card = CustomPaint(
      painter: _SketchCardPainter(
        color: effectiveColor,
        borderColor: effectiveBorderColor,
        borderWidth: effectiveBorderWidth,
        borderRadius: effectiveBorderRadius,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    return AnimatedContainer(
      duration: duration ?? Duration.zero,
      curve: Curves.easeOutCubic,
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.10),
                blurRadius: 0,
                spreadRadius: -1,
                offset: const Offset(4, 5),
              ),
            ],
      ),
      child: card,
    );
  }
}

class _SketchCardPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  const _SketchCardPainter({
    required this.color,
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = borderRadius.topLeft.x.clamp(0, 28).toDouble();
    final rect = Offset.zero & size;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), Radius.circular(radius)),
      fillPaint,
    );

    final firstLine = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final secondLine = Paint()
      ..color = borderColor.withValues(alpha: 0.34)
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(_roughRRectPath(size, radius, 7), firstLine);
    canvas.drawPath(_roughRRectPath(size, radius, 19), secondLine);
  }

  Path _roughRRectPath(Size size, double radius, int seed) {
    final random = math.Random(seed + size.width.round() + size.height.round());
    final path = Path();
    final left = 1.5;
    final top = 1.5;
    final right = size.width - 1.5;
    final bottom = size.height - 1.5;
    final wobble = math.min(2.2, math.min(size.width, size.height) * 0.015);

    Offset jitter(double x, double y) => Offset(
      x + (random.nextDouble() - 0.5) * wobble,
      y + (random.nextDouble() - 0.5) * wobble,
    );

    void lineToJittered(double x, double y) {
      final point = jitter(x, y);
      path.lineTo(point.dx, point.dy);
    }

    path.moveTo(left + radius, top + (random.nextDouble() - 0.5) * wobble);
    lineToJittered(right - radius, top);
    path.quadraticBezierTo(right, top, right, top + radius);
    lineToJittered(right, bottom - radius);
    path.quadraticBezierTo(right, bottom, right - radius, bottom);
    lineToJittered(left + radius, bottom);
    path.quadraticBezierTo(left, bottom, left, bottom - radius);
    lineToJittered(left, top + radius);
    path.quadraticBezierTo(left, top, left + radius, top);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _SketchCardPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}
