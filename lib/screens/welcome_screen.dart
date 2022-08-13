import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/managers/startup_page_manager.dart';
import 'package:share_location/screens/main_screen.dart';
import 'package:share_location/widgets/logo.dart';

class WelcomeScreen extends StatelessWidget {
  static const ID = 'welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              'Quid faciam hodie?',
              textAlign: TextAlign.center,
              style: theme.textTheme.headline1,
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              'What did I do today?',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: LARGE_SPACE),
            Text(
              'Find out what you did all the days and unlock moments you completely forgot!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyText2,
            ),
            const SizedBox(height: LARGE_SPACE),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_right),
              label: const Text('Start'),
              onPressed: () {
                StartupPageManager.navigateToNewPage(context, MainScreen.ID);
              },
            ),
          ],
        ),
      ),
    );
  }
}
