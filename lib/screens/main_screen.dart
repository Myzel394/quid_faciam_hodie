import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/file_manager.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:quid_faciam_hodie/utils/auth_required.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/widgets/animate_in_builder.dart';
import 'package:quid_faciam_hodie/widgets/fade_and_move_in_animation.dart';
import 'package:quid_faciam_hodie/widgets/icon_button_child.dart';
import 'package:quid_faciam_hodie/widgets/sheet_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main_screen/change_camera_button.dart';
import 'main_screen/record_button.dart';
import 'main_screen/recording_overlay.dart';
import 'main_screen/today_photo_button.dart';
import 'main_screen/uploading_photo.dart';

class MainScreen extends StatefulWidget {
  static const ID = '/main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends AuthRequiredState<MainScreen> with Loadable {
  int currentZoomLevelIndex = 0;

  bool isRecording = false;
  bool lockCamera = false;
  bool isTorchEnabled = false;
  Uint8List? uploadingPhotoAnimation;
  List<double>? zoomLevels;

  late User _user;

  CameraController? controller;

  static String formatZoomLevel(double zoomLevel) {
    if (zoomLevel.floor() == zoomLevel) {
      // Zoom level is a whole number
      return '${zoomLevel.floor()}x';
    } else {
      return '${zoomLevel.toStringAsFixed(1)}x';
    }
  }

  double get currentZoomLevel => zoomLevels![currentZoomLevelIndex];

  @override
  bool get isLoading =>
      super.isLoading || controller == null || !controller!.value.isInitialized;

  @override
  void initState() {
    super.initState();

    loadCameras();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _updateCamera(state);
  }

  Future<void> loadCameras() async {
    GlobalValuesManager.setCameras(await availableCameras());

    onNewCameraSelected(GlobalValuesManager.cameras[0]);
  }

  void _updateCamera(final AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void onAuthenticated(Session session) {
    final user = session.user;

    if (user != null) {
      _user = user;
    }
  }

  void onNewCameraSelected(final CameraDescription cameraDescription) async {
    final previousCameraController = controller;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    cameraController.setFlashMode(FlashMode.off);

    await previousCameraController?.dispose();

    if (!mounted) {
      return;
    }

    controller = cameraController;

    // Update UI if controller updates
    controller!.addListener(() {
      if (mounted) setState(() {});
    });

    await controller!.initialize();
    await controller!.prepareForVideoRecording();

    await determineZoomLevels();

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> determineZoomLevels() async {
    final minZoomLevel = await controller!.getMinZoomLevel();
    final maxZoomLevel = await controller!.getMaxZoomLevel();

    final availableZoomLevels = ([...DEFAULT_ZOOM_LEVELS]
            .where((zoomLevel) =>
                zoomLevel >= minZoomLevel && zoomLevel <= maxZoomLevel)
            .toSet()
          ..add(minZoomLevel)
          ..add(maxZoomLevel))
        .toList()
      ..sort();

    setState(() {
      zoomLevels = availableZoomLevels;
    });
  }

  Future<void> takePhoto() async {
    final localizations = AppLocalizations.of(context)!;

    if (controller!.value.isTakingPicture) {
      return;
    }

    setState(() {
      lockCamera = true;
    });

    try {
      if (isMaterial(context))
        context.showPendingSnackBar(
          message: localizations.mainScreenTakePhotoActionTakingPhoto,
        );

      if (isTorchEnabled) {
        await controller!.setFlashMode(FlashMode.torch);
      } else {
        await controller!.setFlashMode(FlashMode.off);
      }

      final file = File((await controller!.takePicture()).path);

      setState(() {
        uploadingPhotoAnimation = file.readAsBytesSync();
      });

      if (isMaterial(context))
        context.showPendingSnackBar(
          message: localizations.mainScreenTakePhotoActionUploadingPhoto,
        );

      try {
        await FileManager.uploadFile(_user, file);
      } catch (error) {
        if (isMaterial(context))
          context.showErrorSnackBar(message: error.toString());
        return;
      }

      if (isMaterial(context))
        context.showSuccessSnackBar(
          message: localizations.mainScreenUploadSuccess,
        );
    } finally {
      setState(() {
        lockCamera = false;
        uploadingPhotoAnimation = null;
      });
    }
  }

  Future<void> takeVideo() async {
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      isRecording = false;
    });

    if (!controller!.value.isRecordingVideo) {
      // Recording has already been stopped
      return;
    }

    setState(() {
      lockCamera = true;
    });

    try {
      if (isMaterial(context))
        context.showPendingSnackBar(
          message: localizations.mainScreenTakeVideoActionSaveVideo,
        );

      final file = File((await controller!.stopVideoRecording()).path);

      if (isMaterial(context))
        context.showPendingSnackBar(
          message: localizations.mainScreenTakeVideoActionUploadingVideo,
        );

      try {
        await FileManager.uploadFile(_user, file);
      } catch (error) {
        if (isMaterial(context)) {
          context.showErrorSnackBar(message: error.toString());
        }
        return;
      }

      if (isMaterial(context))
        context.showSuccessSnackBar(
          message: localizations.mainScreenUploadSuccess,
        );
    } finally {
      setState(() {
        lockCamera = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        SystemNavigator.pop();
        exit(0);
      },
      child: PlatformScaffold(
        backgroundColor: Colors.black,
        body: () {
          if (isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PlatformCircularProgressIndicator(),
                  const SizedBox(height: MEDIUM_SPACE),
                  Text(
                    localizations.mainScreenLoadingCamera,
                    style: platformThemeData(
                      context,
                      material: (data) => data.textTheme.bodyText1,
                      cupertino: (data) => data.textTheme.textStyle,
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            color: Colors.black,
            child: ExpandableBottomSheet(
              background: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AnimateInBuilder(
                    builder: (showPreview) => AnimatedOpacity(
                      opacity: showPreview ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1100),
                      curve: Curves.easeOutQuad,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(SMALL_SPACE),
                        child: AspectRatio(
                          aspectRatio: 1 / controller!.value.aspectRatio,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              controller!.buildPreview(),
                              if (isRecording)
                                RecordingOverlay(controller: controller!),
                              if (uploadingPhotoAnimation != null)
                                UploadingPhoto(
                                  data: uploadingPhotoAnimation!,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              persistentHeader: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(LARGE_SPACE),
                    topRight: Radius.circular(LARGE_SPACE),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: MEDIUM_SPACE,
                        horizontal: MEDIUM_SPACE,
                      ),
                      child: SheetIndicator(),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: SMALL_SPACE),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Expanded(
                            child: FadeAndMoveInAnimation(
                              translationDuration:
                                  DEFAULT_TRANSLATION_DURATION *
                                      SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                              opacityDuration: DEFAULT_OPACITY_DURATION *
                                  SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                              child: ChangeCameraButton(
                                disabled: lockCamera || isRecording,
                                onChangeCamera: () {
                                  final currentCameraIndex = GlobalValuesManager
                                      .cameras
                                      .indexOf(controller!.description);
                                  final availableCameras =
                                      GlobalValuesManager.cameras.length;

                                  onNewCameraSelected(
                                    GlobalValuesManager.cameras[
                                        (currentCameraIndex + 1) %
                                            availableCameras],
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: FadeAndMoveInAnimation(
                              child: RecordButton(
                                disabled: lockCamera,
                                active: isRecording,
                                onVideoBegin: () async {
                                  setState(() {
                                    isRecording = true;
                                  });

                                  if (controller!.value.isRecordingVideo) {
                                    // A recording has already started, do nothing.
                                    return;
                                  }

                                  await controller!.startVideoRecording();
                                },
                                onVideoEnd: takeVideo,
                                onPhotoShot: takePhoto,
                              ),
                            ),
                          ),
                          Expanded(
                            child: FadeAndMoveInAnimation(
                              translationDuration:
                                  DEFAULT_TRANSLATION_DURATION *
                                      SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                              opacityDuration: DEFAULT_OPACITY_DURATION *
                                  SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                              child: TodayPhotoButton(
                                onLeave: () {
                                  controller!.setFlashMode(FlashMode.off);
                                },
                                onComeBack: () {
                                  if (isTorchEnabled) {
                                    controller!.setFlashMode(FlashMode.torch);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              expandableContent: Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: LARGE_SPACE,
                    right: LARGE_SPACE,
                    bottom: MEDIUM_SPACE,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => isTorchEnabled ? Colors.white : Colors.black,
                          ),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => isTorchEnabled ? Colors.black : Colors.white,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            isTorchEnabled = !isTorchEnabled;

                            if (isTorchEnabled) {
                              controller!.setFlashMode(FlashMode.torch);
                            } else {
                              controller!.setFlashMode(FlashMode.off);
                            }
                          });
                        },
                        child: IconButtonChild(
                          icon: const Icon(Icons.flashlight_on_rounded),
                          label:
                              Text(localizations.mainScreenActionsTorchButton),
                        ),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => Colors.white10,
                          ),
                          foregroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (_) => Colors.white,
                          ),
                        ),
                        onPressed: zoomLevels == null
                            ? null
                            : () {
                                final newZoomLevelIndex =
                                    ((currentZoomLevelIndex + 1) %
                                        zoomLevels!.length);

                                controller!.setZoomLevel(
                                    zoomLevels![newZoomLevelIndex]);

                                setState(() {
                                  currentZoomLevelIndex = newZoomLevelIndex;
                                });
                              },
                        child: zoomLevels == null
                            ? const Text('1x')
                            : Text(
                                formatZoomLevel(currentZoomLevel),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }(),
      ),
    );
  }
}
