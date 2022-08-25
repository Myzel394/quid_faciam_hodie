import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:video_player/video_player.dart';

class RawMemoryDisplay extends StatefulWidget {
  final File? file;
  final Uint8List? data;
  final MemoryType type;
  final bool loopVideo;
  final void Function(VideoPlayerController)? onVideoControllerInitialized;
  final BoxFit? fit;

  const RawMemoryDisplay({
    Key? key,
    required this.type,
    this.loopVideo = false,
    this.fit = BoxFit.cover,
    this.onVideoControllerInitialized,
    this.file,
    this.data,
  }) : super(key: key);

  @override
  State<RawMemoryDisplay> createState() => _RawMemoryDisplayState();
}

class _RawMemoryDisplayState extends State<RawMemoryDisplay> {
  VideoPlayerController? videoController;

  @override
  void initState() {
    super.initState();

    if (widget.type == MemoryType.video) {
      initializeVideo();
    }
  }

  Future<void> initializeVideo() async {
    // `file` MUST be defined for videos.
    videoController = VideoPlayerController.file(widget.file!);
    videoController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {});
      videoController!.setLooping(widget.loopVideo);
      videoController!.play();

      if (widget.onVideoControllerInitialized != null) {
        widget.onVideoControllerInitialized!(videoController!);
      }
    });
  }

  @override
  void dispose() {
    videoController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case MemoryType.photo:
        if (widget.data != null) {
          return Image.memory(
            widget.data!,
            fit: widget.fit,
          );
        }

        return Image.file(
          widget.file!,
          fit: widget.fit,
        );
      case MemoryType.video:
        if (videoController == null) {
          return const SizedBox();
        }

        switch (widget.fit) {
          case BoxFit.contain:
            return Align(
              child: AspectRatio(
                aspectRatio: videoController!.value.aspectRatio,
                child: VideoPlayer(videoController!),
              ),
            );
          default:
            return AspectRatio(
              aspectRatio: videoController!.value.aspectRatio,
              child: VideoPlayer(videoController!),
            );
        }
      default:
        throw Exception('Unknown memory type: ${widget.type}');
    }
  }
}
