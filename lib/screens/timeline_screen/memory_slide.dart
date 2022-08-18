import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/controllers/status_controller.dart';
import 'package:quid_faciam_hodie/enums.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/models/timeline.dart';
import 'package:quid_faciam_hodie/widgets/status.dart';

import 'memory_view.dart';

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

    final timeline = context.read<TimelineModel>();

    timeline.addListener(() {
      if (!mounted) {
        return;
      }

      if (timeline.paused) {
        controller?.stop();
      } else {
        controller?.start();
      }
    }, ['paused']);
  }

  @override
  void dispose() {
    controller?.dispose();

    super.dispose();
  }

  void initializeAnimation(final Duration newDuration) {
    duration = newDuration;

    controller = StatusController(
      duration: newDuration,
    );

    controller!.addListener(() {
      if (!mounted) {
        return;
      }

      final timeline = context.read<TimelineModel>();

      if (controller!.done) {
        timeline.nextMemory();
      }
    }, ['done']);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimelineModel>(
      builder: (___, timeline, ____) => Status(
        controller: controller,
        isIndeterminate: controller == null,
        paused: timeline.paused,
        hideProgressBar: !timeline.showOverlay,
        child: MemoryView(
          memory: widget.memory,
          loopVideo: false,
          onFileDownloaded: () {
            if (widget.memory.type == MemoryType.photo) {
              initializeAnimation(DEFAULT_IMAGE_DURATION);
            }
          },
          onVideoControllerInitialized: (controller) {
            if (mounted) {
              initializeAnimation(controller.value.duration);

              timeline.addListener(() {
                if (!mounted) {
                  return;
                }

                if (timeline.paused) {
                  controller.pause();
                } else {
                  controller.play();
                }
              }, ['paused']);
            }
          },
        ),
      ),
    );
  }
}
