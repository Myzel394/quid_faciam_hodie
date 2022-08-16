import 'dart:async';
import 'dart:math';

import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:share_location/foreign_types/memory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class TimelineModel extends PropertyChangeNotifier<String> {
  final Map<DateTime, List<Memory>> _timeline;

  TimelineModel({
    required final List<Memory> memories,
  }) : _timeline = mapFromMemoriesList(memories);

  RealtimeSubscription? _serverSubscription;

  int _currentIndex = 0;
  int _memoryIndex = 0;
  bool _paused = false;
  bool _isInitializing = false;
  bool _showOverlay = true;
  Timer? _overlayRemoverTimer;

  Map<DateTime, List<Memory>> get values => _timeline;
  int get length => _timeline.length;
  int get currentIndex => _currentIndex;
  int get memoryIndex => _memoryIndex;
  bool get paused => _paused;
  bool get isInitializing => _isInitializing;
  bool get showOverlay => _showOverlay;

  DateTime dateAtIndex(final int index) => _timeline.keys.elementAt(index);

  List<Memory> atIndex(final int index) => _timeline.values.elementAt(index);

  List<Memory> get _currentMemoryPack => atIndex(currentIndex);
  bool get _isAtLastMemory => _memoryIndex == _currentMemoryPack.length - 1;
  Memory get currentMemory => _currentMemoryPack.elementAt(_memoryIndex);

  void _removeEmptyDates() {
    _timeline.removeWhere((key, memories) => memories.isEmpty);
  }

  static DateTime createDateKey(final DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void restoreOverlay() => setShowOverlay(true);
  void hideOverlay() => setShowOverlay(false);

  static Map<DateTime, List<Memory>> mapFromMemoriesList(
    final List<Memory> memories,
  ) {
    final map = <DateTime, List<Memory>>{};

    for (final memory in memories) {
      final key = createDateKey(memory.creationDate);

      if (map.containsKey(key)) {
        map[key]!.add(memory);
      } else {
        map[key] = [memory];
      }
    }

    return map;
  }

  @override
  void dispose() {
    _serverSubscription?.unsubscribe(timeout: Duration.zero);
    super.dispose();
  }

  void setCurrentIndex(final int index) {
    _currentIndex = min(_timeline.length - 1, max(0, index));
    notifyListeners('currentIndex');
  }

  void setMemoryIndex(final int index) {
    _memoryIndex = min(
      _timeline.values.elementAt(_currentIndex).length - 1,
      max(0, index),
    );
    resume();
    notifyListeners('memoryIndex');
  }

  void setPaused(final bool paused) {
    _paused = paused;

    _overlayRemoverTimer?.cancel();

    if (paused) {
      _overlayRemoverTimer = Timer(
        const Duration(milliseconds: 600),
        hideOverlay,
      );
    } else {
      restoreOverlay();
    }

    notifyListeners('paused');
  }

  void setIsInitializing(final bool isInitializing) {
    _isInitializing = isInitializing;
    notifyListeners('isInitializing');
  }

  void setShowOverlay(final bool showOverlay) {
    _showOverlay = showOverlay;
    notifyListeners('showOverlay');
  }

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
    setMemoryIndex(_currentMemoryPack.length - 1);
  }

  void nextMemory() {
    if (_isAtLastMemory) {
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

  void refresh(final List<Memory> memories) {
    setIsInitializing(true);

    _timeline.clear();
    _timeline.addAll(mapFromMemoriesList(memories));
    _removeEmptyDates();

    setIsInitializing(false);
  }
}
