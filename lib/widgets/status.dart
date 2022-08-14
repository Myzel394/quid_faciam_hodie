import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/controllers/status_controller.dart';

const BAR_HEIGHT = 4.0;

class Status extends StatefulWidget {
  final StatusController? controller;
  final Widget child;
  final bool paused;
  final bool hideProgressBar;

  const Status({
    Key? key,
    required this.child,
    this.paused = false,
    this.hideProgressBar = false,
    this.controller,
  }) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> with TickerProviderStateMixin {
  late final Animation<double> animation;
  AnimationController? animationController;

  @override
  void didUpdateWidget(covariant Status oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != null && animationController == null) {
      initializeAnimation();
    }

    if (widget.paused) {
      animationController?.stop();
    } else {
      animationController?.forward();
    }
  }

  @override
  void dispose() {
    animationController?.dispose();

    super.dispose();
  }

  void initializeAnimation() {
    animationController = AnimationController(
      duration: widget.controller!.duration,
      vsync: this,
    );
    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController!)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.controller!.setDone();
            }
          });

    animationController!.forward();

    widget.controller!.addListener(() {
      if (widget.controller!.isForwarding) {
        animationController!.forward();
      } else {
        animationController!.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        widget.child,
        Positioned(
          left: 0,
          bottom: SMALL_SPACE,
          width: MediaQuery.of(context).size.width,
          height: BAR_HEIGHT,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.linearToEaseOut,
              opacity: widget.hideProgressBar ? 0.0 : 1.0,
              child: (widget.controller == null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(HUGE_SPACE),
                      child: LinearProgressIndicator(
                        value: null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(.3)),
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: animation,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(HUGE_SPACE),
                        child: LinearProgressIndicator(
                          value: animation.value,
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
