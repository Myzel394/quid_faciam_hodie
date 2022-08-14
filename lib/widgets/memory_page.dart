import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/controllers/memory_slide_controller.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/widgets/memory_slide.dart';

class MemoryPage extends StatefulWidget {
  final DateTime date;
  final List<Memory> memories;
  final VoidCallback onPreviousTimeline;
  final VoidCallback onNextTimeline;

  const MemoryPage({
    Key? key,
    required this.date,
    required this.memories,
    required this.onPreviousTimeline,
    required this.onNextTimeline,
  }) : super(key: key);

  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  late final MemorySlideController controller;

  @override
  void initState() {
    super.initState();

    controller = MemorySlideController(memoryLength: widget.memories.length);
    controller.addListener(() {
      if (controller.done) {
        controller.next();
        // Force UI update
        setState(() {});
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        controller.setPaused(true);
      },
      onTapUp: (_) {
        controller.setPaused(false);
      },
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          MemorySlide(
            key: Key(controller.index.toString()),
            controller: controller,
            memory: widget.memories[controller.index],
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: LARGE_SPACE, left: MEDIUM_SPACE, right: MEDIUM_SPACE),
            child: Text(
              DateFormat('dd. MMMM yyyy').format(widget.date),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
        ],
      ),
    );
  }
}
