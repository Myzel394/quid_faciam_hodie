import 'dart:math';

import 'package:intl/intl.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:share_location/models/memory_pack.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TimelineModel extends PropertyChangeNotifier<String> {
  final Map<String, MemoryPack> _timeline;

  TimelineModel({
    Map<String, MemoryPack>? timeline,
  }) : _timeline = timeline ?? {};

  int _currentIndex = 0;
  int _memoryIndex = 0;
  bool _paused = false;
  bool _isInitializing = true;

  Map<String, MemoryPack> get values => _timeline;
  int get length => _timeline.length;
  int get currentIndex => _currentIndex;
  int get memoryIndex => _memoryIndex;
  bool get paused => _paused;
  bool get isInitializing => _isInitializing;

  static Map<String, MemoryPack> mapFromMemoriesList(
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

    return Map.fromEntries(
      map.entries.map(
        (entry) => MapEntry<String, MemoryPack>(
          entry.key,
          MemoryPack(entry.value),
        ),
      ),
    );
  }

  DateTime dateAtIndex(final int index) =>
      DateTime.parse(_timeline.keys.elementAt(index));

  MemoryPack atIndex(final int index) => _timeline.values.elementAt(index);

  MemoryPack get currentMemoryPack => atIndex(currentIndex);
  bool get isAtLastMemory =>
      _memoryIndex == currentMemoryPack.memories.length - 1;

  Memory get currentMemory =>
      currentMemoryPack.memories.elementAt(_memoryIndex);

  void _removeEmptyDates() {
    _timeline.removeWhere((key, value) => value.memories.isEmpty);
  }

  void setCurrentIndex(final int index) {
    _currentIndex = min(_timeline.length - 1, max(0, index));
    notifyListeners('currentIndex');
  }

  void setMemoryIndex(final int index) {
    _memoryIndex = min(
      _timeline.values.elementAt(_currentIndex).memories.length - 1,
      max(0, index),
    );
    notifyListeners('memoryIndex');
  }

  void setPaused(bool paused) {
    _paused = paused;
    notifyListeners('paused');
  }

  void setIsInitializing(bool isInitializing) {
    _isInitializing = isInitializing;
    notifyListeners('isInitializing');
  }

  void removeMemory(
    final int timelineIndex,
    final int memoryIndex,
  ) {
    _timeline.values.elementAt(timelineIndex).memories.removeAt(memoryIndex);
    _removeEmptyDates();
    notifyListeners();
  }

  void removeCurrentMemory() => removeMemory(_currentIndex, _memoryIndex);

  void pause() => setPaused(true);
  void resume() => setPaused(false);

  void nextTimeline() {
    if (currentIndex == length - 1) {
      return;
    }
    setCurrentIndex(currentIndex + 1);
    setMemoryIndex(0);
  }

  void previousTimeline() {
    if (currentIndex == 0) {
      return;
    }

    setCurrentIndex(currentIndex - 1);
    setMemoryIndex(currentMemoryPack.memories.length - 1);
  }

  void nextMemory() {
    if (isAtLastMemory) {
      nextTimeline();
    } else {
      setMemoryIndex(memoryIndex + 1);
    }
  }

  void previousMemory() {
    if (memoryIndex == 0) {
      previousTimeline();
    } else {
      setMemoryIndex(memoryIndex - 1);
    }
  }

  Future<void> initialize() async {
    setIsInitializing(true);

    await refreshFromServer();

    setIsInitializing(false);
  }

  Future<void> refreshFromServer() async {
    final response = await supabase
        .from('memories')
        .select()
        .order('created_at', ascending: false)
        .execute();
    final memories = List<Memory>.from(
      List<Map<String, dynamic>>.from(response.data).map(Memory.parse),
    );

    values
      ..clear()
      ..addAll(mapFromMemoriesList(memories));

    notifyListeners();
  }
}
