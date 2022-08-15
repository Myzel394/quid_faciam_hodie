import 'package:flutter/material.dart';
import 'package:share_location/screens/main_screen.dart';

import 'main_screen/permissions_required_page.dart';

class GrantPermissionScreen extends StatelessWidget {
  static const ID = 'grant_permission';

  const GrantPermissionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grant Permission'),
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
