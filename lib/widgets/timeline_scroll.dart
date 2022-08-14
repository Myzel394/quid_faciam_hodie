import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/models/memory_pack.dart';
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
  Map<String, MemoryPack>? timeline;

  @override
  initState() {
    super.initState();
    loadTimeline();
  }

  Future<void> loadTimeline() async {
    final response = await supabase
        .from('memories')
        .select()
        .order('created_at', ascending: false)
        .execute();
    final memories = List<Memory>.from(
        List<Map<String, dynamic>>.from(response.data).map(Memory.parse));
    final timelineMapped = convertMemoriesToTimeline(memories);

    setState(() {
      timeline = timelineMapped;
    });
  }

  static Map<String, MemoryPack> convertMemoriesToTimeline(
    final List<Memory> memories,
  ) {
    final map = <String, List<Memory>>{};

    for (final memory in memories) {
      final date = DateFormat('yyyy-MM-dd').format(memory.creationDate);
      if (map.containsKey(date)) {
        map[date]!.add(memory);
      } else {
        map[date] = [memory];
      }
    }

    return Map.fromEntries(
      map.entries.map(
        (entry) => MapEntry<String, MemoryPack>(
          entry.key,
          MemoryPack(entry.value),
        ),
      ),
    );
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
        itemCount: timeline!.length,
        itemBuilder: (_, index) => ChangeNotifierProvider<MemoryPack>(
          create: (_) => timeline!.values.elementAt(index),
          child: TimelinePage(
            date: DateTime.parse(timeline!.keys.toList()[index]),
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
