import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/foreign_types/memory_location.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

class MemoryMaterialMaps extends StatefulWidget {
  final MemoryLocation location;
  final bool lockZoom;
  final double initialZoom;

  const MemoryMaterialMaps({
    Key? key,
    required this.location,
    required this.initialZoom,
    this.lockZoom = false,
  }) : super(key: key);

  @override
  State<MemoryMaterialMaps> createState() => _MemoryMaterialMapsState();
}

class _MemoryMaterialMapsState extends State<MemoryMaterialMaps> {
  late final MapController controller;

  @override
  void initState() {
    super.initState();

    controller = MapController(
      initPosition: GeoPoint(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ),
      initMapWithUserPosition: false,
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  void drawCircle() => controller.drawCircle(
        CircleOSM(
          key: 'accuracy',
          color: Colors.blue,
          centerPoint: GeoPoint(
            latitude: widget.location.latitude,
            longitude: widget.location.longitude,
          ),
          radius: widget.location.accuracy,
          strokeWidth: 4,
        ),
      );

  List<StaticPositionGeoPoint> get staticPoints => [
        StaticPositionGeoPoint(
          'position',
          const MarkerIcon(
            icon: Icon(Icons.location_on, size: 150, color: Colors.blue),
          ),
          [
            GeoPoint(
              latitude: widget.location.latitude,
              longitude: widget.location.longitude,
            )
          ],
        )
      ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return OSMFlutter(
      controller: controller,
      mapIsLoading: Container(
        color: getSheetColor(context),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                width: LARGE_SPACE,
                height: LARGE_SPACE,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: MEDIUM_SPACE),
              Text(
                localizations.generalLoadingLabel,
                style: getBodyTextTextStyle(context),
              ),
            ],
          ),
        ),
      ),
      initZoom: widget.initialZoom,
      maxZoomLevel: widget.lockZoom ? widget.initialZoom : 19,
      minZoomLevel: widget.lockZoom ? widget.initialZoom : 2,
      staticPoints: staticPoints,
      onMapIsReady: (_) {
        drawCircle();
      },
    );
  }
}
