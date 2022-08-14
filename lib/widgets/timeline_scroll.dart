import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/models/timeline.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/timeline_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TimelineScroll extends StatefulWidget {
  TimelineScroll({
    Key? key,
  }) : super(key: key);

  @override
  State<TimelineScroll> createState() => _TimelineScrollState();
}

class _TimelineScrollState extends State<TimelineScroll> with Loadable {
  final pageController = PageController();
  TimelineModel? timeline;

  @override
  initState() {
    super.initState();
    loadTimeline();
  }

  @override
  dispose() {
    pageController.dispose();

    timeline?.dispose();

    super.dispose();
  }

  Future<void> loadTimeline() async {
    timeline?.dispose();

    final response = await supabase
        .from('memories')
        .select()
        .order('created_at', ascending: false)
        .execute();
    final memories = List<Memory>.from(
        List<Map<String, dynamic>>.from(response.data).map(Memory.parse));

    setState(() {
      timeline = TimelineModel.fromMemoriesList(memories);
    });

    timeline!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (timeline == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        scrollDirection: Axis.vertical,
        itemCount: timeline!.values.length,
        itemBuilder: (_, index) => ChangeNotifierProvider.value(
          value: timeline!.atIndex(index),
          child: TimelinePage(
            date: timeline!.dateAtIndex(index),
            onMemoryRemoved: () => timeline!.removeEmptyDates(),
            onNextTimeline: () {
              pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
            onPreviousTimeline: () {
              pageController.previousPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
        ),
      ),
    );
  }
}
