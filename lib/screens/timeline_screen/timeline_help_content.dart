import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/help_content_text.dart';

class TimelineHelpContent extends StatelessWidget {
  const TimelineHelpContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textColor = getBodyTextColor(context);

    return Column(
      children: <Widget>[
        Text(
          localizations.timelineHelpContentDescription,
          textAlign: TextAlign.center,
          style: getBodyTextTextStyle(context),
        ),
        const SizedBox(height: LARGE_SPACE),
        HelpContentText(
          icon: Icon(
            Icons.touch_app_rounded,
            color: textColor,
          ),
          text: localizations.timelineHelpContentHoldDownExplanation,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        HelpContentText(
          icon: Icon(
            Icons.align_vertical_bottom_sharp,
            color: textColor,
          ),
          text: localizations.timelineHelpContentTapTwiceExplanation,
        ),
      ],
    );
  }
}
