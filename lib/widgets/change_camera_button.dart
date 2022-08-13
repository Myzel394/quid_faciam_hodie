import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangeCameraButton extends StatelessWidget {
  final VoidCallback onChangeCamera;

  const ChangeCameraButton({
    Key? key,
    required this.onChangeCamera,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      enableFeedback: false,
      highlightColor: Colors.transparent,
      onTap: () {
        HapticFeedback.heavyImpact();
        onChangeCamera();
      },
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(
            Icons.circle,
            size: 60,
            color: Colors.white.withOpacity(.2),
          ),
          Icon(
            Icons.camera_alt,
            size: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
