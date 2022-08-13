import 'package:flutter/material.dart';
import 'package:share_location/widgets/timeline_scroll.dart';

class TimelineScreen extends StatelessWidget {
  static const ID = 'timeline';

  const TimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TimelineScroll();
  }
}
