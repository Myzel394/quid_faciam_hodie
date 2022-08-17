import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';

class RecordingOverlay extends StatefulWidget {
  final CameraController controller;

  const RecordingOverlay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<RecordingOverlay> createState() => _RecordingOverlayState();
}

class _RecordingOverlayState extends State<RecordingOverlay> {
  late final Timer _timer;
  bool animateIn = false;
  bool initialAnimateIn = false;
  int recordingTime = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (!mounted) {
          return;
        }

        recordingTime++;

        animateIn = !animateIn;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialAnimateIn = true;
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  String getFormattedTime() {
    final minutes = recordingTime ~/ 60;
    final seconds = recordingTime % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Positioned(
      left: 0,
      top: SMALL_SPACE,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: initialAnimateIn ? 1.0 : 0.0,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedOpacity(
                curve: Curves.linear,
                opacity: animateIn ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: Icon(
                  Icons.circle,
                  size: platformThemeData(
                    context,
                    material: (data) => data.textTheme.subtitle1!.fontSize,
                    cupertino: (data) => data.textTheme.textStyle.fontSize,
                  ),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: SMALL_SPACE),
              Text(
                localizations.recordingOverlayIsRecording,
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyLarge,
                  cupertino: (data) => data.textTheme.textStyle,
                ),
              ),
              const SizedBox(width: SMALL_SPACE),
              Text(
                getFormattedTime(),
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyLarge,
                  cupertino: (data) => data.textTheme.textStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
