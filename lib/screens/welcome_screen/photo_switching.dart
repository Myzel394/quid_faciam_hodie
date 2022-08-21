import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/managers/photo_manager.dart';
import 'package:quid_faciam_hodie/widgets/status.dart';

class PhotoSwitching extends StatefulWidget {
  final NetworkImage? initialImage;

  const PhotoSwitching({
    Key? key,
    this.initialImage,
  }) : super(key: key);

  @override
  State<PhotoSwitching> createState() => _PhotoSwitchingState();
}

class _PhotoSwitchingState extends State<PhotoSwitching> {
  // Contains two photos, the first one is the current photo, the second one is the next photo.
  // The second one will be precached for faster image switching
  late final List<NetworkImage> images;

  @override
  void initState() {
    super.initState();

    if (widget.initialImage != null) {
      images = [widget.initialImage!];
      getInitialPhoto();
    }
  }

  @override
  void didUpdateWidget(PhotoSwitching oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialImage != null) {
      images = [widget.initialImage!];
      getInitialPhoto();
    }
  }

  Future<void> getInitialPhoto() async {
    final query = WELCOME_SCREEN_PHOTOS_QUERIES[
        Random().nextInt(WELCOME_SCREEN_PHOTOS_QUERIES.length)];
    final url = await PhotoManager.getRandomPhoto(query);
    final nextPhotoFuture = PhotoManager.getRandomPhoto(query);

    if (!mounted) {
      return;
    }

    setState(() {
      images.add(NetworkImage(url));
    });

    final nextPhotoURL = await nextPhotoFuture;

    if (!mounted) {
      return;
    }

    final nextImage = NetworkImage(nextPhotoURL);
    precacheImage(nextImage, context);

    images.add(nextImage);
  }

  Future<void> getNextPhoto() async {
    final query = WELCOME_SCREEN_PHOTOS_QUERIES[
        Random().nextInt(WELCOME_SCREEN_PHOTOS_QUERIES.length)];
    final nextPhotoFuture = PhotoManager.getRandomPhoto(query);

    if (images.length == 1) {
      // We need to wait for the next photo to load first
      final nextPhotoURL = await nextPhotoFuture;

      if (!mounted) {
        return;
      }

      final nextImage = NetworkImage(nextPhotoURL);
      precacheImage(nextImage, context);

      setState(() {
        images[0] = images[1];
        images[1] = nextImage;
      });
    } else {
      setState(() {
        images[0] = images[1];
      });

      final nextPhotoURL = await nextPhotoFuture;

      if (!mounted) {
        return;
      }

      final nextImage = NetworkImage(nextPhotoURL);
      precacheImage(nextImage, context);

      images[1] = nextImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialImage == null) {
      return Center(
        child: PlatformCircularProgressIndicator(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(MEDIUM_SPACE),
      child: Status(
        key: Key(images.toString()),
        autoStart: true,
        onEnd: () async {
          getNextPhoto();
        },
        duration: const Duration(seconds: 3),
        child: Image(
          image: images[0],
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
