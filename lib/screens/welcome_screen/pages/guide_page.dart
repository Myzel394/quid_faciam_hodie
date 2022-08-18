import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/crabs/next_button.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen/photo_switching.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class GuidePage extends StatelessWidget {
  final String? picture;
  final String description;
  final VoidCallback onNextPage;

  const GuidePage({
    Key? key,
    required this.description,
    required this.onNextPage,
    this.picture,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            picture == null
                ? const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: LARGE_SPACE),
                      child: PhotoSwitching(),
                    ),
                  )
                : SvgPicture.asset(picture!, height: 400),
            const SizedBox(height: LARGE_SPACE),
            Text(
              description,
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
