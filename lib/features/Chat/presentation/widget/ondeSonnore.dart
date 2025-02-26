import 'package:flutter/material.dart';
import 'dart:math';

class SoundWave extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final bool isPlaying; // Booléen pour contrôler l'animation

  const SoundWave({
    super.key,
    this.width = 200.0,
    this.height = 40.0,
    this.color = Colors.white,
    this.isPlaying = false, // Par défaut, l'animation est active
  });

  @override
  _SoundWaveState createState() => _SoundWaveState();
}

class _SoundWaveState extends State<SoundWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Démarrage ou arrêt de l'animation en fonction de `isPlaying`
    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SoundWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Contrôle de l'animation quand `isPlaying` change
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: SoundWavePainter(
              color: widget.color,
              animationValue: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  SoundWavePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final waveHeight = size.height;
    final waveWidth = size.width;
    final waveCount = 20;

    for (int i = 0; i < waveCount; i++) {
      final x = (waveWidth / waveCount) * i;
      final y = waveHeight / 2;

      // Ajustement du mouvement de vague pour être plus lent et fluide
      final waveHeightFactor =
          sin((i + animationValue * waveCount) * pi / 3) * 0.4 + 0.6;
      final startY = y - (waveHeight * waveHeightFactor);
      final endY = y + (waveHeight * waveHeightFactor);

      canvas.drawLine(Offset(x, startY), Offset(x, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SoundWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
