import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_location/enums.dart';
import 'package:video_player/video_player.dart';

class RawMemoryDisplay extends StatefulWidget {
  final Uint8List data;
  final MemoryType type;
  final bool loopVideo;
  final String? filename;

  const RawMemoryDisplay({
    Key? key,
    required this.data,
    required this.type,
    this.loopVideo = false,
    this.filename,
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

  Future<File> createTempVideo() async {
    final tempDirectory = await getTemporaryDirectory();
    final path = '${tempDirectory.path}/${widget.filename ?? 'video.mp4'}';

    if (widget.filename != null) {
      // File already exists, so just return the path
      return File(path);
    }

    // File needs to be created
    final file = await File(path).create();
    await file.writeAsBytes(widget.data);

    return file;
  }

  Future<void> initializeVideo() async {
    final file = await createTempVideo();

    videoController = VideoPlayerController.file(file);
    videoController!.initialize().then((value) {
      setState(() {});
      videoController!.setLooping(widget.loopVideo);
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
    switch (widget.type) {
      case MemoryType.photo:
        return Image.memory(
          widget.data,
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
        throw Exception('Unknown memory type: ${widget.type}');
    }
  }
}
