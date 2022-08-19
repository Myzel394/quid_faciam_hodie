import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/foreign_types/memory_location.dart';
import 'package:quid_faciam_hodie/screens/memory_map_screen.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';

class MemoryLocationView extends StatefulWidget {
  final MemoryLocation location;

  const MemoryLocationView({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  State<MemoryLocationView> createState() => _MemoryLocationViewState();
}

class _MemoryLocationViewState extends State<MemoryLocationView> {
  late final MapController controller;

  @override
  void initState() {
    super.initState();

    controller = MapController(
      initPosition: GeoPoint(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ),
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

  List<StaticPositionGeoPoint> get staticPoints {
    if (widget.location.accuracy <= ACCURACY_IN_METERS_FOR_PINPOINT) {
      return [
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
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: 400,
          child: GestureDetector(
            // Avoid panning, map is view-only
            onDoubleTap: () {},
            child: OSMFlutter(
              controller: controller,
              initZoom: 14,
              minZoomLevel: 14,
              maxZoomLevel: 14,
              staticPoints: staticPoints,
              onMapIsReady: (_) {
                drawCircle();
              },
            ),
          ),
        ),
        const SizedBox(height: MEDIUM_SPACE),
        PlatformTextButton(
          child: IconButtonChild(
            icon: Icon(context.platformIcons.fullscreen),
            label: Text(localizations.memorySheetViewMoreDetails),
          ),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemoryMapScreen(
                  location: widget.location,
                ),
              ),
            );

            if (!mounted) {
              return;
            }

            Navigator.pop(context);
          },
        ),
        const SizedBox(height: MEDIUM_SPACE),
      ],
    );
  }
}
