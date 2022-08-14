import 'package:flutter/material.dart';

class TimelineOverlay extends ChangeNotifier {
  bool _showOverlay = true;

  bool get showOverlay => _showOverlay;

  void hideOverlay() => setShowOverlay(false);
  void restoreOverlay() => setShowOverlay(true);

  void setShowOverlay(bool showOverlay) {
    _showOverlay = showOverlay;
    notifyListeners();
  }
}
