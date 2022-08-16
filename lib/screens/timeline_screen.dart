import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_location/extensions/date.dart';
import 'package:share_location/models/memories.dart';
import 'package:share_location/models/timeline.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/timeline_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'calendar_screen.dart';

final supabase = Supabase.instance.client;

class TimelineScreen extends StatefulWidget {
  static const ID = 'timeline';

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
  final pageController = PageController();
  late final TimelineModel timeline;
  bool _ignorePageChanges = false;

  Future<void> _goToPage(final int page) async {
    _ignorePageChanges = true;

    await pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );

    _ignorePageChanges = false;
  }

  @override
  initState() {
    super.initState();

    final memoriesModel = context.read<Memories>();

    timeline = TimelineModel(memories: memoriesModel.memories);

    memoriesModel.addListener(() {
      timeline.refresh(memoriesModel.memories);
    }, ['memories']);

    // Update page view
    timeline.addListener(() async {
      if (timeline.currentIndex != pageController.page) {
        _goToPage(timeline.currentIndex);
      }
    }, ['currentIndex']);

    print("blaaa");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initialIndex = getIndexFromDate();

      print("#" * 50);
      print(initialIndex);

      await _goToPage(initialIndex);

      timeline.setCurrentIndex(initialIndex);
    });
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
      child: Scaffold(
        body: ChangeNotifierProvider.value(
          value: timeline,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: timeline.values.length,
            onPageChanged: (newPage) {
              if (_ignorePageChanges) {
                return;
              }

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
