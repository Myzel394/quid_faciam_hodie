import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quid_faciam_hodie/constants/storage_keys.dart';
import 'package:quid_faciam_hodie/screens/welcome_screen.dart';

const storage = FlutterSecureStorage();

class StartupPageManager {
  static Future<String> getPage() async =>
      (await storage.read(key: STARTUP_PAGE_KEY)) ?? WelcomeScreen.ID;

  static Future<void> navigateToNewPage(
    BuildContext context,
    String newPageID,
  ) async {
    await storage.write(key: STARTUP_PAGE_KEY, value: newPageID);
    await Navigator.pushReplacementNamed(context, newPageID);
  }
}
