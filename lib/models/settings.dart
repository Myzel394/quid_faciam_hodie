import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quid_faciam_hodie/constants/storage_keys.dart';

const secure = FlutterSecureStorage();

class Settings extends ChangeNotifier {
  ResolutionPreset _resolution = ResolutionPreset.max;
  bool _askForMemoryAnnotations = false;

  Settings({
    final ResolutionPreset? resolution,
    final bool? askForMemoryAnnotations,
  })  : _resolution = resolution ?? ResolutionPreset.max,
        _askForMemoryAnnotations = askForMemoryAnnotations ?? true;

  ResolutionPreset get resolution => _resolution;
  bool get askForMemoryAnnotations => _askForMemoryAnnotations;

  Map<String, dynamic> toJSONData() => {
        'resolution': _resolution.toString(),
        'askForMemoryAnnotations': _askForMemoryAnnotations ? 'true' : 'false',
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
    final resolution = ResolutionPreset.values.firstWhereOrNull(
      (preset) => preset.toString() == data['resolution'],
    );
    final askForMemoryAnnotations = () {
      switch (data['askForMemoryAnnotations']) {
        case 'true':
          return true;
        case 'false':
          return false;
        default:
          return null;
      }
    }();

    return Settings(
      resolution: resolution,
      askForMemoryAnnotations: askForMemoryAnnotations,
    );
  }

  void setResolution(final ResolutionPreset value) {
    _resolution = value;
    notifyListeners();
    save();
  }

  void setAskForMemoryAnnotations(final bool askForMemoryAnnotations) {
    _askForMemoryAnnotations = askForMemoryAnnotations;
    notifyListeners();
    save();
  }
}
