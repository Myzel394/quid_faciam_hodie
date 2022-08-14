import 'dart:math';

import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:share_location/foreign_types/memory.dart';

class MemoryPack extends PropertyChangeNotifier<String> {
  final List<Memory> _memories;
  int _currentMemoryIndex = 0;
  bool _paused = false;
  bool _completed = false;

  MemoryPack(this._memories);

  List<Memory> get memories => [..._memories];
  int get currentMemoryIndex => _currentMemoryIndex;
  Memory get currentMemory => _memories[_currentMemoryIndex];
  bool get paused => _paused;
  bool get completed => _completed;
  bool get isLast => _currentMemoryIndex == _memories.length - 1;

  void setPaused(bool paused) {
    _paused = paused;
    notifyListeners('paused');
  }

  void next() {
    if (isLast) {
      _completed = true;
      notifyListeners('completed');
    } else {
      _paused = false;
      _completed = false;
      _currentMemoryIndex++;
      notifyListeners();
    }
  }

  void previous() {
    _currentMemoryIndex = max(_currentMemoryIndex - 1, 0);
    _paused = false;
    _completed = false;
    notifyListeners();
  }

  void reset() {
    _completed = false;
    _paused = false;
    _currentMemoryIndex = 0;
    notifyListeners();
  }

  void removeMemory(int index) {
    _memories.removeAt(index);
    notifyListeners();
  }

  void removeCurrentMemory() => removeMemory(_currentMemoryIndex);

  void pause() => setPaused(true);
  void resume() => setPaused(false);
}
