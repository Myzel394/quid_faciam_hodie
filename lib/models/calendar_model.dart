import 'package:flutter/material.dart';
import 'package:quid_faciam_hodie/extensions/date.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';

// The `CalendarModel` is only used to give the calendar day's a way to
// send whether they have been pressed to the parent widget.
class CalendarModel extends ChangeNotifier {
  bool _isSavingToGallery = false;
  final Set<DateTime> _selectedDates = {};

  bool get isInSelectMode => _selectedDates.isNotEmpty;
  bool get isSavingToGallery => _isSavingToGallery;
  Set<DateTime> get selectedDates => _selectedDates;

  void setIsInSelectMode(final bool value) {
    if (_isSavingToGallery) {
      return;
    }

    if (!value) {
      _selectedDates.clear();
    }
    notifyListeners();
  }

  void setIsSavingToGallery(final bool value) {
    _isSavingToGallery = value;
    notifyListeners();
  }

  void addDate(final DateTime date) {
    _selectedDates.add(date.asNormalizedDate());
    notifyListeners();
  }

  void removeDate(final DateTime date) {
    _selectedDates.removeWhere((element) => element == date.asNormalizedDate());
    notifyListeners();
  }

  void clearDates() {
    _selectedDates.clear();
    notifyListeners();
  }

  void toggleDate(final DateTime date) {
    if (checkWhetherDateIsSelected(date)) {
      removeDate(date);
    } else {
      addDate(date);
    }
  }

  Iterable<Memory> filterMemories(final Iterable<Memory> memories) =>
      memories.where(
        (memory) => _selectedDates.contains(
          memory.creationDate.asNormalizedDate(),
        ),
      );

  bool checkWhetherDateIsSelected(final DateTime date) {
    return _selectedDates.contains(date.asNormalizedDate());
  }
}
