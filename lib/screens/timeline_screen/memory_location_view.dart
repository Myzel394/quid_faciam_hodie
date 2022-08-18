import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/foreign_types/memory_location.dart';
import 'package:quid_faciam_hodie/widgets/fade_and_move_in_animation.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:quid_faciam_hodie/widgets/key_value_info.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String address = '';

  @override
  void initState() {
    super.initState();

    lookupAddress();

    controller = MapController(
      initPosition: GeoPoint(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ),
    );
  }

  void lookupAddress() async {
    final url =
        'https://geocode.maps.co/reverse?lat=${widget.location.latitude}&lon=${widget.location.longitude}';
    final uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      setState(() {
        address = '';
      });
    } else {
      setState(() {
        address = jsonDecode(response.body)['display_name'];
      });
    }
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
          child: OSMFlutter(
            controller: controller,
            initZoom: 14,
            stepZoom: 1.0,
            staticPoints: staticPoints,
            onMapIsReady: (_) {
              drawCircle();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
          child: Column(
            children: <Widget>[
              const SizedBox(height: MEDIUM_SPACE),
              if (address.isNotEmpty) ...[
                FadeAndMoveInAnimation(
                  child: KeyValueInfo(
                    title: localizations.memorySheetMapEstimatedAddressLabel,
                    value: address,
                    icon: context.platformIcons.location,
                  ),
                ),
                const SizedBox(height: MEDIUM_SPACE),
              ],
              PlatformTextButton(
                onPressed: () {
                  final url =
                      'geo:0,0?q=${widget.location.latitude},${widget.location.longitude} ($address)';
                  launchUrl(Uri.parse(url));
                },
                child: IconButtonChild(
                  icon: Icon(context.platformIcons.location),
                  label: Text(localizations.memorySheetMapOpenNavigation),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
