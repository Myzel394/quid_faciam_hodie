import 'package:coast/coast.dart';
import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/widgets/logo.dart';

class CrabLogo extends StatelessWidget {
  const CrabLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Crab(
      tag: 'logo',
      child: Logo(),
    );
  }
}
