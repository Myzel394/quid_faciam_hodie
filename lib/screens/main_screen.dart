import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/extensions/snackbar.dart';
import 'package:quid_faciam_hodie/managers/file_manager.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:quid_faciam_hodie/utils/auth_required.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/widgets/animate_in_builder.dart';
import 'package:quid_faciam_hodie/widgets/camera_button.dart';
import 'package:quid_faciam_hodie/widgets/change_camera_button.dart';
import 'package:quid_faciam_hodie/widgets/fade_and_move_in_animation.dart';
import 'package:quid_faciam_hodie/widgets/sheet_indicator.dart';
import 'package:quid_faciam_hodie/widgets/today_photo_button.dart';
import 'package:quid_faciam_hodie/widgets/uploading_photo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  static const ID = 'main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends AuthRequiredState<MainScreen> with Loadable {
  int currentZoomLevelIndex = 0;

  bool isRecording = false;
  bool lockCamera = false;
  bool isTorchEnabled = false;
  List? lastPhoto;
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

    callWithLoading(getLastPhoto);
    onNewCameraSelected(GlobalValuesManager.cameras[0]);
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

  Future<void> getLastPhoto() async {
    final data = await FileManager.getLastFile(_user);

    setState(() {
      lastPhoto = data;
    });
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
    if (controller!.value.isTakingPicture) {
      return;
    }

    setState(() {
      lockCamera = true;
    });

    try {
      context.showPendingSnackBar(
        message: 'Taking photo, please hold still...',
      );

      controller!.setFlashMode(FlashMode.off);
      final file = File((await controller!.takePicture()).path);

      setState(() {
        uploadingPhotoAnimation = file.readAsBytesSync();
      });

      context.showPendingSnackBar(message: 'Uploading photo...');

      try {
        await FileManager.uploadFile(_user, file);
      } catch (error) {
        context.showErrorSnackBar(message: error.toString());
        return;
      }

      context.showSuccessSnackBar(message: 'Photo uploaded!');
    } finally {
      setState(() {
        lockCamera = false;
        uploadingPhotoAnimation = null;
      });
    }

    if (mounted) {
      await getLastPhoto();
    }
  }

  Future<void> takeVideo() async {
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
      context.showPendingSnackBar(message: 'Saving video...');

      final file = File((await controller!.stopVideoRecording()).path);

      context.showPendingSnackBar(message: 'Uploading video...');

      try {
        await FileManager.uploadFile(_user, file);
      } catch (error) {
        if (mounted) {
          context.showErrorSnackBar(message: error.toString());
        }
        return;
      }

      context.showSuccessSnackBar(message: 'Video uploaded!');
    } finally {
      setState(() {
        lockCamera = false;
      });
    }

    if (mounted) {
      await getLastPhoto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomSheet: () {
        if (isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: MEDIUM_SPACE),
                Text('Loading camera'),
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
                          children: <Widget>[
                            controller!.buildPreview(),
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
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
                    child: SheetIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(LARGE_SPACE),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FadeAndMoveInAnimation(
                          translationDuration: DEFAULT_TRANSLATION_DURATION *
                              SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                          opacityDuration: DEFAULT_OPACITY_DURATION *
                              SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                          child: ChangeCameraButton(
                            disabled: lockCamera,
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
                        FadeAndMoveInAnimation(
                          child: CameraButton(
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
                        FadeAndMoveInAnimation(
                          translationDuration: DEFAULT_TRANSLATION_DURATION *
                              SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                          opacityDuration: DEFAULT_OPACITY_DURATION *
                              SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                          child: TodayPhotoButton(
                            data: lastPhoto == null ? null : lastPhoto![0],
                            type: lastPhoto == null ? null : lastPhoto![1],
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            expandableContent: Padding(
              padding: const EdgeInsets.only(
                left: LARGE_SPACE,
                right: LARGE_SPACE,
                bottom: MEDIUM_SPACE,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.flashlight_on_rounded),
                    label: const Text('Torch'),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (_) => isTorchEnabled ? Colors.white : Colors.black,
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
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
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (_) => Colors.white10,
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (_) => Colors.white,
                      ),
                    ),
                    onPressed: zoomLevels == null
                        ? null
                        : () {
                            final newZoomLevelIndex =
                                ((currentZoomLevelIndex + 1) %
                                    zoomLevels!.length);

                            controller!
                                .setZoomLevel(zoomLevels![newZoomLevelIndex]);

                            setState(() {
                              currentZoomLevelIndex = newZoomLevelIndex;
                            });
                          },
                    child: zoomLevels == null
                        ? Text('1x')
                        : Text(
                            formatZoomLevel(currentZoomLevel),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      }(),
    );
  }
}
