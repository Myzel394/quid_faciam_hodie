import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/models/memory_pack.dart';

class TimelineModel extends ChangeNotifier {
  final Map<String, MemoryPack> _timeline;

  TimelineModel({
    Map<String, MemoryPack>? timeline,
  }) : _timeline = timeline ?? {};

  Map<String, MemoryPack> get values => _timeline;

  static TimelineModel fromMemoriesList(
    final List<Memory> memories,
  ) {
    final map = <String, List<Memory>>{};

    for (final memory in memories) {
      final date = DateFormat('yyyy-MM-dd').format(memory.creationDate);
      if (map.containsKey(date)) {
        map[date]!.add(memory);
      } else {
        map[date] = [memory];
      }
    }

    final data = Map.fromEntries(
      map.entries.map(
        (entry) => MapEntry<String, MemoryPack>(
          entry.key,
          MemoryPack(entry.value),
        ),
      ),
    );

    return TimelineModel(
      timeline: data,
    );
  }

  @override
  void dispose() {
    _timeline.values.forEach((memoryPack) {
      memoryPack.dispose();
    });

    super.dispose();
  }

  void removeEmptyDates() {
    final previousLength = _timeline.length;

    _timeline.removeWhere((key, value) => value.memories.isEmpty);

    final newLength = _timeline.length;

    if (previousLength != newLength) {
      notifyListeners();
    }
  }

  DateTime dateAtIndex(final int index) =>
      DateTime.parse(_timeline.keys.elementAt(index));

  MemoryPack atIndex(final int index) => _timeline.values.elementAt(index);
}
