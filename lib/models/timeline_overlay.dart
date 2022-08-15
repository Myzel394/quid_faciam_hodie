import 'package:property_change_notifier/property_change_notifier.dart';

enum TimelineState {
  loading,
  paused,
  playing,
  completed,
}

class TimelineOverlayModel extends PropertyChangeNotifier<String> {
  bool _showOverlay = true;
  TimelineState _state = TimelineState.loading;

  bool get showOverlay => _showOverlay;
  TimelineState get state => _state;

  void hideOverlay() => setShowOverlay(false);
  void restoreOverlay() => setShowOverlay(true);

  void setShowOverlay(bool showOverlay) {
    _showOverlay = showOverlay;
    notifyListeners('showOverlay');
  }

  void setState(TimelineState state) {
    _state = state;
    notifyListeners('state');
  }

  void reset() {
    _showOverlay = true;
    _state = TimelineState.loading;
    notifyListeners();
  }
}
