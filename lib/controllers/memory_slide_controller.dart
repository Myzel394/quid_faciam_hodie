import 'package:property_change_notifier/property_change_notifier.dart';

class MemorySlideController extends PropertyChangeNotifier<String> {
  final int memoryLength;

  MemorySlideController({
    required this.memoryLength,
  });

  int _index = 0;
  bool _paused = false;
  bool _done = false;
  bool _completed = false;

  bool get paused => _paused;
  bool get done => _done;
  int get index => _index;
  bool get completed => _completed;

  void setPaused(bool paused) {
    _paused = paused;
    notifyListeners('paused');
  }

  void setDone() {
    _done = true;
    notifyListeners('done');
  }

  void next() {
    if (_index == memoryLength - 1) {
      _completed = true;
      notifyListeners('completed');
    } else {
      _paused = false;
      _done = false;
      _index++;
      notifyListeners();
    }
  }

  void reset() {
    _completed = false;
    _paused = false;
    _done = false;
    _index = 0;

    notifyListeners();
  }
}
