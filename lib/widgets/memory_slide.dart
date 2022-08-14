import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_location/controllers/status_controller.dart';
import 'package:share_location/enums.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/models/memory_pack.dart';
import 'package:share_location/models/timeline_overlay.dart';
import 'package:share_location/widgets/status.dart';

import 'memory.dart';

const BAR_HEIGHT = 4.0;
const DEFAULT_IMAGE_DURATION = Duration(seconds: 5);

class MemorySlide extends StatefulWidget {
  final Memory memory;

  const MemorySlide({
    Key? key,
    required this.memory,
  }) : super(key: key);

  @override
  State<MemorySlide> createState() => _MemorySlideState();
}

class _MemorySlideState extends State<MemorySlide>
    with TickerProviderStateMixin {
  StatusController? controller;

  Duration? duration;

  @override
  void initState() {
    super.initState();

    final timelineOverlay = context.read<TimelineOverlay>();

    timelineOverlay.addListener(() {
      if (!mounted) {
        return;
      }

      switch (timelineOverlay.state) {
        case TimelineState.playing:
          controller?.start();
          break;
        default:
          controller?.stop();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  void initializeAnimation(final Duration duration) {
    final timelineOverlay = context.read<TimelineOverlay>();
    final memoryPack = context.read<MemoryPack>();

    this.duration = duration;

    controller = StatusController(
      duration: duration,
    );

    controller!.addListener(() {
      if (!mounted) {
        return;
      }

      if (controller!.done) {
        timelineOverlay.reset();
        memoryPack.next();
      }
    }, ['done']);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimelineOverlay>(
      builder: (_, timelineOverlay, __) => Consumer<MemoryPack>(
        builder: (___, memoryPack, ____) => Status(
          controller: controller,
          paused: memoryPack.paused,
          hideProgressBar: !timelineOverlay.showOverlay,
          child: MemoryView(
            creationDate: widget.memory.creationDate,
            location: widget.memory.location,
            filename: widget.memory.filename,
            loopVideo: false,
            onFileDownloaded: () {
              if (widget.memory.type == MemoryType.photo) {
                initializeAnimation(DEFAULT_IMAGE_DURATION);
              }
            },
            onVideoControllerInitialized: (controller) {
              if (mounted) {
                initializeAnimation(controller.value.duration);

                memoryPack.addListener(() {
                  if (!mounted) {
                    return;
                  }

                  if (memoryPack.paused) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                }, ['paused']);
              }
            },
          ),
        ),
      ),
    );
  }
}
