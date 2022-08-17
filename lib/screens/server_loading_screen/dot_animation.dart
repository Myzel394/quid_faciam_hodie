import 'dart:async';

import 'package:flutter/material.dart';

class DotAnimation extends StatefulWidget {
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Duration fadeInDelay;
  final Duration fadeOutDelay;
  final Duration? initialFadeInDelay;
  final Curve curve;

  const DotAnimation({
    Key? key,
    this.fadeInDuration = const Duration(seconds: 2),
    this.fadeOutDuration = const Duration(seconds: 2),
    this.curve = Curves.easeOut,
    this.fadeInDelay = const Duration(seconds: 1),
    this.fadeOutDelay = const Duration(seconds: 1),
    this.initialFadeInDelay,
  }) : super(key: key);

  @override
  State<DotAnimation> createState() => _DotAnimationState();
}

class _DotAnimationState extends State<DotAnimation> {
  Timer? _timer;
  bool animateIn = false;

  Duration get initialFadeInDelay =>
      widget.initialFadeInDelay ?? widget.fadeInDelay;

  @override
  void initState() {
    super.initState();

    _timer = Timer(initialFadeInDelay, () {
      setState(() {
        animateIn = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: animateIn ? widget.fadeInDuration : widget.fadeOutDuration,
      scale: animateIn ? 1 : .4,
      curve: widget.curve,
      onEnd: () {
        if (animateIn) {
          // Animate out
          _timer = Timer(widget.fadeOutDelay, () {
            if (!mounted) {
              return;
            }

            setState(() {
              animateIn = false;
            });
          });
        } else {
          // Animate in
          _timer = Timer(widget.fadeInDelay, () {
            if (!mounted) {
              return;
            }

            setState(() {
              animateIn = true;
            });
          });
        }
      },
      child: AnimatedOpacity(
        opacity: animateIn ? 1 : .4,
        duration: animateIn ? widget.fadeInDuration : widget.fadeOutDuration,
        curve: widget.curve,
        child: const Icon(
          Icons.circle,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
