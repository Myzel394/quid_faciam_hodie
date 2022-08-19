import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quid_faciam_hodie/constants/storage_keys.dart';

const secure = FlutterSecureStorage();

class Settings extends ChangeNotifier {
  ResolutionPreset _resolution = ResolutionPreset.max;

  Settings({final ResolutionPreset resolution = ResolutionPreset.max})
      : _resolution = resolution;

  ResolutionPreset get resolution => _resolution;

  Map<String, dynamic> toJSONData() => {
        'resolution': _resolution.toString(),
      };

  Future<void> save() async {
    final data = toJSONData();

    await secure.write(
      key: SETTINGS_KEY,
      value: jsonEncode(data),
    );
  }

  static Future<Settings> restore() async {
    final rawData = await secure.read(key: SETTINGS_KEY);

    if (rawData == null) {
      return Settings();
    }

    final data = jsonDecode(rawData);
    final resolution = ResolutionPreset.values.firstWhere(
      (preset) => preset.toString() == data['resolution'],
    );
    return Settings(
      resolution: resolution,
    );
  }

  void setResolution(final ResolutionPreset value) {
    _resolution = value;
    notifyListeners();
    save();
  }
}
