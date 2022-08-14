import 'package:flutter/material.dart';
import 'package:share_location/controllers/memory_slide_controller.dart';
import 'package:share_location/controllers/status_controller.dart';
import 'package:share_location/enums.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/widgets/status.dart';

import 'memory.dart';

const BAR_HEIGHT = 4.0;
const DEFAULT_IMAGE_DURATION = Duration(seconds: 5);

class MemorySlide extends StatefulWidget {
  final Memory memory;
  final MemorySlideController controller;

  const MemorySlide({
    Key? key,
    required this.memory,
    required this.controller,
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

    widget.controller.addListener(() {
      if (!mounted) {
        return;
      }

      if (widget.controller.paused) {
        controller?.stop();
      } else {
        controller?.start();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  void initializeAnimation(final Duration duration) {
    this.duration = duration;

    controller = StatusController(
      duration: duration,
    )..addListener(widget.controller.setDone, ['done']);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Status(
      controller: controller,
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

            widget.controller.addListener(() {
              if (!mounted) {
                return;
              }

              if (widget.controller.paused) {
                controller.pause();
              } else {
                controller.play();
              }
            });
          }
        },
      ),
    );
  }
}
