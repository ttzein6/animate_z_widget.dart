import 'dart:math';

import 'package:flutter/material.dart';

enum AnimationType { rotate, flip, scale }

class AnimationSpec {
  final Curve curve;
  final Duration duration;
  final Tween<dynamic> tween;

  const AnimationSpec({
    this.curve = Curves.easeInOut,
    required this.duration,
    required this.tween,
  });
}

class AnimateZWidget extends StatefulWidget {
  final Widget child;
  final bool animate;
  final AnimationSpec? customAnimation;
  final AnimationType animationType;
  const AnimateZWidget({
    super.key,
    required this.child,
    required this.animate,
    this.animationType = AnimationType.rotate,
    this.customAnimation,
  });

  @override
  State<AnimateZWidget> createState() => _AnimateZWidgetState();
}

class _AnimateZWidgetState extends State<AnimateZWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        animationBehavior: AnimationBehavior.preserve,
        vsync: this,
        duration:
            widget.customAnimation?.duration ?? const Duration(seconds: 2),
      );
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    if (widget.animate) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return widget.child;
    }
    final Animation animation = (widget.customAnimation?.tween ??
            Tween<double>(
                begin: 0.0,
                end: widget.animationType == AnimationType.rotate ? 10.0 : 1.0))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: (widget.customAnimation?.curve ?? Curves.easeInOut)));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        if (value is double) {
          switch (widget.animationType) {
            case AnimationType.rotate:
              return Transform.rotate(
                angle: value * 2 * pi,
                child: child,
              );
            case AnimationType.flip:
              return Transform.flip(
                flipX: value > 0.5,
                child: child,
              );
            case AnimationType.scale:
              return Transform.scale(
                scale: value,
                child: child,
              );
          }
        } else {
          return child ?? const SizedBox();
        }
      },
      child: widget.child,
    );
  }
}
