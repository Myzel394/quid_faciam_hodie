import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';

class PermissionsRequiredPage extends StatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionsRequiredPage({
    Key? key,
    required this.onPermissionsGranted,
  }) : super(key: key);

  @override
  State<PermissionsRequiredPage> createState() =>
      _PermissionsRequiredPageState();
}

class _PermissionsRequiredPageState extends State<PermissionsRequiredPage> {
  bool hasDeniedForever = false;
  bool hasGrantedCameraPermission = false;
  bool hasGrantedMicrophonePermission = false;

  @override
  void initState() {
    super.initState();

    checkPermissions();
  }

  Future<void> checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    setState(() {
      hasGrantedCameraPermission = cameraStatus.isGranted;
      hasGrantedMicrophonePermission = microphoneStatus.isGranted;
    });

    if (cameraStatus.isPermanentlyDenied ||
        microphoneStatus.isPermanentlyDenied) {
      setState(() {
        hasDeniedForever = true;
      });

      return;
    }

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      widget.onPermissionsGranted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          localizations.permissionsRequiredPageTitle,
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        Text(localizations.permissionsRequiredPageDescription),
        const SizedBox(height: LARGE_SPACE),
        if (hasDeniedForever) ...[
          Text(localizations.permissionsRequiredPagePermanentlyDenied),
          const SizedBox(height: LARGE_SPACE),
          TextButton.icon(
            onPressed: () => openAppSettings(),
            icon: const Icon(Icons.settings),
            label: Text(localizations.permissionsRequiredPageOpenSettings),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: hasGrantedCameraPermission
                ? null
                : () async {
                    await Permission.camera.request();
                    await checkPermissions();
                  },
            icon: const Icon(Icons.camera_alt),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  localizations.permissionsRequiredPageGrantCameraPermission,
                ),
                if (hasGrantedCameraPermission) const Icon(Icons.check),
                if (!hasGrantedCameraPermission) const SizedBox(),
              ],
            ),
          ),
          const SizedBox(height: MEDIUM_SPACE),
          TextButton.icon(
            onPressed: hasGrantedMicrophonePermission
                ? null
                : () async {
                    await Permission.microphone.request();
                    await checkPermissions();
                  },
            icon: const Icon(Icons.mic),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  localizations
                      .permissionsRequiredPageGrantMicrophonePermission,
                ),
                if (hasGrantedMicrophonePermission) const Icon(Icons.check),
                if (!hasGrantedMicrophonePermission) const SizedBox(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
