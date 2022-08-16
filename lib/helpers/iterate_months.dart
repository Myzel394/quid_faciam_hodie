Iterable<DateTime> iterateMonths(
    final DateTime startDate, final DateTime endDate) sync* {
  final endDateLastDay = DateTime(endDate.year, endDate.month, 1);

  DateTime currentDate = startDate;

  yield currentDate;

  while (currentDate != endDateLastDay) {
    final nextDate = DateTime(currentDate.year, currentDate.month + 1, 1);

    if (nextDate.isAfter(endDate)) {
      break;
    }

    currentDate = nextDate;

    yield currentDate;
  }
}
