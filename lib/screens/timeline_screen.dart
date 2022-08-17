import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/extensions/date.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/models/timeline.dart';
import 'package:quid_faciam_hodie/utils/loadable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'calendar_screen.dart';
import 'timeline_screen/timeline_page.dart';

final supabase = Supabase.instance.client;

class TimelineScreen extends StatefulWidget {
  static const ID = '/timeline';

  final DateTime? date;

  const TimelineScreen({
    Key? key,
    this.date,
  }) : super(key: key);

  bool get popToCalendarScreen => date == null;

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with Loadable {
  late final pageController;
  late final TimelineModel timeline;

  @override
  initState() {
    super.initState();

    final memoriesModel = context.read<Memories>();

    timeline = TimelineModel(
      memories: memoriesModel.memories,
    );
    final initialIndex = getIndexFromDate();
    pageController = PageController(
      initialPage: initialIndex,
    );

    timeline.setCurrentIndex(initialIndex);

    memoriesModel.addListener(() {
      timeline.refresh(memoriesModel.memories);

      setState(() {});
    }, ['memories']);

    // Update page view
    timeline.addListener(() async {
      if (timeline.currentIndex != pageController.page) {
        await pageController.animateToPage(
          timeline.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    }, ['currentIndex']);
  }

  @override
  dispose() {
    pageController.dispose();

    super.dispose();
  }

  int getIndexFromDate() {
    if (widget.date == null) {
      return 0;
    }

    return timeline.values.keys
        .toList()
        .indexWhere((date) => date.isSameDay(widget.date!));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.popToCalendarScreen) {
          await Navigator.pushReplacementNamed(context, CalendarScreen.ID);

          return false;
        }

        return true;
      },
      child: PlatformScaffold(
        appBar: isCupertino(context)
            ? PlatformAppBar(
                title: Text('Timeline'),
              )
            : null,
        body: ChangeNotifierProvider.value(
          value: timeline,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: timeline.values.length,
            onPageChanged: (newPage) {
              if (timeline.currentIndex != newPage) {
                // User manually changed page
                timeline.setCurrentIndex(newPage);

                timeline.setMemoryIndex(0);
              }
            },
            itemBuilder: (_, index) => TimelinePage(
              date: timeline.dateAtIndex(index),
              memories: timeline.atIndex(index),
            ),
          ),
        ),
      ),
    );
  }
}
