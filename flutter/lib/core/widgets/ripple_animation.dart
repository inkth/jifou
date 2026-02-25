import 'package:flutter/material.dart';

class RippleAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Color color;

  const RippleAnimation({
    super.key,
    required this.child,
    required this.isAnimating,
    required this.color,
  });

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RippleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
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
          painter: _RipplePainter(
            animationValue: _controller.value,
            color: widget.color,
            isAnimating: widget.isAnimating,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final bool isAnimating;

  _RipplePainter({
    required this.animationValue,
    required this.color,
    required this.isAnimating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isAnimating) return;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;

    canvas.drawCircle(center, maxRadius * animationValue, paint);
    
    final paint2 = Paint()
      ..color = color.withOpacity((1.0 - animationValue) * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final secondValue = (animationValue + 0.5) % 1.0;
    canvas.drawCircle(center, maxRadius * secondValue, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
