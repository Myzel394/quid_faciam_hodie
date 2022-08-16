import 'package:quid_faciam_hodie/foreign_types/memory.dart';

class MemoryPack {
  final List<Memory> _memories;

  const MemoryPack(this._memories);

  List<Memory> get memories => _memories;

  void orderMemories() {
    _memories.sort((a, b) => b.creationDate.compareTo(a.creationDate));
  }

  void updateWithNewMemory(final String memoryID, final Memory memory) {
    final index = _memories.indexWhere((memory) => memory.id == memoryID);

    if (index == -1) {
      throw Exception('Memory not found');
    }

    _memories[index] = memory;

    orderMemories();
  }

  void addMemory(final Memory memory) {
    _memories.add(memory);
    orderMemories();
  }
}
