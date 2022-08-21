import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/modal_sheet.dart';

class HelpSheetForm extends StatefulWidget {
  final String title;
  final Widget helpContent;

  const HelpSheetForm({
    Key? key,
    required this.helpContent,
    required this.title,
  }) : super(key: key);

  @override
  State<HelpSheetForm> createState() => _HelpSheetFormState();
}

class _HelpSheetFormState extends State<HelpSheetForm> {
  bool dontShowSheetAgain = true;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ModalSheet(
      child: Column(
        children: <Widget>[
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: getTitleTextStyle(context),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          widget.helpContent,
          const SizedBox(height: LARGE_SPACE),
          PlatformElevatedButton(
            child: Text(localizations.generalUnderstoodButtonLabel),
            onPressed: () => Navigator.pop(context, dontShowSheetAgain),
          ),
          const SizedBox(height: SMALL_SPACE),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              PlatformSwitch(
                value: dontShowSheetAgain,
                activeColor: platformThemeData(
                  context,
                  material: (data) => data.colorScheme.primary,
                  cupertino: (data) => data.primaryColor,
                ),
                onChanged: (value) {
                  setState(() {
                    dontShowSheetAgain = value;
                  });
                },
              ),
              const SizedBox(width: SMALL_SPACE),
              Text(
                localizations.helpSheetDontShowAgain,
                style: getBodyTextTextStyle(context),
              )
            ],
          ),
        ],
      ),
    );
  }
}
