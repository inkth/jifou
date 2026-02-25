import 'package:flutter/material.dart';
import 'dart:math';

class StarryBackground extends StatefulWidget {
  final Widget child;
  const StarryBackground({super.key, required this.child});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = List.generate(50, (index) => Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarPainter(_stars, _controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class Star {
  final double x = Random().nextDouble();
  final double y = Random().nextDouble();
  final double size = Random().nextDouble() * 2 + 1;
  final double opacity = Random().nextDouble();
}

class _StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  _StarPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      final x = star.x * size.width;
      final y = star.y * size.height;
      final currentOpacity = (star.opacity + animationValue) % 1.0;
      
      paint.color = Colors.white.withOpacity(currentOpacity * 0.5);
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
