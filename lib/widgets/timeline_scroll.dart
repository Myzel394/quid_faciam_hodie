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
    final newTimeline = TimelineModel.fromMemoriesList(memories);

    setState(() {
      timeline = newTimeline;
    });

    // Update page
    newTimeline.addListener(() {
      if (newTimeline.currentIndex != pageController.page) {
        pageController.animateToPage(
          newTimeline.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    }, ['currentIndex']);
  }

  @override
  Widget build(BuildContext context) {
    if (timeline == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider.value(
        value: timeline,
        child: PageView.builder(
          controller: pageController,
          scrollDirection: Axis.vertical,
          itemCount: timeline!.values.length,
          onPageChanged: (newPage) {
            if (timeline!.currentIndex != newPage) {
              // User manually changed page
              timeline!.setCurrentIndex(newPage);

              timeline!.setMemoryIndex(0);
            }
          },
          itemBuilder: (_, index) => TimelinePage(
            date: timeline!.dateAtIndex(index),
          ),
        ),
      ),
    );
  }
}
