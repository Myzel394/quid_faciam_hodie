import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/user_help_sheets_manager.dart';

import 'welcome_screen/pages/get_started_page.dart';
import 'welcome_screen/pages/guide_page.dart';
import 'welcome_screen/pages/initial_page.dart';

class WelcomeScreen extends StatefulWidget {
  static const ID = '/welcome';

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final controller = PageController();

  @override
  void initState() {
    super.initState();

    UserHelpSheetsManager.deleteAll();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void nextPage() {
    controller.animateToPage(
      (controller.page! + 1).toInt(),
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PlatformScaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
        child: Center(
          child: PageView(
            controller: controller,
            children: <Widget>[
              InitialPage(
                onNextPage: nextPage,
              ),
              GuidePage(
                onNextPage: nextPage,
                description:
                    localizations.welcomeScreenCreateMemoriesGuideDescription,
                picture: 'assets/images/live_photo.svg',
              ),
              GuidePage(
                onNextPage: nextPage,
                description:
                    localizations.welcomeScreenViewMemoriesGuideDescription,
              ),
              const GetStartedPage(),
            ],
          ),
        ),
      ),
    );
  }
}
