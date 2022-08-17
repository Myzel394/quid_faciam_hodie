import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class IconButtonChild extends StatelessWidget {
  final Widget label;
  final Widget icon;

  const IconButtonChild({
    Key? key,
    required this.label,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double scale = MediaQuery.maybeOf(context)?.textScaleFactor ?? 1;
    final double gap = scale <= 1 ? 8 : lerpDouble(8, 4, min(scale - 1, 1))!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        icon,
        SizedBox(width: gap),
        Flexible(child: label),
      ],
    );
  }
}
