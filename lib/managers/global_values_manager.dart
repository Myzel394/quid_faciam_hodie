import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quid_faciam_hodie/constants/apis.dart';
import 'package:quid_faciam_hodie/models/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalValuesManager {
  static Future? _serverInitializationFuture;
  static Future? _settingsInitializationFuture;
  static bool _isServerInitialized = false;
  static List<CameraDescription> _cameras = [];
  static Settings? _settings;

  static List<CameraDescription> get cameras => [..._cameras];
  static bool get isServerInitialized => _isServerInitialized;
  static Settings? get settings => _settings;

  static void setCameras(List<CameraDescription> cameras) {
    if (_cameras.isNotEmpty) {
      return;
    }

    _cameras = cameras;
  }

  static void _initializeServer() {
    if (_isServerInitialized || _serverInitializationFuture != null) {
      return;
    }

    _serverInitializationFuture = Supabase.initialize(
      url: SUPABASE_API_URL,
      anonKey: SUPABASE_API_KEY,
      debug: kDebugMode,
    )..then((_) {
        _isServerInitialized = true;
        _serverInitializationFuture = null;
      });
  }

  static void _initializeSettings() {
    _settingsInitializationFuture = Settings.restore()
      ..then((settings) {
        _settings = settings;
        _settingsInitializationFuture = null;
      });
  }

  static void initialize() {
    _initializeServer();
    _initializeSettings();
  }

  static Future<void> watchForInitialization() async {
    // Server initialization
    if (_serverInitializationFuture == null) {
      if (_isServerInitialized) {
        return;
      } else {
        throw Exception('Server has not been initialized yet');
      }
    } else {
      await _serverInitializationFuture;
    }

    // Settings initialization
    if (_settingsInitializationFuture == null) {
      if (_settings == null) {
        throw Exception('Settings have not been initialized yet');
      } else {
        return;
      }
    } else {
      await _settingsInitializationFuture;
    }
  }

  static Future<bool> hasGrantedPermissions() async =>
      (await Permission.camera.isGranted) &&
      (await Permission.microphone.isGranted) &&
      (await Permission.location.isGranted);
}
