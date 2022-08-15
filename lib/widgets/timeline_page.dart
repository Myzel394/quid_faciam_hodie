import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/models/memory_pack.dart';
import 'package:share_location/models/timeline.dart';
import 'package:share_location/models/timeline_overlay.dart';
import 'package:share_location/widgets/memory_sheet.dart';
import 'package:share_location/widgets/memory_slide.dart';

class TimelinePage extends StatefulWidget {
  final DateTime date;

  const TimelinePage({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final timelineOverlayController = TimelineOverlay();
  final pageController = PageController();

  Timer? overlayRemover;

  MemoryPack getMemoryPack() => context.read<TimelineModel>().currentMemoryPack;

  void _handleOverlayChangeBasedOnMemoryPack() {
    if (!mounted) {
      return;
    }

    final timeline = context.read<TimelineModel>();

    if (timeline.paused) {
      timelineOverlayController.hideOverlay();
    } else {
      timelineOverlayController.restoreOverlay();
    }
  }

  void _jumpToCorrectPageFromMemoryPack() {
    if (!mounted) {
      return;
    }

    final timeline = context.read<TimelineModel>();

    if (timeline.memoryIndex != pageController.page) {
      pageController.animateToPage(
        timeline.memoryIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    final timeline = context.read<TimelineModel>();

    timelineOverlayController.addListener(() {
      if (!mounted) {
        return;
      }

      if (timelineOverlayController.state == TimelineState.completed) {
        timelineOverlayController.reset();
        timeline.nextMemory();
      }
    }, ['state']);

    timelineOverlayController.addListener(() {
      if (!mounted) {
        return;
      }

      // Force update to ensure overlays are up-to-date.
      setState(() {});
    }, ['showOverlay']);

    timelineOverlayController
        .addListener(_handleOverlayChangeBasedOnMemoryPack, ['state']);

    timeline.addListener(_jumpToCorrectPageFromMemoryPack);
  }

  @override
  void dispose() {
    pageController.dispose();

    try {
      final timeline = context.read<TimelineModel>();

      timeline.removeListener(_jumpToCorrectPageFromMemoryPack);
    } catch (error) {
      // Timeline has been removed completely
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        final timeline = context.read<TimelineModel>();

        timeline.pause();

        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (sheetContext) => MemorySheet(
            memory: timeline.currentMemory,
            sheetContext: sheetContext,
            onDelete: () async {
              timeline.removeCurrentMemory();
            },
            onVisibilityChanged: () async {
              timeline.refreshFromServer();
            },
          ),
        );

        if (!mounted) {
          return;
        }

        timeline.resume();
      },
      onTapDown: (_) {
        final timeline = context.read<TimelineModel>();

        timeline.pause();

        overlayRemover = Timer(
          const Duration(milliseconds: 600),
          timelineOverlayController.hideOverlay,
        );
      },
      onTapUp: (_) {
        final timeline = context.read<TimelineModel>();

        overlayRemover?.cancel();
        timeline.resume();
        timelineOverlayController.restoreOverlay();
      },
      onTapCancel: () {
        final timeline = context.read<TimelineModel>();

        overlayRemover?.cancel();
        timeline.resume();
        timelineOverlayController.restoreOverlay();
      },
      onHorizontalDragEnd: (details) {
        final timeline = context.read<TimelineModel>();

        if (details.primaryVelocity! < 0) {
          timeline.nextMemory();
        } else if (details.primaryVelocity! > 0) {
          timeline.previousMemory();
        }
      },
      child: ChangeNotifierProvider.value(
        value: timelineOverlayController,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Consumer<TimelineModel>(
              builder: (_, timeline, __) => PageView.builder(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => MemorySlide(
                  key: Key(timeline.currentMemoryPack.memories[index].filename),
                  memory: timeline.currentMemoryPack.memories[index],
                ),
                itemCount: timeline.currentMemoryPack.memories.length,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: LARGE_SPACE,
                left: MEDIUM_SPACE,
                right: MEDIUM_SPACE,
              ),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linearToEaseOut,
                opacity: timelineOverlayController.showOverlay ? 1.0 : 0.0,
                child: Text(
                  DateFormat('dd. MMMM yyyy').format(widget.date),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline1,
                ),
              ),
            ),
            Positioned(
              right: SMALL_SPACE,
              bottom: SMALL_SPACE * 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SMALL_SPACE),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linearToEaseOut,
                  opacity: timelineOverlayController.showOverlay ? 1.0 : 0.0,
                  child: Consumer<TimelineModel>(
                    builder: (_, timeline, __) => Text(
                      '${timeline.memoryIndex + 1}/${timeline.currentMemoryPack.memories.length}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
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
