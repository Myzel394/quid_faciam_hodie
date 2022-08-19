import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
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
        HelpContentText(
          icon: Icon(
            context.platformIcons.time,
            color: textColor,
          ),
          text:
              localizations.timelineHelpContentChronologicalMemoriesExplanation,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        HelpContentText(
          icon: Icon(
            Icons.swipe_rounded,
            color: textColor,
          ),
          text: localizations.timelineHelpContentSwipeLeftRightExplanation,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        HelpContentText(
          icon: Icon(
            Icons.swipe_vertical_rounded,
            color: textColor,
          ),
          text: localizations.timelineHelpContentSwipeUpDownExplanation,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        HelpContentText(
          icon: Icon(
            context.platformIcons.forward,
            color: textColor,
          ),
          text: localizations.timelineHelpContentAutomaticJumpExplanation,
        ),
        const SizedBox(height: MEDIUM_SPACE),
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
