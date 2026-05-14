import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/widgets/glass_container.dart';

/// User selection card for the "Who are you?" screen.
class UserCard extends StatefulWidget {
  final String name;
  final int index;
  final VoidCallback onTap;

  const UserCard({
    super.key,
    required this.name,
    required this.index,
    required this.onTap,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _isPressed = false;

  static const _avatarGradients = [
    [Color(0xFF7B61FF), Color(0xFF5A3FD9)],
    [Color(0xFF4FC3F7), Color(0xFF2979FF)],
    [Color(0xFF69F0AE), Color(0xFF00C853)],
    [Color(0xFFFF6090), Color(0xFFE040FB)],
    [Color(0xFFFFD740), Color(0xFFFF9100)],
    [Color(0xFF00E5FF), Color(0xFF0091EA)],
    [Color(0xFFFF5252), Color(0xFFD50000)],
  ];

  static const _userIcons = [
    Icons.person_rounded,
    Icons.badge_rounded,
    Icons.school_rounded,
    Icons.palette_rounded,
    Icons.handyman_rounded,
    Icons.code_rounded,
    Icons.restaurant_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 + widget.index * 80),
    );
    _scaleAnim = Tween(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnim = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _gradient =>
      _avatarGradients[widget.index % _avatarGradients.length];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(scale: _scaleAnim.value, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: GlassContainer(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.ink.withValues(alpha: 0.70),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _gradient[0].withValues(alpha: 0.16),
                    border: Border.all(
                      color: _gradient[0].withValues(alpha: 0.75),
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: CustomPaint(
                      painter: SketchAvatarPainter(color: _gradient[0]),
                      child: Center(
                        child: Icon(
                          _userIcons[widget.index % _userIcons.length],
                          color: _gradient[0],
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SketchAvatarPainter extends CustomPainter {
  final Color color;

  const SketchAvatarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;
    final jitter = 2.6;
    final random = math.Random(size.width.round() + size.height.round());

    final path = Path();
    for (var i = 0; i <= 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      final point = Offset(
        x + (random.nextDouble() - 0.5) * jitter,
        y + (random.nextDouble() - 0.5) * jitter,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant SketchAvatarPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
