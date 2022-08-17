import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quid_faciam_hodie/screens/main_screen.dart';

import 'main_screen/permissions_required_page.dart';

class GrantPermissionScreen extends StatelessWidget {
  static const ID = 'grant_permission';

  const GrantPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.grantPermissionScreenTitle),
      ),
      body: Center(
        child: PermissionsRequiredPage(
          onPermissionsGranted: () {
            Navigator.pushReplacementNamed(context, MainScreen.ID);
          },
        ),
      ),
    );
  }
}
