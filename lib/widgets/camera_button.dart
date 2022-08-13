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

class _CameraButtonState extends State<CameraButton> {
  bool shrinkIcon = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.disabled) {
          return;
        }

        setState(() {
          shrinkIcon = false;
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
          shrinkIcon = true;
        });
      },
      onLongPressUp: () {
        if (widget.disabled) {
          return;
        }

        setState(() {
          shrinkIcon = false;
        });

        if (widget.active) {
          widget.onVideoEnd();
        }
      },
      onLongPress: () {
        if (widget.disabled) {
          return;
        }

        HapticFeedback.heavyImpact();

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
          children: widget.active
              ? const <Widget>[
                  Icon(
                    Icons.circle,
                    size: 75,
                    color: Colors.white,
                  ),
                  Icon(
                    Icons.circle,
                    size: 65,
                    color: Colors.red,
                  ),
                  Icon(
                    Icons.stop,
                    size: 45,
                    color: Colors.white,
                  ),
                ]
              : <Widget>[
                  Icon(
                    Icons.circle,
                    size: 75,
                    color: Colors.white.withOpacity(.2),
                  ),
                  AnimatedScale(
                    duration: kLongPressTimeout,
                    curve: Curves.easeInOut,
                    scale: shrinkIcon ? .8 : 1,
                    child: const Icon(
                      Icons.circle,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}
