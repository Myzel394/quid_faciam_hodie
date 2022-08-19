import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/crabs/next_button.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/photo_switching.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class ViewMemoriesPage extends StatelessWidget {
  final VoidCallback onNextPage;
  final NetworkImage? initialImage;

  const ViewMemoriesPage({
    Key? key,
    required this.onNextPage,
    this.initialImage,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: LARGE_SPACE),
                child: PhotoSwitching(initialImage: initialImage),
              ),
            ),
            const SizedBox(height: LARGE_SPACE),
            Text(
              localizations.welcomeScreenViewMemoriesGuideDescription,
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
