import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/models/timeline.dart';
import 'package:quid_faciam_hodie/utils/theme.dart';

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
    final timeline = context.watch<TimelineModel>();

    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            // Cupertino needs more space as the top bar is shown to provide a pop button
            top: isCupertino(context) ? LARGE_SPACE * 3 : LARGE_SPACE,
            left: MEDIUM_SPACE,
            right: MEDIUM_SPACE,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            curve: Curves.linearToEaseOut,
            opacity: timeline.showOverlay ? 1.0 : 0.0,
            child: Text(
              DateFormat.yMMMd().format(date),
              textAlign: TextAlign.center,
              style: platformThemeData(
                context,
                material: (data) => data.textTheme.headline1!.copyWith(
                  color: Colors.white,
                ),
                cupertino: (data) =>
                    data.textTheme.navLargeTitleTextStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: SMALL_SPACE * 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MEDIUM_SPACE),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.linearToEaseOut,
              opacity: timeline.showOverlay ? 1.0 : 0.0,
              child: Row(
                mainAxisAlignment:
                    (timeline.currentMemory.annotation.isNotEmpty)
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.end,
                children: <Widget>[
                  if (timeline.currentMemory.annotation.isNotEmpty)
                    Text(
                      timeline.currentMemory.annotation,
                      style: platformThemeData(
                        context,
                        material: (data) => data.textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                        ),
                        cupertino: (data) =>
                            data.textTheme.navTitleTextStyle.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  Row(
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: timeline.currentMemory.isPublic ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.linearToEaseOut,
                        child: Icon(
                          Icons.public,
                          size: getIconSizeForBodyText(context),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: SMALL_SPACE),
                      Text(
                        '$memoryIndex/$memoriesAmount',
                        style: platformThemeData(
                          context,
                          material: (data) =>
                              data.textTheme.titleSmall!.copyWith(
                            color: Colors.white,
                          ),
                          cupertino: (data) =>
                              data.textTheme.navTitleTextStyle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
