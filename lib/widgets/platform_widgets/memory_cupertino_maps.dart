import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/foreign_types/memory_location.dart';

class MemoryCupertinoMaps extends StatefulWidget {
  final MemoryLocation location;
  final bool lockZoom;
  final double initialZoom;

  const MemoryCupertinoMaps({
    Key? key,
    required this.location,
    required this.initialZoom,
    this.lockZoom = false,
  }) : super(key: key);

  @override
  State<MemoryCupertinoMaps> createState() => _MemoryCupertinoMapsState();
}

class _MemoryCupertinoMapsState extends State<MemoryCupertinoMaps> {
  @override
  Widget build(BuildContext context) {
    return AppleMap(
      minMaxZoomPreference: MinMaxZoomPreference(
        widget.lockZoom ? widget.initialZoom : 1,
        widget.lockZoom ? widget.initialZoom : 20,
      ),
      circles: {
        Circle(
          circleId: CircleId('accuracy'),
          center: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          radius: widget.location.accuracy,
          strokeWidth: 1,
          fillColor: Colors.blue.withOpacity(.2),
          strokeColor: Colors.blue,
        ),
      },
      annotations: {
        Annotation(
          annotationId: AnnotationId('position'),
          position: LatLng(
            widget.location.latitude,
            widget.location.longitude,
          ),
          icon: BitmapDescriptor.defaultAnnotation,
        )
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.location.latitude,
          widget.location.longitude,
        ),
        zoom: 14,
      ),
    );
  }
}
