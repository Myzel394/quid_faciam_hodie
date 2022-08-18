import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/crabs/logo.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/crabs/next_button.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class InitialPage extends StatefulWidget {
  final VoidCallback onNextPage;

  const InitialPage({
    Key? key,
    required this.onNextPage,
  }) : super(key: key);

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  late String photoURL;

  @override
  void initState() {
    super.initState();
  }

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
            const SizedBox(height: HUGE_SPACE),
            Text(
              localizations.appTitleQuestion,
              style: getTitleTextStyle(context),
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              localizations.welcomeScreenSubtitle,
              style: getSubTitleTextStyle(context),
            ),
            const SizedBox(height: MEDIUM_SPACE),
            Text(
              localizations.welcomeScreenDescription,
              style: getBodyTextTextStyle(context),
            ),
            const SizedBox(height: LARGE_SPACE),
            CrabNextButton(
              onPressed: widget.onNextPage,
            )
          ],
        ),
      ),
    );
  }
}
