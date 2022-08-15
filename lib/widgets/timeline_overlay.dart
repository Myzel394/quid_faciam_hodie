import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/models/timeline.dart';
import 'package:share_location/models/timeline_overlay.dart';

class TimelineOverlay extends StatelessWidget {
  final DateTime date;
  final int memoryIndex;
  final int memoriesAmount;

  const TimelineOverlay({
    Key? key,
    required this.date,
    required this.memoryIndex,
    required this.memoriesAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeline = context.watch<TimelineModel>();
    final overlayController = context.watch<TimelineOverlayModel>();

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: LARGE_SPACE,
            left: MEDIUM_SPACE,
            right: MEDIUM_SPACE,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            curve: Curves.linearToEaseOut,
            opacity: overlayController.showOverlay ? 1.0 : 0.0,
            child: Text(
              DateFormat('dd. MMMM yyyy').format(date),
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
              opacity: overlayController.showOverlay ? 1.0 : 0.0,
              child: Row(
                children: <Widget>[
                  AnimatedOpacity(
                    opacity: timeline.currentMemory.isPublic ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.linearToEaseOut,
                    child: Icon(
                      Icons.public,
                      size: theme.textTheme.titleSmall!.fontSize,
                    ),
                  ),
                  const SizedBox(width: SMALL_SPACE),
                  Text(
                    '$memoryIndex/$memoriesAmount',
                    style: Theme.of(context).textTheme.titleSmall,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
