import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RecordButton extends StatefulWidget {
  final bool active;
  final VoidCallback onPhotoShot;
  final VoidCallback onVideoBegin;
  final VoidCallback onVideoEnd;
  final bool disabled;

  const RecordButton({
    Key? key,
    required this.onPhotoShot,
    required this.onVideoBegin,
    required this.onVideoEnd,
    this.active = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

const OUT_DURATION = Duration(milliseconds: 300);

class _RecordButtonState extends State<RecordButton> {
  bool animateToVideoIcon = false;
  bool videoInAnimationActive = false;

  void cancelAnimation() {
    if (videoInAnimationActive) {
      return;
    }

    setState(() {
      videoInAnimationActive = false;
      animateToVideoIcon = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Take photo
      onTap: () {
        if (widget.disabled) {
          return;
        }

        setState(() {
          videoInAnimationActive = false;
          animateToVideoIcon = false;
        });

        HapticFeedback.heavyImpact();

        if (widget.active) {
          widget.onVideoEnd();
        } else {
          widget.onPhotoShot();
        }
      },
      // Start Video
      onLongPress: () {
        if (widget.disabled) {
          return;
        }

        setState(() {
          animateToVideoIcon = false;
          videoInAnimationActive = true;
        });

        HapticFeedback.heavyImpact();

        if (widget.active) {
          widget.onVideoEnd();
        } else {
          widget.onVideoBegin();
        }
      },
      // Stop Video
      onLongPressUp: () {
        if (widget.disabled) {
          return;
        }

        setState(() {
          videoInAnimationActive = false;
          animateToVideoIcon = false;
        });

        HapticFeedback.lightImpact();

        if (widget.active) {
          widget.onVideoEnd();
        }
      },
      // Animate to video icon
      onTapDown: (_) {
        if (widget.disabled) {
          return;
        }

        setState(() {
          animateToVideoIcon = true;
        });
      },
      // Cancel icon animation
      onTapCancel: cancelAnimation,
      onPanCancel: cancelAnimation,
      onLongPressCancel: cancelAnimation,
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: videoInAnimationActive ? Duration.zero : OUT_DURATION,
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: videoInAnimationActive
                    ? Colors.white
                    : Colors.white.withOpacity(.2),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            AnimatedScale(
              duration: () {
                if (videoInAnimationActive) {
                  return Duration(milliseconds: 400);
                }

                if (animateToVideoIcon) {
                  return kLongPressTimeout;
                }

                return OUT_DURATION;
              }(),
              curve: Curves.easeInOut,
              scale: () {
                if (videoInAnimationActive) {
                  return .6;
                }

                if (animateToVideoIcon) {
                  return 60 / 40;
                }

                return 1.0;
              }(),
              child: AnimatedContainer(
                duration: () {
                  if (videoInAnimationActive) {
                    return Duration(milliseconds: 400);
                  }

                  if (animateToVideoIcon) {
                    return kLongPressTimeout;
                  }

                  return OUT_DURATION;
                }(),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: videoInAnimationActive ? Colors.red : Colors.white,
                  borderRadius: videoInAnimationActive
                      ? BorderRadius.circular(8)
                      : BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
