import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/screens/settings_screen.dart';

class SettingsButtonOverlay extends StatelessWidget {
  const SettingsButtonOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: SMALL_SPACE,
      top: SMALL_SPACE,
      child: IconButton(
        icon: Icon(context.platformIcons.settings),
        onPressed: () {
          Navigator.pushNamed(context, SettingsScreen.ID);
        },
      ),
    );
  }
}
