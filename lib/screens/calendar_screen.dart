import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/calendar_manager.dart';
import 'package:quid_faciam_hodie/models/memories.dart';

import 'calendar_screen/calendar_month.dart';
import 'calendar_screen/days_of_week_strip.dart';
import 'calendar_screen/memories_data.dart';

class CalendarScreen extends StatelessWidget {
  static const ID = '/calendar';

  const CalendarScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final memoriesManager = context.read<Memories>();

    final calendarManager = CalendarManager(memories: memoriesManager.memories);
    final monthMapping = calendarManager.getMappingForList();

    return Consumer<Memories>(
      builder: (context, memories, _) => PlatformScaffold(
        appBar: isCupertino(context)
            ? PlatformAppBar(
                title: Text(localizations.calendarScreenTitle),
              )
            : null,
        body: Padding(
          padding: EdgeInsets.only(
            top: isCupertino(context) ? HUGE_SPACE : MEDIUM_SPACE,
          ),
          child: CustomScrollView(
            reverse: true,
            slivers: [
              SliverStickyHeader(
                header: Container(
                  color: platformThemeData(
                    context,
                    material: (data) => data.canvasColor,
                    cupertino: (data) => data.barBackgroundColor,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
                  child: const DaysOfWeekStrip(),
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == monthMapping.length) {
                        return MemoriesData();
                      }

                      final date = monthMapping.keys.elementAt(index);
                      final dayMapping = monthMapping.values.elementAt(index);

                      return CalendarMonth(
                        year: date.year,
                        month: date.month,
                        dayAmountMap: dayMapping,
                      );
                    },
                    childCount: monthMapping.length + 1,
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
