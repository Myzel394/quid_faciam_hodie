import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/widgets/logo.dart';

import 'grant_permission_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const ID = 'welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(MEDIUM_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Logo(),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.appTitleQuestion,
              textAlign: TextAlign.center,
              style: theme.textTheme.headline1,
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              localizations.welcomeScreenSubtitle,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.welcomeScreenDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyText2,
            ),
            const SizedBox(height: LARGE_SPACE),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_right),
              label: Text(localizations.welcomeScreenStartButtonTitle),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  GrantPermissionScreen.ID,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
