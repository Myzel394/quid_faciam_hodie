import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar_widget/flutter_calendar_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/constants/values.dart';
import 'package:quid_faciam_hodie/extensions/date.dart';
import 'package:quid_faciam_hodie/models/calendar_model.dart';
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
    final delay = Duration(
      microseconds: Random().nextInt(CALENDAR_DATE_IN_MAX_DELAY.inMicroseconds),
    );

    return Consumer<CalendarModel>(
      builder: (_, calendar, __) {
        final isSelected = calendar.checkWhetherDateIsSelected(dateTime);
        final backgroundPercentage = () {
          if (isSelected) {
            return 1.0;
          }

          if (events.isEmpty) {
            return 0.0;
          }

          final highestAmountOfEvents = events[0];
          final amount = events[1];
          return amount / highestAmountOfEvents;
        }();

        return DelayRender(
          delay: delay,
          child: FadeAndMoveInAnimation(
            opacityDuration:
                DEFAULT_OPACITY_DURATION * CALENDAR_DATE_IN_DURATION_MULTIPLIER,
            translationDuration: DEFAULT_TRANSLATION_DURATION *
                CALENDAR_DATE_IN_DURATION_MULTIPLIER,
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
              child: GestureDetector(
                onLongPress: () {
                  if (events.isNotEmpty) {
                    HapticFeedback.heavyImpact();

                    calendar.addDate(dateTime);
                  }
                },
                child: Material(
                  child: Padding(
                    padding: const EdgeInsets.all(TINY_SPACE),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(SMALL_SPACE),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            color: isSelected
                                ? textStyle.outsideDayTextColor
                                : textStyle.selectedDayTextColor
                                    .withOpacity(backgroundPercentage),
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
            ),
          ),
        );
      },
    );
  }
}

class CalendarMonth extends StatefulWidget {
  final Map<DateTime, int> dayAmountMap;
  final int year;
  final int month;

  const CalendarMonth({
    Key? key,
    required this.dayAmountMap,
    required this.year,
    required this.month,
  }) : super(key: key);

  @override
  State<CalendarMonth> createState() => _CalendarMonthState();
}

class _CalendarMonthState extends State<CalendarMonth> {
  int get highestAmount => widget.dayAmountMap.values.isEmpty
      ? 0
      : widget.dayAmountMap.values.reduce(max);

  DateTime get firstDate => DateTime(widget.year, widget.month, 1);

  DateTime get lastDate => DateTime(widget.year, widget.month,
      DateUtils.getDaysInMonth(widget.year, widget.month));

  bool doesDateExist(final DateTime date) =>
      widget.dayAmountMap.keys.contains(date.asNormalizedDate());

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarModel>(
      builder: (_, calendar, __) => FlutterCalendar(
        focusedDate: firstDate,
        selectionMode: CalendarSelectionMode.single,
        calendarBuilder: MonthCalendarBuilder(),
        events: EventList(events: {
          DateTime(1990, 1, 1): [
            highestAmount,
          ],
          ...Map.fromEntries(
            widget.dayAmountMap.entries.map((entry) {
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
          if (calendar.isInSelectMode &&
              widget.dayAmountMap.keys.contains(date.asNormalizedDate())) {
            HapticFeedback.selectionClick();

            calendar.toggleDate(date);
            return;
          }

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
          // Primary theme color
          outsideDayTextColor: platformThemeData(
            context,
            material: (data) => data.colorScheme.primary,
            cupertino: (data) => data.primaryColor,
          ),
        ),
      ),
    );
  }
}
