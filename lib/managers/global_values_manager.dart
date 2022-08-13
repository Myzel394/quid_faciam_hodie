import 'package:camera/camera.dart';

class GlobalValuesManager {
  static List<CameraDescription> _cameras = [];

  static List<CameraDescription> get cameras => [..._cameras];

  static void setCameras(List<CameraDescription> cameras) {
    if (_cameras.isNotEmpty) {
      throw Exception('Cameras already set');
    }

    _cameras = cameras;
  }
}
