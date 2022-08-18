import 'dart:io';

import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:location/location.dart';

Future<void> tagLocationToImage(
  final File file,
  final LocationData locationData,
) async {
  final exif = FlutterExif.fromPath(file.absolute.path);

  await exif.setLatLong(locationData.latitude!, locationData.longitude!);
  await exif.setAltitude(locationData.altitude!);
  await exif.setAttribute('accuracy', locationData.accuracy!.toString());
  await exif.setAttribute('speed', locationData.speed!.toString());

  await exif.saveAttributes();
}
