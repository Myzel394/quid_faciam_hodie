import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraButton extends StatefulWidget {
  final bool active;
  final VoidCallback onPhotoShot;
  final VoidCallback onVideoBegin;
  final VoidCallback onVideoEnd;
  final bool disabled;

  const CameraButton({
    Key? key,
    required this.onPhotoShot,
    required this.onVideoBegin,
    required this.onVideoEnd,
    this.active = false,
    this.disabled = false,
  }) : super(key: key);

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

const OUT_DURATION = Duration(milliseconds: 300);

class _CameraButtonState extends State<CameraButton> {
  bool animateToVideoIcon = false;
  bool videoInAnimationActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      onLongPressDown: (_) {
        if (widget.disabled) {
          return;
        }

        setState(() {
          animateToVideoIcon = true;
        });
      },
      onLongPressUp: () {
        if (widget.disabled) {
          return;
        }

        setState(() {
          videoInAnimationActive = false;
          animateToVideoIcon = false;
        });

        if (widget.active) {
          widget.onVideoEnd();
        }
      },
      onTapCancel: () {
        setState(() {
          videoInAnimationActive = false;
          animateToVideoIcon = false;
        });
      },
      onPanCancel: () {
        setState(() {
          videoInAnimationActive = false;
          animateToVideoIcon = false;
        });
      },
      onLongPress: () {
        if (widget.disabled) {
          return;
        }

        HapticFeedback.heavyImpact();

        setState(() {
          videoInAnimationActive = true;
        });

        if (widget.active) {
          widget.onVideoEnd();
        } else {
          widget.onVideoBegin();
        }
      },
      child: Opacity(
        opacity: widget.disabled ? 0.5 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.circle,
              size: 75,
              color: Colors.white.withOpacity(.2),
            ),
            AnimatedScale(
              duration: animateToVideoIcon ? kLongPressTimeout : OUT_DURATION,
              curve: Curves.easeInOut,
              scale: animateToVideoIcon ? (75 / 50) : 1,
              child: const Icon(
                Icons.circle,
                size: 50,
                color: Colors.white,
              ),
            ),
            AnimatedScale(
              curve: Curves.easeInOut,
              duration: animateToVideoIcon
                  ? const Duration(milliseconds: 180)
                  : OUT_DURATION,
              scale: videoInAnimationActive ? 1 : 0,
              child: const Icon(
                Icons.circle,
                size: 65,
                color: Colors.red,
              ),
            ),
            AnimatedScale(
              curve: Curves.easeOutCirc,
              duration: animateToVideoIcon
                  ? const Duration(milliseconds: 1000)
                  : OUT_DURATION,
              scale: videoInAnimationActive ? 1 : .6,
              child: const Icon(
                Icons.stop,
                size: 45,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
