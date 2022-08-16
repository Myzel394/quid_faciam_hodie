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

  RealtimeSubscription? _serverSubscription;

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

  DateTime dateAtIndex(final int index) =>
      DateTime.parse(_timeline.keys.elementAt(index));

  MemoryPack atIndex(final int index) => _timeline.values.elementAt(index);

  MemoryPack get _currentMemoryPack => atIndex(currentIndex);
  bool get _isAtLastMemory =>
      _memoryIndex == _currentMemoryPack.memories.length - 1;
  Memory get currentMemory =>
      _currentMemoryPack.memories.elementAt(_memoryIndex);

  void _removeEmptyDates() {
    _timeline.removeWhere((key, value) => value.memories.isEmpty);
  }

  static formatCreationDateKey(final DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static Map<String, MemoryPack> mapFromMemoriesList(
    final List<Memory> memories,
  ) {
    final map = <String, List<Memory>>{};

    for (final memory in memories) {
      final key = formatCreationDateKey(memory.creationDate);

      if (map.containsKey(key)) {
        map[key]!.add(memory);
      } else {
        map[key] = [memory];
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
    setMemoryIndex(_currentMemoryPack.memories.length - 1);
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

  Future<void> initialize() async {
    setIsInitializing(true);

    await _listenToServer();

    setIsInitializing(false);
  }

  void _insertMemory(final Memory memory) {
    final key = formatCreationDateKey(memory.creationDate);

    if (!_timeline.containsKey(key)) {
      _timeline[key] = MemoryPack([memory]);
      return;
    }

    final memoryPack = _timeline[key]!;

    memoryPack.addMemory(memory);
  }

  void _updateMemory(final String id, final Memory memory) {
    final key = formatCreationDateKey(memory.creationDate);

    if (!_timeline.containsKey(key)) {
      _timeline[key] = MemoryPack([memory]);
      return;
    }

    final memoryPack = _timeline[key]!;

    memoryPack.updateWithNewMemory(id, memory);
  }

  void _deleteMemory(final String id) {
    // Search for correct `Memory` and remove it
    for (final memories in _timeline.values) {
      memories.memories.removeWhere((memory) => memory.id == id);
    }

    _removeEmptyDates();
  }

  Future<void> _fetchInitialData() async {
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
  }

  Future<void> _onServerUpdate(
    final SupabaseRealtimePayload response,
  ) async {
    if (response == null) {
      return;
    }

    switch (response.eventType) {
      case 'INSERT':
        final memory = Memory.parse(response.newRecord!);
        _insertMemory(memory);
        break;
      case 'UPDATE':
        final memoryID = response.oldRecord!['id'];
        final memory = Memory.parse(response.newRecord!);

        _updateMemory(memoryID, memory);
        break;
      case 'DELETE':
        final id = response.oldRecord!['id'];

        _deleteMemory(id);
        break;
    }

    notifyListeners();
  }

  Future<void> _listenToServer() async {
    await _fetchInitialData();
    notifyListeners();

    // Watch new updates
    _serverSubscription = supabase
        .from('memories')
        .on(SupabaseEventTypes.all, _onServerUpdate)
        .subscribe();
  }
}
