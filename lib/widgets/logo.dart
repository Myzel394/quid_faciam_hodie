import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_location/constants/spacing.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomAppBarColor,
        borderRadius: BorderRadius.circular(MEDIUM_SPACE),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(SPACE_MULTIPLIER * 15),
        child: SvgPicture.asset(
          'assets/logo_blank.svg',
          width: 100,
        ),
      ),
    );
  }
}
