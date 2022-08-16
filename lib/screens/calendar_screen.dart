import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/calendar_manager.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/widgets/calendar_month.dart';
import 'package:quid_faciam_hodie/widgets/days_of_week_strip.dart';

class CalendarScreen extends StatelessWidget {
  static const ID = 'calendar';

  const CalendarScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final memoriesManager = context.read<Memories>();
    final theme = Theme.of(context);

    final calendarManager = CalendarManager(memories: memoriesManager.memories);
    final monthMapping = calendarManager.getMappingForList();

    return Consumer<Memories>(
      builder: (context, memories, _) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
          child: CustomScrollView(
            reverse: true,
            slivers: [
              SliverStickyHeader(
                header: Container(
                  color: theme.canvasColor,
                  padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
                  child: const DaysOfWeekStrip(),
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final date = monthMapping.keys.elementAt(index);
                      final dayMapping = monthMapping.values.elementAt(index);

                      return CalendarMonth(
                        year: date.year,
                        month: date.month,
                        dayAmountMap: dayMapping,
                      );
                    },
                    childCount: monthMapping.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
