import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/enums.dart';
import 'package:video_player/video_player.dart';

class TodayPhotoButton extends StatefulWidget {
  final Uint8List? data;
  final MemoryType? type;

  const TodayPhotoButton({
    Key? key,
    this.data,
    this.type,
  }) : super(key: key);

  @override
  State<TodayPhotoButton> createState() => _TodayPhotoButtonState();
}

class _TodayPhotoButtonState extends State<TodayPhotoButton> {
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();

    if (widget.type == MemoryType.video) {
      initializeVideo();
    }
  }

  Future<void> initializeVideo() async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/video.mp4').create();
    file.writeAsBytesSync(widget.data!);

    videoController = VideoPlayerController.file(file);
    videoController!.initialize().then((value) {
      setState(() {});
      videoController!.setLooping(true);
      videoController!.play();
    });
  }

  @override
  void dispose() {
    videoController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(SMALL_SPACE),
          color: Colors.grey,
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(SMALL_SPACE),
            child: () {
              if (widget.data == null) {
                return SizedBox();
              }

              switch (widget.type) {
                case MemoryType.photo:
                  return Image.memory(
                    widget.data as Uint8List,
                    fit: BoxFit.cover,
                  );
                case MemoryType.video:
                  if (videoController == null) {
                    return const SizedBox();
                  }

                  return AspectRatio(
                    aspectRatio: videoController!.value.aspectRatio,
                    child: VideoPlayer(videoController!),
                  );
                default:
                  return const SizedBox();
              }
            }()),
      ),
    );
  }
}
