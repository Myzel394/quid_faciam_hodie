import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:quid_faciam_hodie/constants/apis.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalValuesManager {
  static Future? _serverInitializationFuture;
  static bool _isServerInitialized = false;
  static List<CameraDescription> _cameras = [];

  static List<CameraDescription> get cameras => [..._cameras];
  static bool get isServerInitialized => _isServerInitialized;

  static void setCameras(List<CameraDescription> cameras) {
    if (_cameras.isNotEmpty) {
      return;
    }

    _cameras = cameras;
  }

  static void initializeServer() {
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

  static Future<void> waitForServerInitialization() async {
    if (_serverInitializationFuture == null) {
      if (_isServerInitialized) {
        return;
      } else {
        throw Exception('Server has not been initialized yet');
      }
    }

    await _serverInitializationFuture;
  }
}
