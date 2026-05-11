import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight custom confetti overlay widget.
class ConfettiOverlay extends StatefulWidget {
  final bool isPlaying;
  final Widget child;

  const ConfettiOverlay({
    super.key,
    required this.isPlaying,
    required this.child,
  });

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
          _particles.removeWhere((p) => p.y > 1.2);
        });
      });
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startConfetti();
    }
  }

  void _startConfetti() {
    _particles.clear();
    for (int i = 0; i < 80; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.5,
        vx: (_random.nextDouble() - 0.5) * 0.015,
        vy: _random.nextDouble() * 0.012 + 0.005,
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.15,
        size: _random.nextDouble() * 8 + 4,
        color: _randomColor(),
      ));
    }
    _controller.forward(from: 0);
  }

  Color _randomColor() {
    final colors = [
      const Color(0xFF7B61FF),
      const Color(0xFF4FC3F7),
      const Color(0xFF69F0AE),
      const Color(0xFFFF6090),
      const Color(0xFFFFD740),
      const Color(0xFFFF5252),
      const Color(0xFF00E5FF),
      const Color(0xFFE040FB),
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(_particles),
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  double x, y, vx, vy, rotation, rotationSpeed, size;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.0003; // gravity
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
