import 'package:flutter/material.dart';
import 'package:flutter_calendar_widget/flutter_calendar_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';

class DaysOfWeekStrip extends StatelessWidget {
  final DayOfWeek startOfWeek;

  const DaysOfWeekStrip({
    Key? key,
    this.startOfWeek = DayOfWeek.mon,
  }) : super(key: key);

  int getWeekdayNumber(DayOfWeek weekday) =>
      DayOfWeek.values.indexOf(weekday) + 1;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: List.generate(
            7,
            (index) => Align(
              child: Text(
                DateFormat.E().format(
                  DateTime(1900, 1, 1)
                      .add(
                        Duration(days: index),
                      )
                      .add(
                        Duration(
                          days: 8 - getWeekdayNumber(DayOfWeek.mon),
                        ),
                      ),
                ),
                style: platformThemeData(
                  context,
                  material: (data) => data.textTheme.bodyText1!,
                  cupertino: (data) => data.textTheme.textStyle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
