extension DateExtensions on DateTime {
  bool isSameDay(final DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
