import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:quid_faciam_hodie/foreign_types/memory.dart';
import 'package:quid_faciam_hodie/managers/global_values_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Memories extends PropertyChangeNotifier<String> {
  final List<Memory> _memories = [];

  Memories();

  RealtimeSubscription? _serverSubscription;
  bool _isInitialized = false;

  List<Memory> get memories => _memories;
  bool get isInitialized => _isInitialized;

  @override
  void dispose() {
    _serverSubscription?.unsubscribe();

    super.dispose();
  }

  void addMemory(final Memory memory) {
    _memories.add(memory);
    notifyListeners('memories');
  }

  void addAllMemories(final List<Memory> memories) {
    _memories.addAll(memories);
    notifyListeners('memories');
  }

  void removeMemory(final Memory memory) {
    _memories.remove(memory);
    notifyListeners('memories');
  }

  void removeMemoryByID(final String id) {
    _memories.removeWhere((memory) => memory.id == id);
    notifyListeners('memories');
  }

  void setIsInitialized(final bool value) {
    _isInitialized = value;
    notifyListeners('isInitialized');
  }

  void sortMemories() {
    _memories.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    notifyListeners('memories');
  }

  Future<void> initialize() async {
    setIsInitialized(false);

    await _loadInitialData();

    setIsInitialized(true);
    notifyListeners();

    // Watch new updates
    _serverSubscription = supabase
        .from('memories')
        .on(SupabaseEventTypes.all, _onServerUpdate)
        .subscribe();
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

        addMemory(memory);

        break;
      case 'DELETE':
        final id = response.oldRecord!['id'];

        removeMemoryByID(id);
        break;
      // Used for easier debugging
      case 'UPDATE':
        final memory = Memory.parse(response.newRecord!);
        final id = response.oldRecord!['id'];

        removeMemoryByID(id);
        addMemory(memory);
        break;
    }

    sortMemories();
  }

  Future<void> _loadInitialData() async {
    await GlobalValuesManager.waitForServerInitialization();

    final response = await supabase
        .from('memories')
        .select()
        .order('created_at', ascending: false)
        .execute();
    final newMemories = List<Memory>.from(
      List<Map<String, dynamic>>.from(response.data).map(Memory.parse),
    );

    addAllMemories(newMemories);
  }
}
