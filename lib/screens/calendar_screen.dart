import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:provider/provider.dart';
import 'package:quid_faciam_hodie/constants/spacing.dart';
import 'package:quid_faciam_hodie/managers/calendar_manager.dart';
import 'package:quid_faciam_hodie/models/calendar_model.dart';
import 'package:quid_faciam_hodie/models/memories.dart';
import 'package:quid_faciam_hodie/screens/calendar_screen/save_to_gallery_modal.dart';

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
      builder: (context, memories, _) => ChangeNotifierProvider<CalendarModel>(
        create: (_) => CalendarModel(),
        child: Consumer<CalendarModel>(
          builder: (_, calendar, __) => PlatformScaffold(
            appBar: (calendar.isInSelectMode || isCupertino(context))
                ? PlatformAppBar(
                    leading: calendar.isInSelectMode
                        ? PlatformIconButton(
                            icon: Icon(context.platformIcons.clear),
                            onPressed: calendar.clearDates,
                          )
                        : null,
                    trailingActions: calendar.isInSelectMode
                        ? <Widget>[
                            PlatformIconButton(
                              onPressed: () async {
                                calendar.setIsSavingToGallery(true);

                                final memoriesToSave =
                                    calendar.filterMemories(memories.memories);

                                final hasSavedAll = await showPlatformDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (_) => SaveToGalleryModal(
                                    memories: memoriesToSave,
                                  ),
                                );

                                if (hasSavedAll == true) {
                                  calendar.clearDates();
                                }

                                calendar.setIsSavingToGallery(true);
                              },
                              icon: Icon(isMaterial(context)
                                  ? Icons.download
                                  : CupertinoIcons.down_arrow),
                            ),
                          ]
                        : null,
                    title: Text(
                      calendar.isInSelectMode
                          ? localizations.calendarScreenSelectionTitle(
                              calendar.filterMemories(memories.memories).length,
                            )
                          : localizations.calendarScreenTitle,
                    ),
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
                      padding:
                          const EdgeInsets.symmetric(vertical: SMALL_SPACE),
                      child: const DaysOfWeekStrip(),
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == monthMapping.length) {
                            return const MemoriesData();
                          }

                          final date = monthMapping.keys.elementAt(index);
                          final dayMapping =
                              monthMapping.values.elementAt(index);

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
        ),
      ),
    );
  }
}
