import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/foreign_types/memory_location.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/utils/lookup_address.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:quid_faciam_hodie/widgets/key_value_info.dart';
import 'package:quid_faciam_hodie/widgets/sheet_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class MemoryMapScreen extends StatefulWidget {
  final MemoryLocation location;

  const MemoryMapScreen({
    Key? key,
    required this.location,
  }) : super(key: key);

  @override
  State<MemoryMapScreen> createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends State<MemoryMapScreen> with Loadable {
  late final MapController controller;
  String? address;

  @override
  void initState() {
    super.initState();

    callWithLoading(fetchAddress);

    controller = MapController(
      initPosition: GeoPoint(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ),
    );
  }

  Future<void> fetchAddress() async {
    try {
      final foundAddress = await lookupAddress(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      );

      setState(() {
        address = foundAddress;
      });
    } catch (error) {
      setState(() {
        address = null;
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
    final backgroundColor = getSheetColor(context);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(localizations.memoryMapScreenTitle),
      ),
      body: ExpandableBottomSheet(
        enableToggle: true,
        background: OSMFlutter(
          controller: controller,
          initZoom: 13,
          stepZoom: 1.0,
          trackMyPosition: true,
          staticPoints: staticPoints,
          onMapIsReady: (_) {
            drawCircle();
          },
        ),
        persistentHeader: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SMALL_SPACE),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(LARGE_SPACE),
              topRight: Radius.circular(LARGE_SPACE),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(MEDIUM_SPACE),
            child: Column(
              children: <Widget>[
                const SheetIndicator(),
                const SizedBox(height: MEDIUM_SPACE),
                Text(
                  localizations.memoryMapScreenExpandForMoreDescription,
                  style: getBodyTextTextStyle(context),
                ),
              ],
            ),
          ),
        ),
        expandableContent: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(MEDIUM_SPACE),
          child: Column(
            children: <Widget>[
              KeyValueInfo(
                title: localizations.memoryMapScreenValuesAddressLabel,
                value: () {
                  if (isLoading) {
                    return localizations.memoryMapScreenValuesAddressIsLoading;
                  }

                  if (address == null) {
                    return localizations
                        .memoryMapScreenValuesAddressIsUnavailable;
                  }

                  return address!;
                }(),
              ),
              const SizedBox(height: SMALL_SPACE),
              PlatformTextButton(
                onPressed: () {
                  final url =
                      'geo:0,0?q=${widget.location.latitude},${widget.location.longitude} (${address ?? ''})';
                  launchUrl(Uri.parse(url));
                },
                child: IconButtonChild(
                  icon: Icon(context.platformIcons.location),
                  label: Text(localizations.memoryMapScreenOpenNavigation),
                ),
              ),
              const SizedBox(height: SMALL_SPACE),
              KeyValueInfo(
                title: localizations.memoryMapScreenValuesLatitudeLabel,
                value: widget.location.latitude.toString(),
              ),
              KeyValueInfo(
                title: localizations.memoryMapScreenValuesLongitudeLabel,
                value: widget.location.longitude.toString(),
              ),
              KeyValueInfo(
                title: localizations.memoryMapScreenValuesAccuracyLabel,
                value: localizations.memoryMapScreenValuesAccuracyValue(
                  widget.location.accuracy.toString(),
                ),
                icon: Icons.circle,
              ),
              KeyValueInfo(
                title: localizations.memoryMapScreenValuesSpeedLabel,
                value: localizations.memoryMapScreenValuesSpeedValue(
                  widget.location.speed.toString(),
                ),
                icon: Icons.speed_rounded,
              ),
              KeyValueInfo(
                title: localizations.memoryMapScreenValuesAltitudeLabel,
                value: localizations.memoryMapScreenValuesAltitudeValue(
                  widget.location.altitude.toString(),
                ),
                icon: Icons.landscape_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
