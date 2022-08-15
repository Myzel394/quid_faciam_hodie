import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/constants/values.dart';
import 'package:share_location/extensions/snackbar.dart';
import 'package:share_location/managers/file_manager.dart';
import 'package:share_location/managers/global_values_manager.dart';
import 'package:share_location/utils/auth_required.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/animate_in_builder.dart';
import 'package:share_location/widgets/camera_button.dart';
import 'package:share_location/widgets/change_camera_button.dart';
import 'package:share_location/widgets/fade_and_move_in_animation.dart';
import 'package:share_location/widgets/today_photo_button.dart';
import 'package:share_location/widgets/uploading_photo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreen extends StatefulWidget {
  static const ID = 'main';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends AuthRequiredState<MainScreen> with Loadable {
  bool isRecording = false;
  bool lockCamera = false;
  List? lastPhoto;
  Uint8List? uploadingPhotoAnimation;

  late User _user;

  CameraController? controller;

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

    controller = cameraController;

    // Update UI if controller updates
    controller!.addListener(() {
      if (mounted) setState(() {});
    });

    controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
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
      body: SafeArea(
        child: () {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    AnimateInBuilder(
                      builder: (showPreview) => AnimatedOpacity(
                        opacity: showPreview ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1100),
                        curve: Curves.easeOutQuad,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SMALL_SPACE),
                          child: AspectRatio(
                            aspectRatio: 1 / controller!.value.aspectRatio,
                            child: controller!.buildPreview(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: LARGE_SPACE),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FadeAndMoveInAnimation(
                                  translationDuration:
                                      DEFAULT_TRANSLATION_DURATION *
                                          SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  opacityDuration: DEFAULT_OPACITY_DURATION *
                                      SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  child: ChangeCameraButton(
                                    onChangeCamera: () {
                                      final currentCameraIndex =
                                          GlobalValuesManager.cameras
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
                                  translationDuration:
                                      DEFAULT_TRANSLATION_DURATION *
                                          SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  opacityDuration: DEFAULT_OPACITY_DURATION *
                                      SECONDARY_BUTTONS_DURATION_MULTIPLIER,
                                  child: lastPhoto == null
                                      ? const TodayPhotoButton()
                                      : TodayPhotoButton(
                                          data: lastPhoto![0],
                                          type: lastPhoto![1],
                                        ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                if (uploadingPhotoAnimation != null)
                  UploadingPhoto(
                    data: uploadingPhotoAnimation!,
                    onDone: () {
                      setState(() {
                        uploadingPhotoAnimation = null;
                      });
                    },
                  ),
              ],
            ),
          );
        }(),
      ),
    );
  }
}
