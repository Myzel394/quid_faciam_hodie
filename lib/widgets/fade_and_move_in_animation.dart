import 'package:flutter/material.dart';

const DEFAULT_TRANSLATION_DURATION = Duration(milliseconds: 500);
const DEFAULT_OPACITY_DURATION = Duration(milliseconds: 800);

class FadeAndMoveInAnimation extends StatefulWidget {
  final Widget child;
  final bool active;

  final Offset translationOffset;
  final Duration translationDuration;
  final Curve translationCurve;

  final Duration opacityDuration;
  final Curve opacityCurve;

  const FadeAndMoveInAnimation({
    Key? key,
    required this.child,
    this.active = true,
    this.translationOffset = const Offset(0, 60),
    this.translationDuration = DEFAULT_TRANSLATION_DURATION,
    this.translationCurve = Curves.easeOutQuad,
    this.opacityDuration = DEFAULT_OPACITY_DURATION,
    this.opacityCurve = Curves.linearToEaseOut,
  }) : super(key: key);

  @override
  State<FadeAndMoveInAnimation> createState() => _FadeAndMoveInAnimationState();
}

class _FadeAndMoveInAnimationState extends State<FadeAndMoveInAnimation>
    with TickerProviderStateMixin {
  late final AnimationController translationController;
  late final Animation<double> translationAnimation;

  bool opacityEnabled = false;

  @override
  void initState() {
    super.initState();

    translationController = AnimationController(
      vsync: this,
      duration: widget.translationDuration,
    );
    translationAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: translationController,
        curve: widget.translationCurve,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.active) {
      translationController.forward();
    } else {
      translationController.reverse();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacityEnabled = widget.active;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: translationController,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          widget.translationOffset.dx * translationAnimation.value,
          widget.translationOffset.dy * translationAnimation.value,
        ),
        child: AnimatedOpacity(
          duration: widget.opacityDuration,
          curve: widget.opacityCurve,
          opacity: opacityEnabled ? 1 : 0,
          child: child,
        ),
      ),
    );
  }
}
