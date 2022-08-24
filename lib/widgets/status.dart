import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/controllers/status_controller.dart';
import 'package:quid_faciam_hodie/native_events/window_focus.dart';

const BAR_HEIGHT = 4.0;

class Status extends StatefulWidget {
  final StatusController? controller;
  final Widget child;
  final bool paused;
  final bool hideProgressBar;
  final bool autoStart;
  final bool isIndeterminate;
  final bool pauseOnLostFocus;
  final VoidCallback? onEnd;
  final Duration duration;

  const Status({
    Key? key,
    required this.child,
    this.paused = false,
    this.hideProgressBar = false,
    this.autoStart = false,
    this.isIndeterminate = false,
    this.pauseOnLostFocus = true,
    this.duration = const Duration(seconds: 5),
    this.onEnd,
    this.controller,
  }) : super(key: key);

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> with TickerProviderStateMixin {
  bool _wasAnimatingBeforeLostFocus = false;

  Animation<double>? animation;
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

  @override
  void initState() {
    super.initState();

    EventChannelWindowFocus.setGlobalListener((hasFocus) {
      if (!widget.pauseOnLostFocus) {
        return;
      }

      if (hasFocus && _wasAnimatingBeforeLostFocus) {
        animationController?.forward();
      } else if (!hasFocus) {
        _wasAnimatingBeforeLostFocus =
            animationController?.isAnimating ?? false;
        animationController?.stop();
      }
    });

    if (widget.autoStart) {
      initializeAnimation();
    }
  }

  void initializeAnimation() {
    animationController = AnimationController(
      duration: widget.controller?.duration ?? widget.duration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onEnd?.call();
        }
      });

    animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(animationController!)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.controller?.setDone();
            }
          });

    animationController!.forward();

    if (widget.controller != null) {
      widget.controller!.addListener(() {
        if (widget.controller!.isForwarding) {
          animationController!.forward();
        } else {
          animationController!.stop();
        }
      });
    }

    if (widget.autoStart) {
      animationController?.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          widget.child,
          Positioned(
            left: 0,
            right: 0,
            bottom: SMALL_SPACE,
            height: BAR_HEIGHT,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linearToEaseOut,
                opacity: widget.hideProgressBar ? 0.0 : 1.0,
                child: (widget.isIndeterminate || animation == null)
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
                        animation: animation!,
                        builder: (_, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(HUGE_SPACE),
                          child: LinearProgressIndicator(
                            value: animation!.value,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            backgroundColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
