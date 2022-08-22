import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CancelRecordingButton extends StatelessWidget {
  final VoidCallback onCancel;

  const CancelRecordingButton({
    Key? key,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        onCancel();
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
            context.platformIcons.clear,
            size: 25,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
