import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_location/extensions/date.dart';
import 'package:share_location/models/timeline.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/timeline_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TimelineScreen extends StatefulWidget {
  static const ID = 'timeline';

  final DateTime? date;

  const TimelineScreen({
    Key? key,
    this.date,
  }) : super(key: key);

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> with Loadable {
  final pageController = PageController();
  final timeline = TimelineModel();
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

    timeline.initialize();

    // Update page view
    timeline.addListener(() async {
      if (timeline.currentIndex != pageController.page) {
        _goToPage(timeline.currentIndex);
      }
    }, ['currentIndex']);

    // Update page when initializing is done
    timeline.addListener(() {
      if (!mounted) {
        return;
      }

      setState(() {});

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final initialIndex = getIndexFromDate();

        await _goToPage(initialIndex);

        timeline.setCurrentIndex(initialIndex);
      });
    }, ['isInitializing']);
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
        .indexWhere((date) => DateTime.parse(date).isSameDay(widget.date!));
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
            memoryPack: timeline.atIndex(index),
          ),
        ),
      ),
    );
  }
}
