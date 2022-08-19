import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/crabs/next_button.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class CreateMemoriesPage extends StatelessWidget {
  final VoidCallback onNextPage;

  const CreateMemoriesPage({
    Key? key,
    required this.onNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset('assets/images/live_photo.svg', height: 400),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.welcomeScreenCreateMemoriesGuideDescription,
              style: getBodyTextTextStyle(context),
            ),
            const SizedBox(height: LARGE_SPACE),
            CrabNextButton(onPressed: onNextPage),
          ],
        ),
      ),
    );
  }
}
