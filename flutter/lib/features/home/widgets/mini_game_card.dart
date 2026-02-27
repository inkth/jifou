import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/records_provider.dart';

class MiniGameCard extends ConsumerStatefulWidget {
  const MiniGameCard({super.key});

  @override
  ConsumerState<MiniGameCard> createState() => _MiniGameCardState();
}

class _MiniGameCardState extends ConsumerState<MiniGameCard> with TickerProviderStateMixin {
  int health = 0;
  int wealth = 0;
  int happiness = 0;
  final int maxVal = 100;
  
  bool _hasTriggeredFullRecord = false;

  late AnimationController _waveController;
  late AnimationController _healthScaleController;
  late AnimationController _wealthScaleController;
  late AnimationController _happinessScaleController;
  
  late AnimationController _shineController;

  // 连击相关
  int _comboCount = 0;
  Timer? _comboTimer;
  
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _healthScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _wealthScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _happinessScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      setState(() {
        _tiltX = (event.x / 10).clamp(-1.0, 1.0);
        _tiltY = (event.y / 10).clamp(-1.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _shineController.dispose();
    _healthScaleController.dispose();
    _wealthScaleController.dispose();
    _happinessScaleController.dispose();
    _accelerometerSubscription?.cancel();
    _comboTimer?.cancel();
    super.dispose();
  }

  void _checkAllFull() async {
    if (health >= maxVal && wealth >= maxVal && happiness >= maxVal && !_hasTriggeredFullRecord) {
      _hasTriggeredFullRecord = true;
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();
      await ref.read(recordsProvider.notifier).addRecord(
        "✨ 恭喜！你已达成人生状态全满：健康、财富与幸福在此刻交汇。愿这份圆满长久陪伴你。",
        "text"
      );
    }
  }

  void _increment(String type) {
    _comboCount++;
    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _comboCount = 0;
          // 连击结束，恢复正常波浪速度
          _waveController.duration = const Duration(seconds: 2);
          if (!_waveController.isAnimating) _waveController.repeat();
        });
      }
    });

    // 连击加速逻辑：连击越多，波浪翻滚越快
    double speedFactor = 1.0 + (_comboCount.clamp(0, 20) / 5.0); // 最高加速 5 倍
    _waveController.duration = Duration(milliseconds: (2000 / speedFactor).round());
    if (!_waveController.isAnimating) _waveController.repeat();

    if (_comboCount > 10) {
      HapticFeedback.heavyImpact();
    } else if (_comboCount > 5) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    
    AnimationController? controller;
    if (type == 'health') controller = _healthScaleController;
    if (type == 'wealth') controller = _wealthScaleController;
    if (type == 'happiness') controller = _happinessScaleController;

    controller?.forward(from: 0.0);

    setState(() {
      // 连击奖励：连击数越高，单次点击增加的数值越多（可选，目前保持+1但视觉加速）
      if (type == 'health' && health < maxVal) health++;
      if (type == 'wealth' && wealth < maxVal) wealth++;
      if (type == 'happiness' && happiness < maxVal) happiness++;
    });

    _checkAllFull();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildArtBall('健康', health, const Color(0xFF00F2FE), const Color(0xFF4FACFE), 'health', _healthScaleController),
          _buildArtBall('财富', wealth, const Color(0xFFFAD961), const Color(0xFFF76B1C), 'wealth', _wealthScaleController),
          _buildArtBall('幸福', happiness, const Color(0xFFFF0844), const Color(0xFFFFB199), 'happiness', _happinessScaleController),
        ],
      ),
    );
  }

  Widget _buildArtBall(String label, int value, Color color1, Color color2, String type, AnimationController controller) {
    double progress = value / maxVal;
    bool isFull = value >= maxVal;
    double comboBonus = (_comboCount.clamp(0, 20) / 20.0) * 0.2;
    
    return GestureDetector(
      onTap: () => _increment(type),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color1.withOpacity((0.15 + comboBonus) * progress),
                      blurRadius: (isFull ? 35 : 25) + (_comboCount > 0 ? 10 : 0),
                      spreadRadius: (isFull ? 8 : 5) + (_comboCount > 0 ? 2 : 0),
                    ),
                  ],
                ),
              ),
              if (isFull)
                AnimatedBuilder(
                  animation: _shineController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ShineRingPainter(
                        animationValue: _shineController.value,
                        color: color1,
                      ),
                      size: const Size(76, 76),
                    );
                  },
                ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(
                    color: isFull ? color1.withOpacity(0.5 + comboBonus) : Colors.white.withOpacity(0.15 + comboBonus),
                    width: isFull ? 2.0 : 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: ArtLiquidPainter(
                            progress: progress,
                            waveValue: _waveController.value,
                            color1: color1,
                            color2: color2,
                            tiltX: _tiltX,
                            tiltY: _tiltY,
                            isCombo: _comboCount > 0,
                          ),
                          size: const Size(70, 70),
                        );
                      },
                    ),
                    if (isFull)
                      AnimatedBuilder(
                        animation: _shineController,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-2.0 + _shineController.value * 4, -1.0),
                                end: Alignment(-1.0 + _shineController.value * 4, 1.0),
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.2 + comboBonus),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          );
                        },
                      ),
                    Positioned(
                      top: 5,
                      left: 15,
                      child: Container(
                        width: 30,
                        height: 15,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.elliptical(30, 15)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.3 + comboBonus),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  final double animValue = CurvedAnimation(
                    parent: controller,
                    curve: Curves.elasticOut,
                  ).value;
                  double scale = (1.0 + comboBonus) + (animValue * 0.6);
                  
                  return Transform.scale(
                    scale: controller.isAnimating ? scale : (1.0 + comboBonus),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        if (controller.isAnimating || isFull) {
                          return LinearGradient(
                            colors: isFull 
                              ? [const Color(0xFFFFD700), Colors.white, const Color(0xFFFFD700)]
                              : [const Color(0xFFFFD700), const Color(0xFFFFFACD), const Color(0xFFFFD700)],
                          ).createShader(bounds);
                        }
                        return LinearGradient(
                          colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.9)],
                        ).createShader(bounds);
                      },
                      child: Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          shadows: [
                            if (controller.isAnimating || isFull)
                              Shadow(
                                color: const Color(0xFFFFD700).withOpacity(isFull ? 1.0 : 0.8),
                                blurRadius: (isFull ? 20 : 15 * animValue) + (_comboCount * 2),
                              ),
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShineRingPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  ShineRingPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color.withOpacity(0.8),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(animationValue * 2 * math.pi),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant ShineRingPainter oldDelegate) => true;
}

class ArtLiquidPainter extends CustomPainter {
  final double progress;
  final double waveValue;
  final Color color1;
  final Color color2;
  final double tiltX;
  final double tiltY;
  final bool isCombo;

  ArtLiquidPainter({
    required this.progress,
    required this.waveValue,
    required this.color1,
    required this.color2,
    required this.tiltX,
    required this.tiltY,
    this.isCombo = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final Rect rect = Offset.zero & size;
    canvas.clipPath(Path()..addOval(rect));

    final double tiltOffset = tiltX * 15.0;
    final double yOffset = size.height * (1 - progress) + (tiltY * 5.0);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color1, Colors.white, 0.1)!,
          color2,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(-10, yOffset - tiltOffset);
    
    for (double x = -10; x <= size.width + 10; x++) {
      double amplitude = progress > 0 && progress < 1 ? (isCombo ? 6.0 : 3.5) : 0.0;
      double y = (yOffset + (tiltOffset * (x / size.width - 0.5) * 2)) + 
                 math.sin((x / size.width * 2 * math.pi) + (waveValue * 2 * math.pi)) * amplitude;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width + 10, size.height + 10);
    path.lineTo(-10, size.height + 10);
    path.close();
    canvas.drawPath(path, paint);
    
    final paint2 = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    path2.moveTo(-10, yOffset - tiltOffset);
    for (double x = -10; x <= size.width + 10; x++) {
      double amplitude = progress > 0 && progress < 1 ? (isCombo ? 4.0 : 2.5) : 0.0;
      double y = (yOffset + (tiltOffset * (x / size.width - 0.5) * 2)) + 
                 math.sin((x / size.width * 2 * math.pi) + (waveValue * 2 * math.pi) + math.pi) * amplitude;
      path2.lineTo(x, y);
    }
    path2.lineTo(size.width + 10, size.height + 10);
    path2.lineTo(-10, size.height + 10);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant ArtLiquidPainter oldDelegate) => true;
}
