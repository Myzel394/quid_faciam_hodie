import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/helpers/iterate_months.dart';
import 'package:share_location/models/calendar.dart';
import 'package:share_location/widgets/calendar_month.dart';
import 'package:share_location/widgets/days_of_week_strip.dart';

class CalendarScreen extends StatefulWidget {
  static const ID = 'calendar';

  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final calendar = CalendarModel();

  @override
  void initState() {
    super.initState();

    calendar.initialize();

    calendar.addListener(() {
      setState(() {});
    });
  }

  static Map<DateTime, Map<DateTime, int>> fillEmptyMonths(
      Map<DateTime, Map<DateTime, int>> monthMapping) {
    final earliestDate =
        monthMapping.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final latestDate = monthMapping.keys.reduce((a, b) => a.isAfter(b) ? a : b);

    final filledMonthMapping = <DateTime, Map<DateTime, int>>{};

    for (final date in iterateMonths(earliestDate, latestDate)) {
      filledMonthMapping[date] = monthMapping[date] ?? {};
    }

    return filledMonthMapping;
  }

  @override
  Widget build(BuildContext context) {
    if (calendar.isInitializing) {
      return CircularProgressIndicator();
    }

    final theme = Theme.of(context);
    final monthMapping = fillEmptyMonths(calendar.getMonthDayAmountMapping());
    final sortedMonthMapping = Map.fromEntries(
      monthMapping.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return Scaffold(
      body: CustomScrollView(
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
                (context, index) => CalendarMonth(
                  year: sortedMonthMapping.keys.elementAt(index).year,
                  month: sortedMonthMapping.keys.elementAt(index).month,
                  dayAmountMap: sortedMonthMapping.values.elementAt(index),
                ),
                childCount: sortedMonthMapping.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
