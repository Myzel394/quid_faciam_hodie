import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/help_content_text.dart';

class CameraHelpContent extends StatelessWidget {
  const CameraHelpContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final iconColor = getBodyTextColor(context).withOpacity(.2);

    return Column(
      children: <Widget>[
        HelpContentText(
          icon: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.circle_rounded,
                color: iconColor,
              ),
              const Icon(
                Icons.circle_rounded,
                color: Colors.white,
                size: 13,
              ),
            ],
          ),
          text: localizations.mainScreenHelpSheetTakePhotoExplanation,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        HelpContentText(
          icon: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.circle_rounded,
                color: iconColor,
              ),
              Icon(
                Icons.circle_rounded,
                color: Colors.white,
                size: 19,
              ),
              Icon(
                Icons.square_rounded,
                color: Colors.red,
                size: 10,
              ),
            ],
          ),
          text: localizations.mainScreenHelpSheetTakeVideoExplanation,
        ),
      ],
    );
  }
}
