import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final timeline = TimelineModel();

  @override
  initState() {
    super.initState();

    timeline.initialize();

    // Update page view
    timeline.addListener(() {
      if (timeline.currentIndex != pageController.page) {
        pageController.animateToPage(
          timeline.currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    }, ['currentIndex']);

    // Update page when initializing is done
    timeline.addListener(() {
      setState(() {});
    }, ['isInitializing']);
  }

  @override
  dispose() {
    pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (timeline.isInitializing) {
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
            memoryPack: timeline.atIndex(index),
          ),
        ),
      ),
    );
  }
}
