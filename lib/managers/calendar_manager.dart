import 'package:quid_faciam_hodie/extensions/date.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/helpers/iterate_months.dart';

class CalendarManager {
  final Map<DateTime, Set<String>> _values;

  CalendarManager({
    required final List<Memory> memories,
  }) : _values = mapFromMemoriesList(memories);

  static Map<DateTime, Set<String>> mapFromMemoriesList(
      final List<Memory> memories) {
    final map = <DateTime, Set<String>>{};

    for (final memory in memories) {
      final key = memory.creationDate.asNormalizedDate();

      if (map.containsKey(key)) {
        map[key]!.add(memory.id);
      } else {
        map[key] = {
          memory.id,
        };
      }
    }

    return map;
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

  Map<DateTime, Map<DateTime, int>> getMonthDayAmountMapping() {
    final map = <DateTime, Map<DateTime, int>>{};

    for (final entry in _values.entries) {
      final date = entry.key;
      final monthDate = DateTime(date.year, date.month, 1);
      final memoryIDs = entry.value;

      if (map.containsKey(monthDate)) {
        map[monthDate]![date] = memoryIDs.length;
      } else {
        map[monthDate] = {
          date: memoryIDs.length,
        };
      }
    }

    return map;
  }

  Map<DateTime, Map<DateTime, int>> getMappingForList() {
    final monthMapping = fillEmptyMonths(getMonthDayAmountMapping());

    return Map.fromEntries(
      monthMapping.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }
}
