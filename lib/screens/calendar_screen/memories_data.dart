import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class MemoriesData extends StatelessWidget {
  const MemoriesData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memories = context.watch<Memories>();
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              localizations.welcomeScreenMemoriesDataMemoriesAmount(
                memories.memories.length,
              ),
              style: getBodyTextTextStyle(context),
            ),
            const SizedBox(height: SMALL_SPACE),
            Text(
              localizations.welcomeScreenMemoriesDataMemoriesSpanning(
                memories.memories.last.creationDate,
                memories.memories.first.creationDate,
              ),
              style: getBodyTextTextStyle(context),
            ),
          ],
        ),
      ),
    );
  }
}
