import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:quid_faciam_hodie/widgets/logo.dart';

import 'grant_permission_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const ID = '/';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      body: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Logo(),
              const SizedBox(height: LARGE_SPACE),
              Text(
                localizations.appTitleQuestion,
                textAlign: TextAlign.center,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.headline1,
                  cupertino: (data) => data.textTheme.navLargeTitleTextStyle,
                ),
              ),
              const SizedBox(height: SMALL_SPACE),
              Text(
                localizations.welcomeScreenSubtitle,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodySmall,
                  cupertino: (data) => data.textTheme.navTitleTextStyle,
                ),
              ),
              const SizedBox(height: LARGE_SPACE),
              Text(
                localizations.welcomeScreenDescription,
                textAlign: TextAlign.center,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyText1,
                  cupertino: (data) => data.textTheme.textStyle,
                ),
              ),
              const SizedBox(height: LARGE_SPACE),
              PlatformElevatedButton(
                child: IconButtonChild(
                  icon: Icon(context.platformIcons.forward),
                  label: Text(localizations.welcomeScreenStartButtonTitle),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    GrantPermissionScreen.ID,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
