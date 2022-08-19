import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/screens/login_screen.dart';
import 'package:quid_faciam_hodie/screens/server_loading_screen.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/crabs/logo.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const CrabLogo(),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.appTitleQuestion,
              style: getTitleTextStyle(context),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Text(
              localizations.welcomeScreenGetStartedLabel,
              style: getSubTitleTextStyle(context),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            PlatformElevatedButton(
              child: IconButtonChild(
                icon: Icon(context.platformIcons.forward),
                label: Text(localizations.welcomeScreenStartButtonTitle),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ServerLoadingScreen(
                      nextScreen: LoginScreen.ID,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
