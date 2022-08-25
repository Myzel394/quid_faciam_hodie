import 'package:flutter/services.dart';

class EventChannelWindowFocus {
  static const MethodChannel _channel =
      const MethodChannel('floss.myzel394.quid_faciam_hodie/window_focus');

  static void setGlobalListener(void Function(bool) listener) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'windowFocusChanged') {
        listener(call.arguments as bool);
      }

      return null;
    });
  }
}
