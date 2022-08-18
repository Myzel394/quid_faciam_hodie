import 'package:property_change_notifier/property_change_notifier.dart';

class StatusController extends PropertyChangeNotifier<String> {
  final Duration duration;
  bool _isForwarding = false;
  bool _done = false;

  bool get isForwarding => _isForwarding;
  bool get done => _done;

  StatusController({
    this.duration = const Duration(seconds: 4),
  });

  void start() {
    _isForwarding = true;
    notifyListeners('isForwarding');
  }

  void stop() {
    _isForwarding = false;
    notifyListeners('isForwarding');
  }

  void setDone() {
    _done = true;
    notifyListeners('done');
  }

  void reset() {
    _done = false;
    _isForwarding = false;
    notifyListeners('done');
  }
}
