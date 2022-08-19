import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

import '../widgets/icon_button_child.dart';

class EmptyScreen extends StatelessWidget {
  static const ID = '/empty';

  const EmptyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Lottie.asset('assets/lottie/flying-astronaut.json'),
            const SizedBox(height: LARGE_SPACE),
            Padding(
              padding: const EdgeInsets.all(MEDIUM_SPACE),
              child: Column(
                children: <Widget>[
                  Text(
                    localizations.emptyScreenTitle,
                    textAlign: TextAlign.center,
                    style: getTitleTextStyle(context),
                  ),
                  const SizedBox(height: MEDIUM_SPACE),
                  Text(
                    localizations.emptyScreenSubtitle,
                    textAlign: TextAlign.center,
                    style: getSubTitleTextStyle(context),
                  ),
                  const SizedBox(height: SMALL_SPACE),
                  Text(
                    textAlign: TextAlign.center,
                    localizations.emptyScreenDescription,
                    style: getBodyTextTextStyle(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            PlatformElevatedButton(
              child: IconButtonChild(
                icon: Icon(context.platformIcons.back),
                label: Text(localizations.emptyScreenCreateMemory),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
