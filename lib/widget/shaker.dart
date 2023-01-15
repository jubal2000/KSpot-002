import 'dart:async';
import 'package:flutter/material.dart';

class Shaker extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final ShakeMode shakeMode;
  final double shakeWidth;
  const Shaker({
    Key? key,
    required this.child,
    required this.duration,
    required this.shakeWidth,
    required this.shakeMode,
  }) : super(key: key);
  _ShakerState createState() => _ShakerState();
}

class _ShakerState extends State<Shaker> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 40), vsync: this);
    animation = Tween(begin: 0.0, end: widget.shakeWidth).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shakeMode == ShakeMode.none)
      controller.stop();
    else {
      controller.repeat(reverse: true);
      if (widget.shakeMode == ShakeMode.once)
        Timer(widget.duration, () => controller.stop());
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        double x = 0;
        if (animation.value != widget.shakeWidth)
          x = animation.value - (widget.shakeWidth / 2);
        return Transform.translate(
          offset: Offset(x, 0),
          child: widget.child,
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

enum ShakeMode {
  always, // 1-1. 멈추지 않음
  once, // 1-2. 일정 시간 이후에 멈춤
  none, // 2.   흔들리지 않음
}
