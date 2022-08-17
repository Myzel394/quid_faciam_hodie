import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/flutter_calendar_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/extensions/date.dart';
import 'package:quid_faciam_hodie/screens/timeline_screen.dart';
import 'package:quid_faciam_hodie/widgets/delay_render.dart';
import 'package:quid_faciam_hodie/widgets/fade_and_move_in_animation.dart';

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

    final delay = Duration(
      microseconds: Random().nextInt(CALENDAR_DATE_IN_MAX_DELAY.inMicroseconds),
    );

    return DelayRender(
      delay: delay,
      child: FadeAndMoveInAnimation(
        opacityDuration:
            DEFAULT_OPACITY_DURATION * CALENDAR_DATE_IN_DURATION_MULTIPLIER,
        translationDuration:
            DEFAULT_TRANSLATION_DURATION * CALENDAR_DATE_IN_DURATION_MULTIPLIER,
        translationOffset: const Offset(0.0, -MEDIUM_SPACE),
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
  bool doesDateExist(final DateTime date) =>
      dayAmountMap.keys.contains(date.asNormalizedDate());

  @override
  Widget build(BuildContext context) {
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
        if (!doesDateExist(date)) {
          return;
        }

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
        headerTextStyle: platformThemeData(
          context,
          material: (data) => data.textTheme.subtitle1!,
          cupertino: (data) => data.textTheme.navTitleTextStyle,
        ),
        dayTextColor: platformThemeData(
          context,
          material: (data) => data.textTheme.bodyText1!.color!,
          cupertino: (data) => data.textTheme.textStyle.color!,
        ),
        // Background color
        selectedDayTextColor: platformThemeData(
          context,
          material: (data) => data.textTheme.bodyText1!.color!,
          cupertino: (data) => data.textTheme.textStyle.color!,
        ),
        // Foreground color
        focusedDayTextColor: platformThemeData(
          context,
          material: (data) => data.dialogBackgroundColor,
          cupertino: (data) => data.barBackgroundColor,
        ),
      ),
    );
  }
}
