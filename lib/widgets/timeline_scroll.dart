import 'package:flutter/material.dart';
import 'package:share_location/utils/loadable.dart';
import 'package:share_location/widgets/memory.dart';
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
  dynamic timeline;

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

    setState(() {
      timeline = response.data;
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
        itemCount: timeline.length,
        itemBuilder: (_, index) => Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Memory(
            location: timeline[index]['location'],
            creationDate: DateTime.parse(timeline[index]['created_at']),
          ),
        ),
      ),
    );
  }
}
