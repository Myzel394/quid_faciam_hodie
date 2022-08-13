import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPhotoShot;
  final VoidCallback onVideoBegin;
  final VoidCallback onVideoEnd;

  const CameraButton({
    Key? key,
    required this.onPhotoShot,
    required this.onVideoBegin,
    required this.onVideoEnd,
    this.active = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.heavyImpact();

        if (active) {
          onVideoEnd();
        } else {
          onPhotoShot();
        }
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();

        if (active) {
          onVideoEnd();
        } else {
          onVideoBegin();
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: active
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
                const Icon(
                  Icons.circle,
                  size: 50,
                  color: Colors.white,
                ),
              ],
      ),
    );
  }
}
