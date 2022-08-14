import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/controllers/memory_slide_controller.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/models/timeline_overlay.dart';
import 'package:share_location/widgets/memory_slide.dart';

class TimelinePage extends StatefulWidget {
  final DateTime date;
  final List<Memory> memories;
  final VoidCallback onPreviousTimeline;
  final VoidCallback onNextTimeline;

  const TimelinePage({
    Key? key,
    required this.date,
    required this.memories,
    required this.onPreviousTimeline,
    required this.onNextTimeline,
  }) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final timelineOverlayController = TimelineOverlay();
  final pageController = PageController();
  late final MemorySlideController controller;

  Timer? overlayRemover;

  @override
  void initState() {
    super.initState();

    controller = MemorySlideController(memoryLength: widget.memories.length);
    controller.addListener(() {
      if (controller.done) {
        controller.next();

        pageController.nextPage(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linearToEaseOut,
        );
      }
    }, ['done']);
    controller.addListener(() {
      if (controller.completed) {
        widget.onNextTimeline();
      }
    }, ['completed']);
  }

  @override
  void dispose() {
    controller.dispose();
    timelineOverlayController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        controller.setPaused(true);

        overlayRemover = Timer(
          const Duration(milliseconds: 200),
          timelineOverlayController.hideOverlay,
        );
      },
      onTapUp: (_) {
        overlayRemover?.cancel();

        controller.setPaused(false);

        timelineOverlayController.restoreOverlay();
      },
      onTapCancel: () {
        overlayRemover?.cancel();

        timelineOverlayController.restoreOverlay();
        controller.setPaused(false);
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          controller.next();

          pageController.nextPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.linearToEaseOut,
          );
        } else if (details.primaryVelocity! > 0) {
          controller.previous();

          pageController.previousPage(
            duration: const Duration(milliseconds: 200),
            curve: Curves.linearToEaseOut,
          );
        }
      },
      child: ChangeNotifierProvider<TimelineOverlay>(
        create: (_) => timelineOverlayController,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => MemorySlide(
                key: Key(controller.index.toString()),
                controller: controller,
                memory: widget.memories[controller.index],
              ),
              itemCount: widget.memories.length,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: LARGE_SPACE,
                left: MEDIUM_SPACE,
                right: MEDIUM_SPACE,
              ),
              child: Consumer<TimelineOverlay>(
                builder: (context, overlayController, _) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linearToEaseOut,
                  opacity: overlayController.showOverlay ? 1.0 : 0.0,
                  child: Text(
                    DateFormat('dd. MMMM yyyy').format(widget.date),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
