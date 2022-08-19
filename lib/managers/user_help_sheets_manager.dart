import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quid_faciam_hodie/constants/help_sheet_id.dart';
import 'package:quid_faciam_hodie/constants/storage_keys.dart';

const storage = FlutterSecureStorage();

class UserHelpSheetsManager {
  static String _createKey(final HelpSheetID helpID) =>
      '$USER_HELP_SHEETS_KEY/$helpID';

  static Future<bool> getIfAlreadyShown(final HelpSheetID helpID) async =>
      (await storage.read(key: _createKey(helpID))) == 'true';

  static Future<void> setAsShown(final HelpSheetID helpID) async =>
      storage.write(
        key: _createKey(helpID),
        value: 'true',
      );

  static Future<void> deleteAll() async {
    const keys = HelpSheetID.values;

    for (final key in keys) {
      await storage.delete(key: _createKey(key));
    }
  }
}
