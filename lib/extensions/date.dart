extension DateExtensions on DateTime {
  bool isSameDay(final DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime asNormalizedDate() => DateTime(
        year,
        month,
        day,
        0,
        0,
        0,
        0,
        0,
      );
  DateTime asNormalizedDateTime() =>
      DateTime(year, month, day, hour, minute, 0, 0, 0);
}
