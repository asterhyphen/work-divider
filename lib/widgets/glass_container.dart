import 'dart:ui';
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
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveColor = color ?? AppColors.bgCard.withValues(alpha: 0.35);

    Widget innerContainer = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        border: border ??
            Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
        borderRadius: effectiveBorderRadius,
      ),
      child: child,
    );

    if (duration != null) {
      innerContainer = AnimatedContainer(
        duration: duration!,
        curve: Curves.easeOutCubic,
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveColor,
          border: border ??
              Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.0,
              ),
          borderRadius: effectiveBorderRadius,
        ),
        child: child,
      );
    }

    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: -2,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: innerContainer,
        ),
      ),
    );
  }
}
