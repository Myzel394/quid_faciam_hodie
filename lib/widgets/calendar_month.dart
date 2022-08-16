import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/flutter_calendar_widget.dart';
import 'package:intl/intl.dart';
import 'package:share_location/constants/spacing.dart';
import 'package:share_location/screens/timeline_screen.dart';
import 'package:share_location/widgets/delay_render.dart';
import 'package:share_location/widgets/fade_and_move_in_animation.dart';

class MonthCalendarBuilder extends CalendarBuilder {
  @override
  Widget buildDayOfWeek(DateTime dateTime, String weekdayString) {
    return const SizedBox.shrink();
  }

  @override
  Widget buildHeader(VoidCallback onLeftTap, VoidCallback onRightTap,
      DateTime dateTime, String locale) {
    final month = DateFormat.yMMMM(locale).format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
      child: Text(month, style: textStyle.headerTextStyle),
    );
  }

  @override
  Widget buildDate(DateTime dateTime, DateType type, List events) {
    final backgroundPercentage = () {
      if (events.isEmpty) {
        return 0.0;
      }

      final highestAmountOfEvents = events[0];
      final amount = events[1];
      return amount / highestAmountOfEvents;
    }();

    final duration = Duration(milliseconds: Random().nextInt(800));

    return DelayRender(
      delay: duration,
      child: FadeAndMoveInAnimation(
        child: Opacity(
          opacity: () {
            if (type.isOutSide) {
              return 0.0;
            }

            if (dateTime.isAfter(DateTime.now())) {
              return 0.4;
            }

            return 1.0;
          }(),
          child: Padding(
            padding: const EdgeInsets.all(TINY_SPACE),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SMALL_SPACE),
              child: Stack(
                alignment: style.dayAlignment,
                children: [
                  SizedBox(
                    child: Container(
                      color: textStyle.selectedDayTextColor
                          .withOpacity(backgroundPercentage),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      dateTime.day.toString(),
                      style: TextStyle(
                        color: backgroundPercentage > .5
                            ? textStyle.focusedDayTextColor
                            : textStyle.dayTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CalendarMonth extends StatelessWidget {
  final Map<DateTime, int> dayAmountMap;
  final int year;
  final int month;

  const CalendarMonth({
    Key? key,
    required this.dayAmountMap,
    required this.year,
    required this.month,
  }) : super(key: key);

  int get highestAmount =>
      dayAmountMap.values.isEmpty ? 0 : dayAmountMap.values.reduce(max);
  DateTime get firstDate => DateTime(year, month, 1);
  DateTime get lastDate =>
      DateTime(year, month, DateUtils.getDaysInMonth(year, month));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FlutterCalendar(
      focusedDate: firstDate,
      selectionMode: CalendarSelectionMode.single,
      calendarBuilder: MonthCalendarBuilder(),
      events: EventList(events: {
        DateTime(1990, 1, 1): [
          highestAmount,
        ],
        ...Map.fromEntries(
          dayAmountMap.entries.map((entry) {
            return MapEntry(
              entry.key,
              [highestAmount, entry.value],
            );
          }),
        ),
      }),
      minDate: firstDate,
      maxDate: lastDate,
      startingDayOfWeek: DayOfWeek.mon,
      onDayPressed: (date) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimelineScreen(date: date),
          ),
        );
      },
      style: const CalendarStyle(
        calenderMargin: EdgeInsets.symmetric(vertical: MEDIUM_SPACE),
      ),
      textStyle: CalendarTextStyle(
        headerTextStyle: theme.textTheme.subtitle1!,
        dayOfWeekTextColor: theme.textTheme.bodyText2!.color!,
        dayTextColor: theme.textTheme.bodyText1!.color!,
        // Background color
        selectedDayTextColor: theme.textTheme.bodyText1!.color!,
        // Foreground color
        focusedDayTextColor: theme.bottomAppBarColor,
      ),
    );
  }
}
