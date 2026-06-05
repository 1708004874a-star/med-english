import 'dart:math';
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    this.onTap,
    this.resetKey,
  });

  final Widget front;
  final Widget back;
  final VoidCallback? onTap;
  /// Change this to trigger a reset to front side
  final Object? resetKey;

  @override
  State<FlipCard> createState() => FlipCardState();
}

class FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showingFront = true;

  bool get isFlipped => !_showingFront;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to front when the card content changes (next card)
    if (widget.resetKey != oldWidget.resetKey) {
      _ctrl.value = 0;
      _showingFront = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void flip() {
    if (_ctrl.isAnimating) return;
    if (_showingFront) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
    setState(() => _showingFront = !_showingFront);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          final angle = _anim.value * pi;
          final showFront = angle < pi / 2;

          // The back is pre-mirrored by rotateY(pi). Both faces share the same
          // outer rotateY(angle), so at the end of the flip (angle == pi) the
          // outer rotation and the pre-mirror cancel out, leaving readable text.
          final Widget child = showFront
              ? widget.front
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: widget.back,
                );

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: child,
          );
        },
      ),
    );
  }
}
