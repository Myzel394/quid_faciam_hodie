import 'package:coast/coast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';

class CrabNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CrabNextButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Crab(
      tag: 'next_button',
      child: PlatformElevatedButton(
        onPressed: onPressed,
        child: IconButtonChild(
          icon: Icon(context.platformIcons.forward),
          label: Text(localizations.generalContinueButtonLabel),
        ),
      ),
    );
  }
}
