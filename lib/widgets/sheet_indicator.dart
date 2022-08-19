import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class SheetIndicator extends StatelessWidget {
  const SheetIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 5,
      decoration: BoxDecoration(
        color: getBodyTextColor(context).withOpacity(.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
