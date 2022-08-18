import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/models/timeline.dart';

import 'memory_sheet.dart';
import 'memory_slide.dart';
import 'timeline_overlay.dart';

class TimelinePage extends StatefulWidget {
  final DateTime date;
  final List<Memory> memories;

  const TimelinePage({
    Key? key,
    required this.date,
    required this.memories,
  }) : super(key: key);

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  final pageController = PageController();

  Timer? overlayRemover;

  @override
  void initState() {
    super.initState();

    final timeline = context.read<TimelineModel>();

    // Jump to correct page
    timeline.addListener(() {
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
    }, ['memoryIndex']);
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeline = context.watch<TimelineModel>();

    return GestureDetector(
      onDoubleTap: () async {
        timeline.pause();

        await showPlatformModalSheet(
          context: context,
          material: MaterialModalSheetData(
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          ),
          builder: (sheetContext) => MemorySheet(
            memory: timeline.currentMemory,
            sheetContext: sheetContext,
          ),
        );

        if (!mounted) {
          return;
        }

        timeline.resume();
      },
      onTapDown: (_) => timeline.pause(),
      onTapUp: (_) => timeline.resume(),
      onTapCancel: () => timeline.resume(),
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          timeline.nextMemory();
        } else if (details.primaryVelocity! > 0) {
          timeline.previousMemory();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          PageView.builder(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, index) => MemorySlide(
              key: Key(widget.memories[index].filename),
              memory: widget.memories[index],
            ),
            itemCount: widget.memories.length,
          ),
          TimelineOverlay(
            date: widget.date,
            memoriesAmount: widget.memories.length,
            memoryIndex: timeline.memoryIndex + 1,
          ),
        ],
      ),
    );
  }
}
