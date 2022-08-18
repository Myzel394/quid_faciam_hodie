import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/managers/photo_manager.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:quid_faciam_hodie/widgets/status.dart';

class PhotoSwitching extends StatefulWidget {
  const PhotoSwitching({Key? key}) : super(key: key);

  @override
  State<PhotoSwitching> createState() => _PhotoSwitchingState();
}

class _PhotoSwitchingState extends State<PhotoSwitching> with Loadable {
  late String photoURL;

  @override
  void initState() {
    super.initState();

    callWithLoading(getNextPhoto);
  }

  Future<void> getNextPhoto() async {
    final query = WELCOME_SCREEN_PHOTOS_QUERIES[
        Random().nextInt(WELCOME_SCREEN_PHOTOS_QUERIES.length)];
    final url = await PhotoManager.getRandomPhoto(query);

    if (!mounted) {
      return;
    }

    setState(() {
      photoURL = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(MEDIUM_SPACE),
      child: Image.network(
        photoURL,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return Status(
              autoStart: true,
              onEnd: () async {
                getNextPhoto();
              },
              duration: const Duration(seconds: 3),
              child: child,
            );
          }
          return const SizedBox.expand();
        },
        fit: BoxFit.cover,
      ),
    );
  }
}
