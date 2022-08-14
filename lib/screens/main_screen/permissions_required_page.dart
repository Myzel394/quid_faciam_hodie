import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_location/constants/spacing.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          'Permissions Required',
          style: Theme.of(context).textTheme.headline1,
        ),
        const SizedBox(height: MEDIUM_SPACE),
        const Text(
          'Please grant the following permissions to use this app',
        ),
        const SizedBox(height: LARGE_SPACE),
        if (hasDeniedForever) ...[
          const Text(
            'You have permanently denied permissions required to use this app. Please enable them in the settings.',
          ),
          const SizedBox(height: LARGE_SPACE),
          TextButton.icon(
            onPressed: () => openAppSettings(),
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
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
            label: Text(
              'Grant camera permission${hasGrantedCameraPermission ? ' - Granted!' : ''}',
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
            label: Text(
              'Grant microphone permission ${hasGrantedMicrophonePermission ? ' - Granted!' : ''}',
            ),
          ),
        ],
      ],
    );
  }
}
