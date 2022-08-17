import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangeCameraButton extends StatelessWidget {
  final VoidCallback onChangeCamera;
  final bool disabled;

  const ChangeCameraButton({
    Key? key,
    required this.onChangeCamera,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      enableFeedback: false,
      highlightColor: Colors.transparent,
      onTap: () {
        if (disabled) {
          return;
        }

        HapticFeedback.heavyImpact();
        onChangeCamera();
      },
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.circle,
              size: 60,
              color: Colors.white.withOpacity(.2),
            ),
            const Icon(
              Icons.camera_alt,
              size: 30,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
