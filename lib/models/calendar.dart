import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class CalendarModel extends ChangeNotifier {
  // Maps each day to an amount of memories on that day.
  // To remove days later we only store the IDs of the memories.
  final Map<String, Set<String>> _values = {};
  bool _isInitializing = true;

  RealtimeSubscription? _serverSubscription;

  bool get isInitializing => _isInitializing;

  CalendarModel();

  static String formatCreationDateKey(final DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static Map<String, Set<String>> mapFromMemoriesList(
      final List<Memory> memories) {
    final map = <String, Set<String>>{};

    for (final memory in memories) {
      final key = formatCreationDateKey(memory.creationDate);

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

  @override
  void dispose() {
    _serverSubscription?.unsubscribe(timeout: Duration.zero);

    super.dispose();
  }

  void setIsInitializing(final bool value) {
    _isInitializing = value;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    final response = await supabase
        .from('memories')
        .select()
        .order('created_at', ascending: false)
        .execute();
    final newMemories = List<Memory>.from(
      List<Map<String, dynamic>>.from(response.data).map(Memory.parse),
    );

    _values.addAll(mapFromMemoriesList(newMemories));
  }

  void _removeEmptyDates() {
    _values.removeWhere((key, value) => value.isEmpty);
  }

  void _addMemory(final Memory memory) {
    final key = formatCreationDateKey(memory.creationDate);

    if (_values.containsKey(key)) {
      _values[key]!.add(memory.id);
    } else {
      _values[key] = {
        memory.id,
      };
    }
  }

  void _removeMemory(final String id) {
    // Search for the id and remove it
    for (final memories in _values.values) {
      memories.remove(id);
    }

    _removeEmptyDates();
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

        _addMemory(memory);

        break;
      case 'DELETE':
        final id = response.oldRecord!['id'];

        _removeMemory(id);
        break;
      // Used for easier debugging
      case 'UPDATE':
        final memory = Memory.parse(response.newRecord!);

        _removeMemory(response.oldRecord!['id']);
        _addMemory(memory);
        break;
    }

    notifyListeners();
  }

  Future<void> initialize() async {
    setIsInitializing(true);

    await _loadInitialData();

    setIsInitializing(false);
    notifyListeners();

    // Watch new updates
    _serverSubscription = supabase
        .from('memories')
        .on(SupabaseEventTypes.all, _onServerUpdate)
        .subscribe();
  }

  Map<DateTime, Map<DateTime, int>> getMonthDayAmountMapping() {
    final map = <DateTime, Map<DateTime, int>>{};

    for (final entry in _values.entries) {
      final key = entry.key;
      final date = DateTime.parse(key);
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
}
