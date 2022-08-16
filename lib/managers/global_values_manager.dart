import 'package:camera/camera.dart';

class GlobalValuesManager {
  static bool _hasBeenInitialized = false;
  static List<CameraDescription> _cameras = [];

  static List<CameraDescription> get cameras => [..._cameras];
  static bool get hasBeenInitialized => _hasBeenInitialized;

  static void setCameras(List<CameraDescription> cameras) {
    if (_cameras.isNotEmpty) {
      return;
    }

    _cameras = cameras;
  }

  static void setHasBeenInitialized(bool hasBeenInitialized) {
    _hasBeenInitialized = hasBeenInitialized;
  }
}
