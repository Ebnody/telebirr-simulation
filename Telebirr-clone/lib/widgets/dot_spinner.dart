import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A transparent rotating-dot spinner that mimics the look of the green
/// loading GIF without baking in a white background.
///
/// Renders [dotCount] circles equally spaced on a ring; the dot whose
/// position currently matches the animation phase is drawn in
/// [activeDotColor], while the others use [dotColor] with a smooth
/// falloff so neighbouring dots are slightly tinted.
class DotSpinner extends StatefulWidget {
  const DotSpinner({
    super.key,
    this.size = 80,
    this.dotCount = 8,
    this.dotColor = const Color(0xFFAED581),
    this.activeDotColor = const Color(0xFF558B2F),
    this.duration = const Duration(milliseconds: 900),
  });

  final double size;
  final int dotCount;
  final Color dotColor;
  final Color activeDotColor;
  final Duration duration;

  @override
  State<DotSpinner> createState() => _DotSpinnerState();
}

class _DotSpinnerState extends State<DotSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dotDiameter = widget.size * 0.2;
    final double radius = widget.size / 2 - dotDiameter / 2;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final double phase = _controller.value;
          return Stack(
            alignment: Alignment.center,
            children: List.generate(widget.dotCount, (i) {
              final double dotPhase = i / widget.dotCount;
              double distance = (phase - dotPhase).abs();
              if (distance > 0.5) distance = 1 - distance;
              final double t =
                  (1 - distance * widget.dotCount).clamp(0.0, 1.0);
              final Color color =
                  Color.lerp(widget.dotColor, widget.activeDotColor, t)!;

              final double angle =
                  (i / widget.dotCount) * 2 * math.pi - math.pi / 2;
              final double dx = math.cos(angle) * radius;
              final double dy = math.sin(angle) * radius;

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Container(
                  width: dotDiameter,
                  height: dotDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
