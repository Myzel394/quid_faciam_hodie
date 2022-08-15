import 'dart:collection';

const DURATION_INFINITY = Duration(days: 999);
const SECONDARY_BUTTONS_DURATION_MULTIPLIER = 1.8;
const PHOTO_SHOW_AFTER_CREATION_DURATION = Duration(milliseconds: 500);
final UnmodifiableSetView<double> DEFAULT_ZOOM_LEVELS =
    UnmodifiableSetView({0.6, 1, 2, 5, 10, 20, 50, 100});
