import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
    return GestureDetector(
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
            Icon(
              context.platformIcons.switchCamera,
              size: 25,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
